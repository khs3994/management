---
name: pending-reviews
description: >
  내가 리뷰어로 등록된 PR 목록을 가져와서 리뷰 우선순위를 평가합니다.
  "pending-reviews", "리뷰할 PR", "리뷰 대기", "리뷰 목록"을 언급할 때 사용합니다.
---

# Pending Reviews - Review Priority Evaluator

## 언제 이 스킬을 사용하는가

아래 상황에서 이 스킬을 실행한다:

- 내가 리뷰어로 등록된 PR 목록을 확인하고 싶을 때
- 리뷰 우선순위를 파악하고 싶을 때
- "pending-reviews", "리뷰할 PR", "리뷰 대기" 등을 언급할 때

## Reference 문서

| 파일 | 설명 |
|---|---|
| `templates/default.md` | 우선순위 그룹별 compact 테이블 출력 템플릿 |
| `templates/compact.md` | 단순 테이블 출력 템플릿 |

## 스크립트

GitHub API 호출은 직접 하지 않고, 반드시 아래 스크립트를 사용한다:

| 스크립트 | 용도 | 사용법 |
|---|---|---|
| `scripts/fetch-review-prs.sh` | 내가 리뷰어로 등록된 PR 목록 조회 | `bash scripts/fetch-review-prs.sh` |
| `scripts/fetch-pr-detail.sh` | 특정 PR의 상세 정보 조회 | `bash scripts/fetch-pr-detail.sh <owner/repo> <pr-number>` |

## 템플릿

결과 출력 시 반드시 아래 템플릿 파일을 읽고 해당 형식에 맞춰 출력한다:

| 템플릿 | 용도 | 사용 시점 |
|---|---|---|
| `templates/default.md` | 우선순위 그룹별 compact 테이블 | 기본 출력 형식 |
| `templates/compact.md` | 단순 테이블 | `--compact` 옵션 또는 그룹화 없이 출력할 때 |

- 템플릿의 `{{placeholder}}`를 실제 데이터로 치환하여 출력한다.
- 템플릿에 정의된 컬럼 순서와 형식을 반드시 준수한다.

## 사용 방법

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

### Step 2: PR 상세 정보 조회
목록의 각 PR에 대해 `scripts/fetch-pr-detail.sh`를 실행하여 상세 정보를 가져온다.

### Step 3: 우선순위 평가
`agents/pr-review-priority.md` 에이전트를 호출하여 각 PR의 WSJF 점수를 계산한다.
Step 2에서 수집한 PR 상세 정보(labels, additions, deletions, createdAt, comments 등)를 에이전트에 전달한다.

에이전트 호출 시 반드시 아래 내용을 프롬프트에 포함한다:
```
중요: 내부 작업 감점(Internal Work Penalty)을 반드시 적용해야 합니다.
각 PR마다 "내부/사용자대면" 판정, base_WSJF, final_WSJF를 출력하세요.
```

에이전트가 반환한 final_WSJF 점수 내림차순으로 PR을 정렬한다.

### Step 4: 결과 출력
`templates/default.md` 템플릿을 읽고, `{{placeholder}}`를 실제 데이터로 치환하여 우선순위별로 그룹화된 테이블을 출력한다.
해당 그룹에 PR이 없으면 "없음"으로 표시한다.
