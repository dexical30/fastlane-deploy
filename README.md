# app-ci

개인 맥미니를 온프레미스 GitHub Actions self-hosted runner로 운영하기 위해
Expo/EAS 앱 배포용 Fastlane 설정을 정리한 저장소입니다.
`APP_DIR`로 클론된 앱 경로를 주입받아 iOS/Android 빌드 및 배포를 수행합니다.

## 구성 요약

- Fastlane 경로는 `APP_DIR` 기준으로 통일
- Credentials 경로는 `/opt/developer/app-ci/credentials`로 고정
- 앱 식별 변수는 `APP_IDENTIFIER`, `APP_NAME`, `APP_SCHEME`로 통일
- Apple 팀 ID 변수는 `APPLE_TEAM_ID` 사용
- Android 배포 전 keystore 존재 확인 (`credentials/androidkey/{APP_IDENTIFIER}.jks`)

## 디렉토리 구조

```
/opt/developer/app-ci
├── credentials
│   ├── app-store-connect.p8
│   ├── match/
│   ├── playstore.json
│   └── androidkey/
│       └── {APP_IDENTIFIER}.jks
├── fastlane/
├── ci.env
└── ci.env.template
```

## Credentials 요구사항

- `credentials/playstore.json` (Google Play 서비스 계정 키)
- `credentials/app-store-connect.p8` (App Store Connect API 키)
- `match`는 S3를 사용하므로 S3 접근 권한이 있는 IAM 사용자/키가 필요합니다.

## 환경 변수

### GitHub Secrets로 주입

- `APP_DIR` (클론된 앱 루트 경로)
- `APP_IDENTIFIER`
- `APP_NAME`
- `APP_SCHEME`

### ci.env(온프레미스)로 관리

- `APPLE_TEAM_ID`
- `FASTLANE_APPLE_ID`
- `APPLE_STORE_CONNECT_API_KEY_ID`
- `APPLE_STORE_CONNECT_API_KEY_ISSUER_ID`
- `APPLE_STORE_CONNECT_API_KEY_PATH` (기본: `/opt/developer/app-ci/credentials/app-store-connect.p8`)
- `MATCH_S3_BUCKET_NAME`
- `MATCH_S3_ACCESS_KEY_ID`
- `MATCH_S3_SECRET_ACCESS_KEY`
- `MATCH_KEYCHAIN_PASSWORD` (선택)
- `FASTLANE_SLACK_WEBHOOK` (선택)
- `ANDROID_RELEASE_STATUS` (선택, 기본: `draft`)

`ci.env` 예시는 `ci.env.template`를 참고하세요.

## 배포

Fastlane 실행 전 `ci.env`를 로드하고 필요한 환경변수를 설정합니다.

### iOS TestFlight 배포

```
source ci.env
bundle exec fastlane ios beta
```

### Android 내부 테스트 배포

```
source ci.env
bundle exec fastlane android beta
```

### App Store Connect 앱 생성(없을 경우)

```
source ci.env
bundle exec fastlane ios setup_appstore
```

## Scripts

- `scripts/generate-android-key.sh`: 환경변수를 참조해 Android keystore 생성
- `scripts/source-env.sh`: 실행 위치의 `.env`와 `.ci`를 읽어 터미널 세션에 환경변수 추가
- `scripts/deploy.sh`: `prebuild` → `fastlane ios` → `fastlane android` 순으로 실행

## 참고

- iOS 인증서/프로비저닝은 `match`를 사용하며, 프로파일은 `credentials/match/` 경로를 사용합니다.
- Android keystore가 없으면 배포가 실패합니다.
