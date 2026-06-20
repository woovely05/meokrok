# 먹록 🥗

> 하루 먹은 음식을 기록하고, 나만의 식습관 루틴을 만드는 **로컬 우선 식단 다이어리 앱**

외부 서버 없이 기기 로컬 SQLite만으로 동작합니다. 개인 데이터는 기기 밖으로 전송되지 않습니다.

---

## 주요 기능

### 식사 기록
- 아침 / 점심 / 저녁 / 간식 타입별 식사 로그
- 음식명 · 양 · 단위(g, ml, 개, 인분) · 칼로리 · 단백질 · 탄수화물 · 지방 입력
- 이전 날짜 기록 그대로 복사 붙여넣기
- 식사 노트 작성
- 삭제 후 실행 취소(Snackbar Undo)

### AI 칼로리 추정
- 음식명 입력 시 **로컬 LLM(Gemma GGUF · llama.cpp)**으로 칼로리 자동 추정
- 최초 실행 시 스플래시에서 모델 자동 다운로드 (중단 후 이어받기 지원)
- 오프라인 완전 동작 — 개인 데이터 외부 전송 없음
- 다운로드 실패 시 "AI 없이 시작" 우회 가능

### 홈 대시보드
- 오늘의 칼로리 · 단백질 · 탄수화물 · 지방 진행 바
- 월간 달력 — 기록일 색상 표시 (목표 달성 🟢 / 초과 🟠 / 부족 🔵)
- 물 섭취 트래커 (하루 8잔 목표)
- 최근 7일 칼로리 바 차트
- 주간 / 월간 기간 리포트 (기록일 수 · 평균 칼로리 · 목표 달성일 · 주요 식사 유형)
- 연속 기록 스트릭 (🔥)

### 식단 분석
- 총 섭취 칼로리 · 달성률 · 남은 칼로리 / 초과 칼로리
- 섭취량 기반 맞춤 피드백 메시지
- 당일 전체 식사 내역 조회

### 마이페이지
- 신체 정보 편집 (키 · 몸무게 · 나이 · 성별)
- **Mifflin-St Jeor + TDEE 공식**으로 1일 칼로리 목표 자동 계산
- 목표 선택 (체중 감량 / 유지 / 벌크업)
- BMI 계산 및 판정 (저체중 / 정상 / 과체중 / 비만)
- 체중 기록 및 꺾은선 추이 차트
- 라이트 / 다크 모드 즉시 전환

### 계정 · 보안
- 로컬 계정 (외부 인증 서버 없음)
- 비밀번호 SHA-256 해시 저장
- 첫 로그인 후 온보딩 플로우 (신체 정보 입력)

---

## 기술 스택

| 분류 | 기술 |
|---|---|
| 프레임워크 | Flutter 3.x / Dart 3.11+ |
| 상태 관리 | flutter_riverpod 2.x · riverpod_annotation (코드 생성) |
| 로컬 DB | Drift (SQLite) + sqlite3_flutter_libs |
| 로컬 LLM | llamadart (llama.cpp Flutter 바인딩) |
| 라우팅 | go_router |
| 차트 | fl_chart (bar, line) |
| 캘린더 | table_calendar |
| 폰트 | google_fonts (Noto Sans KR) |
| 보안 | crypto (SHA-256) |
| 기타 | intl · shared_preferences · uuid · path_provider |

---

## 아키텍처

```
lib/
├── core/
│   ├── constants/      # AppConstants (매직 넘버 중앙화)
│   ├── router/         # go_router 설정
│   ├── services/       # gemini_service (로컬 LLM), model_downloader
│   ├── theme/          # AppColors (ThemeExtension), AppTheme, ThemeModeProvider
│   ├── utils/          # AppDateFormats, calorie_feedback
│   └── widgets/        # AppButton, AppCard, AppTextField, BottomNav
│
├── data/
│   ├── database/       # Drift AppDatabase + 코드 생성 (스키마 v3)
│   ├── models/         # UserModel, MealLogModel, FoodItemModel
│   └── repositories/   # MealRepository, UserRepository
│
└── features/
    ├── auth/
    │   ├── providers/  # AuthProvider (StateNotifier)
    │   ├── screens/    # SplashScreen, LoginScreen, SignupScreen, ProfileScreen
    │   └── widgets/    # ProfileEditField, ProfileSettingsCard, ProfileWeightCard
    ├── home/
    │   └── screens/    # HomeScreen
    ├── meal_log/
    │   ├── providers/  # 날짜별 식사 · 영양 · 스트릭 · 리포트 Provider
    │   └── screens/    # MealLogScreen
    ├── analysis/
    │   └── screens/    # AnalysisScreen
    └── onboarding/
        └── screens/    # OnboardingScreen
```

**설계 원칙**
- Feature-first 디렉터리 구조로 관심사 분리
- Repository 패턴으로 데이터 레이어 격리
- Riverpod `FutureProvider.family` + `StateNotifier`로 전체 상태 관리
- `AppColors` ThemeExtension으로 라이트/다크 테마 단일 관리
- Dart 3 Records로 타입 안전 AI 결과 반환
  ```dart
  typedef AiResult = ({double? calories, AiEstimateFailure? failure});
  ```

---

## 데이터베이스

| 테이블 | 주요 컬럼 | 추가 버전 |
|---|---|---|
| `users` | id, name, email, passwordHash, gender, height, weight, age, goal | v1 |
| `meal_logs` | id, userId, date, mealType, foodsJson, note | v1 (note: v3) |
| `weight_logs` | id, userId, date, weight | v2 |

모든 데이터는 기기 내 `ApplicationDocumentsDirectory/meokrok.db`에만 저장됩니다.

---

## 시작하기

### 요구 사항

- Flutter SDK 3.x 이상 (`flutter --version`으로 확인)
- Dart SDK 3.11.1 이상
- Android 5.0+ / iOS 12+ 디바이스 또는 에뮬레이터

### 설치 및 실행

```bash
# 저장소 클론
git clone https://github.com/woovely05/meokrok.git
cd meokrok

# 의존성 설치
flutter pub get

# 코드 생성 (Drift 스키마 + Riverpod Provider)
dart run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run
```

### AI 모델 설정 (선택)

앱 최초 실행 시 AI 칼로리 추정 기능을 위한 GGUF 모델(~4 GB)을 스플래시 화면에서 자동 다운로드합니다.

- 네트워크 불안정 시 **"다시 시도"** 버튼으로 이어받기
- 다운로드 없이 앱만 사용하려면 **"AI 없이 시작"** 선택
- 이후 재실행 시 언제든 이어받기 가능

---

## 스크린 플로우

```
SplashScreen (모델 다운로드 + 인증 확인)
    ├─▶ /login        미인증
    │       └─▶ /signup
    └─▶ /onboarding   첫 로그인
            └─▶ /home
                  ├─▶ /meal-log/:date   식사 기록
                  ├─▶ /analysis/:date   식단 분석
                  └─▶ /mypage          마이페이지
```

---

## 라이선스

MIT
