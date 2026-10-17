#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."
./scripts/build-app.sh "${1:-debug}"
open "build/Prompt on Mac.app"
