#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

CONFIG="${1:-debug}"
BIN_NAME="PromptOnMac"
APP="build/Prompt on Mac.app"

swift build -c "$CONFIG"
BIN="$(swift build -c "$CONFIG" --show-bin-path)/$BIN_NAME"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/$BIN_NAME"
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
codesign --force --sign - "$APP" >/dev/null

echo "$APP"
