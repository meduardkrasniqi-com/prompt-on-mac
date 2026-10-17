# Prompt on Mac

A small teleprompter for macOS. Your script hangs from the top of the screen, right under the camera notch, and scrolls at the pace you set. You can read while looking straight into the lens.

## Features

- **Sits under the camera.** A black panel hangs from the top edge of the screen. On MacBooks with a notch, the text starts just below it.
- **Stage cues.** Anything in square brackets, like `[Pause]` or `[Smile]`, shows up dimmed and in italics.
- **Scrolling you control.** Set the speed in points per second, nudge it while you talk, or scroll the panel with the trackpad. Hovering over the text pauses it.
- **Global shortcuts.** Control the prompter while another app is in front.
- **Adjustable layout.** Choose the typeface, size, line spacing and alignment, plus the panel's width, height, position and display.
- **Screen sharing.** The panel asks macOS to keep it out of screen sharing and recordings. Some capture apps ignore that request.

Settings and your script are saved automatically.

## Shortcuts

| Action | Keys |
| --- | --- |
| Play or pause | `⌃ ⌥ Space` |
| Show or hide the prompter | `⌃ ⌥ H` |
| Back to start | `⌃ ⌥ R` |
| Faster | `⌃ ⌥ ↑` |
| Slower | `⌃ ⌥ ↓` |

## Install

Requires macOS 14 or later. Runs on Apple silicon and Intel.

1. Open `PromptOnMac-<version>.dmg` and drag **Prompt on Mac** into Applications.
2. Open the app once. macOS will say it can't verify the developer. Click Done.
3. Go to **System Settings → Privacy & Security**, scroll down and click **Open Anyway**.

The app is not notarized by Apple yet, which is why step 3 is needed. If macOS says the app is damaged, run this and open it again:

```sh
xattr -cr "/Applications/Prompt on Mac.app"
```

## Build from source

You only need the Xcode Command Line Tools (Swift 6). Full Xcode is optional.

```sh
./scripts/run.sh            # debug build, then launch
./scripts/run.sh release    # release build, then launch
```

The app is written to `build/Prompt on Mac.app`.

To build a universal DMG for distribution:

```sh
./scripts/make-dmg.sh
```

This creates `build/PromptOnMac-<version>.dmg` and copies it into `site/`. The version comes from `CFBundleShortVersionString` in `Resources/Info.plist`.

To regenerate the app icon after changing `scripts/make-icon.swift`:

```sh
mkdir -p /tmp/AppIcon.iconset
swift scripts/make-icon.swift /tmp/AppIcon.iconset
iconutil -c icns /tmp/AppIcon.iconset -o Resources/AppIcon.icns
```

## Project layout

```
Package.swift                  Swift package, macOS 14+
Sources/PromptOnMac/
  PromptOnMacApp.swift         App entry point and launch setup
  AppState.swift               Settings, persistence and scrolling
  PrompterPanel.swift          The floating panel under the notch
  PrompterView.swift           Scrolling text and cue formatting
  MainView.swift               Script editor and settings inspector
  HotKeys.swift                Global keyboard shortcuts
Resources/
  Info.plist                   App bundle metadata
  AppIcon.icns                 App icon
scripts/
  build-app.sh                 Build and bundle the .app
  run.sh                       Build and launch
  make-dmg.sh                  Universal release build and DMG
  make-icon.swift              Draws the app icon
site/
  index.html                   Landing page
  favicon.svg                  Favicon
```

## Website

`site/` is a static landing page. Run `./scripts/make-dmg.sh` first so the DMG sits next to `index.html`, then upload the folder to any static host. The DMG is ignored by git, so if you deploy from the repository, attach the DMG to a GitHub release and point the download links there instead.
