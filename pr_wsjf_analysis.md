# PR Review Priority Analysis - WSJF Scoring

## Scoring Methodology

### Business Value (BV)
- hotfix, critical, p0: 20
- bug: 13
- feature, enhancement: 8
- chore, refactor, docs: 3
- 라벨 없음: 5

### Time Criticality (TC)
- 3일 이상 경과: 20
- 2일 경과: 13
- 1일 경과: 8
- 1일 미만: 3

### Risk Reduction/Opportunity Enablement (RR/OE)
- security, auth, crash: 20
- performance, infra: 13
- 댓글 3개 이상: 8
- 그 외: 3

### Job Duration (변경 라인 수)
- 0-50: 1
- 51-200: 2
- 201-500: 3
- 501-1000: 5
- 1001-2000: 8
- 2001+: 13

### Scope Modifier (SM)
- Draft PR: 0.5 (50% 할인)
- "Do NOT Merge" 라벨: 0.3 (70% 할인)
- 정상 PR: 1.0

## Individual PR Analysis

### PR #1406 - 보물상자 연타제한 (165일 경과)
- **BV**: 5 (라벨 없음)
- **TC**: 20 (3일 이상 경과)
- **RR/OE**: 3 (그 외)
- **Job Duration**: 1 (34 lines)
- **CoD**: 5 + 20 + 3 = 28
- **SM**: 1.0 (정상 PR)
- **WSJF**: (28 / 1) × 1.0 = **28.0**

### PR #1556 - app 모듈 CLAUDE.md 문서 추가 (4일 경과)
- **BV**: 3 (docs 성격)
- **TC**: 20 (3일 이상 경과)
- **RR/OE**: 3 (그 외)
- **Job Duration**: 2 (192 lines)
- **CoD**: 3 + 20 + 3 = 26
- **SM**: 1.0 (정상 PR)
- **WSJF**: (26 / 2) × 1.0 = **13.0**

### PR #86 - Firebase Analytics/Crashlytics 통합 (7일 경과)
- **BV**: 8 (feature)
- **TC**: 20 (3일 이상 경과)
- **RR/OE**: 13 (infra 성격)
- **Job Duration**: 2 (167 lines)
- **CoD**: 8 + 20 + 13 = 41
- **SM**: 1.0 (정상 PR)
- **WSJF**: (41 / 2) × 1.0 = **20.5**

### PR #84 - 화면이동 데이터 전달 방식 개선 (12일 경과)
- **BV**: 13 (fix)
- **TC**: 20 (3일 이상 경과)
- **RR/OE**: 3 (그 외)
- **Job Duration**: 2 (190 lines)
- **CoD**: 13 + 20 + 3 = 36
- **SM**: 1.0 (정상 PR)
- **WSJF**: (36 / 2) × 1.0 = **18.0**

### PR #1552 - 연속학습 보상 진입 조건 조회 및 로딩 처리 일원화 (15일 경과)
- **BV**: 8 (enhancement 성격)
- **TC**: 20 (3일 이상 경과)
- **RR/OE**: 3 (그 외)
- **Job Duration**: 8 (1435 lines)
- **CoD**: 8 + 20 + 3 = 31
- **SM**: 1.0 (정상 PR)
- **WSJF**: (31 / 8) × 1.0 = **3.9**

### PR #1551 - 연속학습 보상 도입 및 통계 개선 (19일 경과)
- **BV**: 8 (feature)
- **TC**: 20 (3일 이상 경과)
- **RR/OE**: 3 (그 외)
- **Job Duration**: 13 (4352 lines)
- **CoD**: 8 + 20 + 3 = 31
- **SM**: 0.3 (Draft + "Do NOT Merge" 라벨)
- **WSJF**: (31 / 13) × 0.3 = **0.7**

### PR #1525 - 동적 폰트 스케일링 제거 (34일 경과)
- **BV**: 3 (refactor)
- **TC**: 20 (3일 이상 경과)
- **RR/OE**: 3 (그 외)
- **Job Duration**: 3 (426 lines)
- **CoD**: 3 + 20 + 3 = 26
- **SM**: 1.0 (정상 PR)
- **WSJF**: (26 / 3) × 1.0 = **8.7**

## Final Priority Ranking (WSJF 내림차순)

| 순위 | PR | 제목 | WSJF | SM | 근거 |
|------|----|----|------|----|----|
| 1 | #1406 | 보물상자 연타제한 | 28.0 | 1.0 | 오래된 작업, 작은 변경량으로 빠른 리뷰 가능 |
| 2 | #86 | Firebase Analytics/Crashlytics 통합 | 20.5 | 1.0 | Feature + Infrastructure, 적당한 변경량 |
| 3 | #84 | 화면이동 데이터 전달 방식 개선 | 18.0 | 1.0 | Bug fix 성격, 적당한 변경량 |
| 4 | #1556 | app 모듈 CLAUDE.md 문서 추가 | 13.0 | 1.0 | 문서 추가, 낮은 비즈니스 가치 |
| 5 | #1525 | 동적 폰트 스케일링 제거 | 8.7 | 1.0 | Refactor 작업, 중간 변경량 |
| 6 | #1552 | 연속학습 보상 진입 조건 조회 | 3.9 | 1.0 | 대용량 변경으로 리뷰 시간 오래 소요 |
| 7 | #1551 | 연속학습 보상 도입 및 통계 개선 | 0.7 | 0.3 | Draft + "Do NOT Merge"로 SM 대폭 할인 |

## 권장 리뷰 순서

1. **PR #1406**: 가장 높은 WSJF, 빠른 처리 가능
2. **PR #86**: Infrastructure 개선으로 높은 비즈니스 가치
3. **PR #84**: Bug fix 성격으로 중요도 높음
4. **PR #1556**: 문서 작업으로 낮은 리스크
5. **PR #1525**: Refactor 작업, 안정적 진행 가능
6. **PR #1552**: 대용량 변경으로 충분한 시간 할당 필요
7. **PR #1551**: Draft 상태로 최후 순위 (병합 준비되지 않음)