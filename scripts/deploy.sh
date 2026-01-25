RUN_DIR="$(pwd)"
export ENV_FILE_DIR="${RUN_DIR}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/source-env.sh"

echo "Deploying app..."

yarn prebuild -y

cd /opt/developer/app-ci

fastlane ios beta

fastlane android beta

echo "App deployed successfully"
