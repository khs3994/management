# management

GitHub PR 리뷰 워크플로우 자동화를 위한 Claude Code 플러그인입니다.
PR 목록 조회 → WSJF 우선순위 평가 → 코드 리뷰 → Approve 판정까지 하나의 파이프라인으로 실행합니다.

## Skills

| 스킬 | 명령어 | 설명 |
|------|--------|------|
| Pending Reviews | `/management:pending-reviews` | PR 목록 조회 + WSJF 우선순위 + 코드 리뷰 + Approve 판정 |

## Prerequisites

- [Claude Code](https://claude.com/claude-code) v1.0.33+
- [GitHub CLI](https://cli.github.com/) (`gh`) 설치 및 인증

## Installation

```shell
# 1. 마켓플레이스 등록
/plugin marketplace add khs3994/management

# 2. 플러그인 설치
/plugin install management@management-marketplace
```

## Usage

```shell
# 전체 플로우 (WSJF + 코드 리뷰 + Approve 판정)
/management:pending-reviews

# WSJF 우선순위만 출력 (코드 리뷰 건너뜀)
/management:pending-reviews --skip-review

# 특정 레포만 필터링
/management:pending-reviews --repo fan-maum/trot-android

# 단순 테이블 출력
/management:pending-reviews --compact
```

또는 자연어로 "리뷰할 PR", "리뷰 대기", "코드 리뷰", "approve" 등을 언급하면 자동으로 실행됩니다.

## Pipeline

```
Step 1: PR 목록 조회 (fetch-review-prs.sh)
  ↓
Step 2: PR 상세 정보 병렬 수집 (fetch-pr-detail.sh)
  ↓
Step 3: WSJF 우선순위 평가 (pr-review-priority 에이전트)
  ↓
Step 4: 우선순위별 그룹 테이블 출력
  ↓  (--skip-review 시 여기서 종료)
Step 5: 리뷰 대상 분류 + Diff 수집
  ↓
Step 6: 병렬 Approve 판정 (pr-approve-judge 에이전트)
  ↓
Step 7: 종합 결과 출력 (Approve 가능 / 추가 확인 필요 / 리뷰 제외)
```

## WSJF Priority Criteria

WSJF = (Business Value + Time Criticality + Risk Reduction) / Job Duration

| 그룹 | WSJF 점수 |
|------|-----------|
| 🔴 높음 | >= 10 |
| 🟡 보통 | 4 ~ 9 |
| 🟢 낮음 | < 4 |

내부 작업(docs, chore, refactor 등)은 최종 점수에 ×0.5 감점 적용.

## Approve Checklist

pr-approve-judge 에이전트가 6개 항목을 전수 검사합니다:

| # | 항목 | 설명 |
|---|------|------|
| 1 | PR 설명 충실도 | body가 비어있거나 diff와 불일치 → FAIL |
| 2 | 보안 위험 | 하드코딩 시크릿, injection, XSS 등 → FAIL |
| 3 | 명백한 버그 | off-by-one, null 미처리, 리소스 누수 등 → FAIL |
| 4 | 사이드이펙트 범위 | PR 범위 초과 영향, breaking change 미반영 → FAIL |
| 5 | 변경 사유 추적 가능성 | behavior change인데 사유 미기재 → FAIL |
| 6 | 코드 품질 최소 기준 | 3회 이상 복붙, TODO/HACK 임시코드, 디버그 코드 잔존 → FAIL |

모든 항목 PASS 시 Approve 가능, 하나라도 FAIL 시 추가 확인 필요로 판정합니다.
애매하면 FAIL — 보수적 기준을 적용합니다.

## Review Exclusion

다음 PR은 코드 리뷰 대상에서 자동 제외됩니다:

| 조건 | 사유 |
|------|------|
| Draft PR | 개발 진행 중 |
| label에 `deploy` 포함 | Release/Deploy 병합 PR |
| title이 `[Main]`, `[Develop]`, `[Release`로 시작 | Release/Deploy 병합 PR |
| additions + deletions > 5000 | 변경 규모 과대 |

## Project Structure

```
management/
├── .claude-plugin/
│   ├── plugin.json              # 플러그인 매니페스트
│   └── marketplace.json         # 마켓플레이스 카탈로그
├── skills/
│   └── pending-reviews/
│       └── SKILL.md             # 리뷰 파이프라인 스킬
├── agents/
│   ├── pr-review-priority.md    # WSJF 기반 우선순위 평가 에이전트
│   └── pr-approve-judge.md      # 보수적 Approve 판정 에이전트
├── scripts/
│   ├── fetch-review-prs.sh      # 리뷰 요청 PR 목록 조회
│   └── fetch-pr-detail.sh       # PR 상세 정보 조회
└── templates/
    ├── default.md               # 우선순위 그룹별 출력 템플릿
    └── compact.md               # 단순 테이블 출력 템플릿
```

## Safety

이 플러그인은 GitHub에 직접 approve, comment, review submit을 하지 않습니다.
로컬에서 분석 결과를 출력할 뿐, GitHub API를 통한 리뷰 제출 동작은 수행하지 않습니다.

## License

MIT
