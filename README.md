# management

GitHub 워크플로우 자동화를 위한 Claude Code 스킬 모음집입니다.

## Skills

| 스킬 | 명령어 | 설명 |
|------|--------|------|
| Pending Reviews | `/management:pending-reviews` | 내가 리뷰어로 등록된 PR 목록 조회 및 우선순위 평가 |

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
# 리뷰 대기 PR 목록 확인
/management:pending-reviews
```

또는 자연어로 "리뷰할 PR", "리뷰 대기", "리뷰 목록" 등을 언급하면 자동으로 실행됩니다.

## Priority Criteria

| 기준 | 높음 | 보통 | 낮음 |
|------|------|------|------|
| PR 크기 (additions + deletions) | < 100 lines | 100-500 lines | > 500 lines |
| 생성 시간 | 3일 이상 경과 | 1-3일 | 당일 |
| 라벨 | `urgent`, `hotfix`, `bug` | `feature`, `enhancement` | `docs`, `chore` |

## Project Structure

```
management/
├── .claude-plugin/
│   ├── plugin.json          # 플러그인 매니페스트
│   └── marketplace.json     # 마켓플레이스 카탈로그
├── skills/
│   └── pending-reviews/
│       └── SKILL.md         # 리뷰 대기 PR 스킬
├── agents/
│   └── pr-review-priority.md  # WSJF 기반 우선순위 평가 에이전트
├── scripts/
│   ├── fetch-review-prs.sh  # 리뷰 요청 PR 목록 조회
│   └── fetch-pr-detail.sh   # PR 상세 정보 조회
└── templates/
    ├── default.md           # 우선순위 그룹별 출력 템플릿
    └── compact.md           # 단순 테이블 출력 템플릿
```

## License

MIT
