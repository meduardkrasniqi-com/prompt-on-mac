#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

NAME="Prompt on Mac"
BIN_NAME="PromptOnMac"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' Resources/Info.plist)"
APP="build/$NAME.app"
STAGING="build/dmg"
DMG="build/$BIN_NAME-$VERSION.dmg"

swift build -c release --triple arm64-apple-macosx14.0
swift build -c release --triple x86_64-apple-macosx14.0

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
lipo -create \
    ".build/arm64-apple-macosx/release/$BIN_NAME" \
    ".build/x86_64-apple-macosx/release/$BIN_NAME" \
    -output "$APP/Contents/MacOS/$BIN_NAME"
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
codesign --force --deep --sign - "$APP"

rm -rf "$STAGING" "$DMG"
mkdir -p "$STAGING"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

hdiutil create -volname "$NAME" -srcfolder "$STAGING" -ov -format UDZO "$DMG" >/dev/null
rm -rf "$STAGING"
cp "$DMG" site/

echo "$DMG"
