import SwiftUI

@main
struct PromptOnMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Window("Prompt on Mac", id: "main") {
            MainView(state: AppState.shared)
        }
        .windowToolbarStyle(.unified)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelController: PrompterPanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        let state = AppState.shared
        panelController = PrompterPanelController(state: state)

        for shortcut in Shortcut.allCases {
            HotKeys.shared.register(keyCode: shortcut.keyCode, modifiers: Shortcut.modifiers) {
                shortcut.perform(on: state)
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
