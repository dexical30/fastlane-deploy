#!/usr/bin/env bash
set -euo pipefail

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required env var: ${name}" >&2
    exit 1
  fi
}

require_env "APP_IDENTIFIER"
require_env "ANDROID_KEY_ALIAS"
require_env "ANDROID_KEYSTORE_PASSWORD"
require_env "ANDROID_KEY_PASSWORD"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY_DIR="${BASE_DIR}/credentials/androidkey"
KEY_PATH="${KEY_DIR}/${APP_IDENTIFIER}.jks"

if [[ -e "${KEY_PATH}" && "${FORCE:-}" != "1" ]]; then
  echo "Keystore already exists: ${KEY_PATH}"
  echo "Skipping keystore generation. Set FORCE=1 to overwrite."
  exit 0
fi

mkdir -p "${KEY_DIR}"

KEY_DNAME="${ANDROID_KEY_DNAME:-CN=${APP_IDENTIFIER}, OU=Mobile, O=Company, L=City, S=State, C=KR}"

keytool -genkeypair \
  -alias "${ANDROID_KEY_ALIAS}" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storetype JKS \
  -keystore "${KEY_PATH}" \
  -storepass "${ANDROID_KEYSTORE_PASSWORD}" \
  -keypass "${ANDROID_KEY_PASSWORD}" \
  -dname "${KEY_DNAME}"

echo "Keystore created: ${KEY_PATH}"
