#!/usr/bin/env bash

# 환경 변수 로드 (set -a로 자동 export)
set -a

echo "NODE_ENV=$NODE_ENV"
echo "SCHEME=$SCHEME"

RUN_DIR="$(pwd)"
export ENV_FILE_DIR="${RUN_DIR}"

source /opt/app-ci/ci.env
source ".env"
# set +a는 필요하지 않음 (스크립트 종료 시 자동으로 해제됨)

# cat "${APP_DIR}/.env"
echo "$APP_IDENTIFIER"
echo "CI.env is bound: $CI_ENV_READY"
# echo "$APP_DIR"
# echo "$APPLE_STORE_CONNECT_API_KEY_PATH"

echo "Deploying app..."

yarn prebuild

cd /opt/app-ci

fastlane ios beta

fastlane android beta

echo "App deployed successfully"
