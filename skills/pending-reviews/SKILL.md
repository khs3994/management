---
name: pending-reviews
description: >
  내가 리뷰어로 등록된 PR 목록을 가져와서 WSJF 우선순위 평가 + 코드 리뷰 + Approve 가능 여부 판단까지 전체 플로우를 실행합니다.
  "pending-reviews", "리뷰할 PR", "리뷰 대기", "리뷰 목록", "코드 리뷰", "PR 리뷰", "approve"를 언급할 때 반드시 이 스킬을 사용하세요.
  --skip-review 옵션을 주면 WSJF 우선순위만 출력합니다.
---

# Pending Reviews - Full Review Pipeline

PR 목록 조회 → 상세 정보 수집 → WSJF 우선순위 → 코드 리뷰 → Approve 판정까지 하나의 파이프라인으로 실행한다.

## 옵션

| 옵션 | 설명 |
|---|---|
| `--skip-review` | Step 5~7을 건너뛰고 기존 WSJF 우선순위만 출력 (Step 1~4만 실행) |
| `--repo <owner/repo>` | 특정 레포만 필터링 (예: `--repo fan-maum/trot-android`) |
| `--compact` | 그룹화 없이 단순 테이블로 출력 |
| 옵션 없음 | 전체 플로우 (Step 1~7) 실행 |

## 안전 규칙

**절대 GitHub에 직접 approve, comment, review submit 하지 말 것.**
이 스킬은 로컬에서 분석 결과를 출력할 뿐, GitHub API를 통한 리뷰 제출 동작은 수행하지 않는다.

## 스크립트

GitHub API 호출은 직접 하지 않고, 반드시 아래 스크립트를 사용한다:

| 스크립트 | 용도 | 사용법 |
|---|---|---|
| `scripts/fetch-review-prs.sh` | 내가 리뷰어로 등록된 PR 목록 조회 | `bash scripts/fetch-review-prs.sh` |
| `scripts/fetch-pr-detail.sh` | 특정 PR의 상세 정보 조회 | `bash scripts/fetch-pr-detail.sh <owner/repo> <pr-number>` |

## 템플릿

| 템플릿 | 용도 | 사용 시점 |
|---|---|---|
| `templates/default.md` | 우선순위 그룹별 compact 테이블 | 기본 출력 형식 |
| `templates/compact.md` | 단순 테이블 | `--compact` 옵션 시 |

- 템플릿의 `{{placeholder}}`를 실제 데이터로 치환하여 출력한다.

---

## 실행 플로우

### Step 0: 사전 조건 확인
`gh` CLI가 설치되어 있는지 확인한다. 없으면 설치 후 로그인까지 완료한다:

```bash
if ! command -v gh &> /dev/null; then
  brew install gh
  gh auth login
fi
```

### Step 1: PR 목록 조회
`scripts/fetch-review-prs.sh`를 실행하여 리뷰 요청된 PR 목록을 가져온다.

`--repo` 옵션이 지정된 경우, 결과에서 해당 레포의 PR만 필터링한다.

### Step 2: PR 상세 정보 조회
목록의 각 PR에 대해 `scripts/fetch-pr-detail.sh`를 실행하여 상세 정보를 가져온다.
PR이 여러 건이면 병렬로 실행하여 속도를 높인다.

### Step 3: 우선순위 평가
`agents/pr-review-priority.md` 에이전트를 호출하여 각 PR의 WSJF 점수를 계산한다.
Step 2에서 수집한 PR 상세 정보(labels, additions, deletions, createdAt, comments 등)를 에이전트에 전달한다.

에이전트 호출 시 반드시 아래 내용을 프롬프트에 포함한다:
```
중요: 내부 작업 감점(Internal Work Penalty)을 반드시 적용해야 합니다.
각 PR마다 "내부/사용자대면" 판정, base_WSJF, final_WSJF를 출력하세요.
```

에이전트가 반환한 final_WSJF 점수 내림차순으로 PR을 정렬한다.

### Step 4: WSJF 우선순위 결과 출력
`templates/default.md` 템플릿을 읽고, `{{placeholder}}`를 실제 데이터로 치환하여 우선순위별로 그룹화된 테이블을 출력한다.
해당 그룹에 PR이 없으면 "없음"으로 표시한다.

WSJF 그룹 경계값:
- 🔴 높음: final_WSJF >= 10
- 🟡 보통: 4 <= final_WSJF < 10
- 🟢 낮음: final_WSJF < 4

> `--skip-review` 옵션이 지정된 경우, 여기서 종료한다.

---

### Step 5: 코드 리뷰 대상 분류 및 Diff 수집

Step 2에서 수집한 PR 상세 정보를 기반으로, 각 PR을 **리뷰 대상** 또는 **리뷰 제외**로 분류한다.

#### 리뷰 제외 조건 (하나라도 해당하면 제외)

| 조건 | 제외 사유 표시 |
|---|---|
| `isDraft == true` | Draft PR |
| label에 `deploy` 포함 | Release/Deploy 병합 PR |
| title이 `[Main]`으로 시작 | Release/Deploy 병합 PR |
| title이 `[Develop]`으로 시작 | Release/Deploy 병합 PR |
| title이 `[Release`로 시작 | Release/Deploy 병합 PR |
| additions + deletions > 5000 | 변경 규모 과대 |

#### Diff 수집

리뷰 대상으로 분류된 PR 각각에 대해 diff를 수집한다:

```bash
gh pr diff <number> --repo <owner/repo>
```

### Step 6: 병렬 Approve 판정

리뷰 대상 PR 각각에 대해 `management:pr-approve-judge` 에이전트를 **병렬로**(Agent tool의 `subagent_type="management:pr-approve-judge"`, `run_in_background=true`) 실행한다.

이 에이전트는 6개 체크리스트(PR 설명 충실도, 보안 위험, 명백한 버그, 사이드이펙트 범위, 변경 사유 추적 가능성, 코드 품질 최소 기준)를 **전수 검사**하여 모든 항목을 통과해야 Approve로 판정한다. 앞선 항목이 FAIL이어도 나머지를 건너뛰지 않으며, 애매한 경우 FAIL로 판정하는 보수적 기준을 적용한다.

각 에이전트에 전달할 프롬프트 구성:

```
아래 PR에 대해 6개 체크리스트 기준으로 즉시 Approve 가능한지 판정해주세요.

## PR 정보
- 제목: {{title}}
- 작성자: {{author}}
- 변경 규모: +{{additions}}/-{{deletions}}, {{changed_files}}개 파일
- 생성일: {{createdAt}} ({{days_elapsed}}일 경과)
- URL: {{url}}

## PR 설명
{{body}}

## Diff
{{diff}}

## 판정 요청
- 6개 항목(PR 설명 충실도, 보안 위험, 명백한 버그, 사이드이펙트 범위, 변경 사유 추적 가능성, 코드 품질 최소 기준)을 전수 검사하여 각각 PASS/FAIL 평가
- 모든 항목 PASS 시 ✅ Approve 가능, 하나라도 FAIL 시 ❌ 추가 확인 필요
- 판정 근거를 2~3줄로 요약하고, FAIL 항목은 번호와 함께 구체적 이슈를 bullet으로 나열
- **절대 GitHub에 직접 코멘트나 approve를 남기지 말 것**
```

### Step 7: 종합 결과 출력

모든 코드 리뷰 에이전트의 결과가 돌아오면, 아래 형식으로 Approve 판정 결과를 출력한다.
Step 4의 WSJF 우선순위 테이블 아래에 이어서 출력한다.

```markdown
## Approve 가능 여부 판정

### ✅ Approve 가능: N건
#### 1. `repo-name` [#번호](url) — 제목 (+N/-N)
- **판정 근거**: (2~3줄 요약)
- **참고**: (있으면)

### ❌ 추가 확인 필요: N건
#### 1. `repo-name` [#번호](url) — 제목 (+N/-N)
- **FAIL 항목**: #2 보안 위험, #5 변경 사유 추적 가능성
- **우려 사항**: (핵심 이슈 bullet)

### ⏭️ 리뷰 제외: N건
| Repo | PR | 제목 | 사유 |
|---|---|---|---|
| repo-name | #번호 | 제목 | Draft / Release 병합 PR / 변경 규모 과대 등 |

## 요약 테이블
| Repo | PR | 제목 | 판정 | FAIL 항목 | 주요 사유 |
|---|---|---|---|---|---|
```

판정 분류 기준:
- **Approve 가능**: pr-approve-judge 에이전트가 6개 체크리스트를 모두 PASS로 판단한 경우
- **추가 확인 필요**: pr-approve-judge 에이전트가 하나 이상의 체크리스트를 FAIL로 판단한 경우
- **리뷰 제외**: Step 5에서 제외된 PR
