# 먹록 (Meokrok)

> 하루 먹은 음식을 기록하고 나만의 식습관 루틴을 만드는 Flutter 앱

---

## 프로그램 개요

**먹록**은 매일 먹은 음식을 간편하게 기록하고, 칼로리를 추적해 건강한 식습관 루틴을 형성할 수 있도록 돕는 모바일 앱입니다.  
외부 서버 없이 기기 로컬 DB만으로 동작하므로 인터넷 연결 없이도 사용할 수 있습니다.

---

## 주요 기능

| 기능                 | 설명                                                                              |
| -------------------- | --------------------------------------------------------------------------------- |
| **식사 기록**        | 아침·점심·저녁·간식 단위로 음식명, 양, 칼로리 입력                                |
| **캘린더 뷰**        | 월별 캘린더에서 기록 여부·칼로리 달성 상태를 색상으로 시각화                      |
| **7일 칼로리 차트**  | 최근 1주일 바 차트로 칼로리 추이 확인                                             |
| **일일 분석**        | 목표 칼로리 달성률, 남은 칼로리, 오늘의 피드백 메시지                             |
| **기간 리포트**      | 이번 주 / 이번 달 기록일 수, 평균 칼로리, 목표 달성일, 가장 많이 기록한 식사 유형 |
| **물 섭취 추적**     | 하루 8컵 목표로 물 섭취량 기록                                                    |
| **연속 기록 스트릭** | 연속 기록 일수 표시(🔥)                                                           |
| **회원 인증**        | 회원가입·로그인·프로필 관리 (SHA-256 비밀번호 해시, 로컬 저장)                    |
| **온보딩**           | 최초 실행 시 사용 가이드                                                          |
| **다크/라이트 테마** | 시스템 설정 연동 테마 전환                                                        |

---

## 기술 스택

```
Flutter 3.x (Dart 3.11+)
├── 상태관리   flutter_riverpod 2.x + riverpod_generator
├── 로컬 DB    drift (SQLite) + sqlite3_flutter_libs
├── 라우팅     go_router
├── 차트       fl_chart
├── 캘린더     table_calendar
├── 폰트       google_fonts (Noto Sans KR)
├── 보안       crypto (SHA-256)
└── 기타       shared_preferences, uuid, intl
```

---

## 설치 및 실행

```bash
# 저장소 클론
git clone https://github.com/woovely05/meokro.git
cd meokrok

# 의존성 설치
flutter pub get

# 코드 생성 (Drift & Riverpod)
dart run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run
```

> **요구사항:** Flutter SDK 3.x, Dart 3.11 이상

---

## 프로젝트 구조

```
lib/
├── core/
│   ├── router/        # go_router 라우팅 설정
│   ├── theme/         # 색상 팔레트, 다크/라이트 테마
│   └── widgets/       # 공통 위젯 (버튼, 카드, 텍스트필드, 하단 네비)
├── data/
│   ├── database/      # Drift DB 스키마 및 DAOs
│   ├── models/        # 데이터 모델 (User, MealLog, FoodItem)
│   └── repositories/  # DB 접근 레이어
└── features/
    ├── auth/          # 로그인, 회원가입, 프로필
    ├── home/          # 홈 (캘린더, 주간 차트, 요약)
    ├── meal_log/      # 식사 기록 입력 화면
    ├── analysis/      # 일별 상세 분석
    └── onboarding/    # 온보딩 화면
```

---

## 본인이 구현한 부분

- 전체 UI/UX 설계 및 화면 레이아웃 구성
- Drift 로컬 DB 스키마 설계 및 Repository 패턴 구현
- Riverpod 기반 상태관리 전체 구조 (Provider, Notifier)
- 캘린더 날짜별 칼로리 달성 색상 시각화 로직
- 연속 기록 스트릭 계산, 기간 리포트 집계 로직
- 물 섭취 카운터, 일별 피드백 메시지 생성
- 로컬 회원 인증 (SHA-256 해시, shared_preferences)
- 다크/라이트 테마 시스템 연동

---

## AI 활용 여부 및 활용 범위

| 구분          | 내용                                           |
| ------------- | ---------------------------------------------- |
| **활용 도구** | Claude Code (claude-sonnet-4-6)                |
| **활용 범위** | 코드 리팩토링, 버그 디버깅                     |
| **직접 작성** | 기능 설계, 비즈니스 로직, 화면 구성, DB 스키마 |

AI는 작성된 코드의 품질 개선(리팩토링)과 오류 수정(디버깅) 과정에서 보조 도구로 활용하였으며, 핵심 로직 및 기능 설계는 직접 구현하였습니다.

---

## 라이선스

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
