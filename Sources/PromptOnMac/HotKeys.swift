import Carbon
import AppKit

enum Shortcut: CaseIterable, Identifiable {
    case playPause, visibility, restart, faster, slower

    static let modifiers = UInt32(controlKey | optionKey)

    var id: Self { self }

    var title: String {
        switch self {
        case .playPause: "Play / Pause"
        case .visibility: "Show / Hide prompter"
        case .restart: "Back to start"
        case .faster: "Faster"
        case .slower: "Slower"
        }
    }

    var keys: [String] {
        switch self {
        case .playPause: ["⌃", "⌥", "Space"]
        case .visibility: ["⌃", "⌥", "H"]
        case .restart: ["⌃", "⌥", "R"]
        case .faster: ["⌃", "⌥", "↑"]
        case .slower: ["⌃", "⌥", "↓"]
        }
    }

    var keyCode: UInt32 {
        switch self {
        case .playPause: UInt32(kVK_Space)
        case .visibility: UInt32(kVK_ANSI_H)
        case .restart: UInt32(kVK_ANSI_R)
        case .faster: UInt32(kVK_UpArrow)
        case .slower: UInt32(kVK_DownArrow)
        }
    }

    @MainActor
    func perform(on state: AppState) {
        switch self {
        case .playPause: state.togglePlayback()
        case .visibility: state.toggleVisibility()
        case .restart: state.restart()
        case .faster: state.adjustSpeed(by: 5)
        case .slower: state.adjustSpeed(by: -5)
        }
    }
}

@MainActor
final class HotKeys {
    static let shared = HotKeys()

    private var actions: [UInt32: () -> Void] = [:]
    private var refs: [EventHotKeyRef] = []
    private var isInstalled = false

    func register(keyCode: UInt32, modifiers: UInt32, action: @escaping () -> Void) {
        installHandlerIfNeeded()
        let id = UInt32(actions.count + 1)
        actions[id] = action
        var ref: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: OSType(0x54505254), id: id)
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &ref)
        if let ref { refs.append(ref) }
    }

    fileprivate func fire(_ id: UInt32) {
        actions[id]?()
    }

    private func installHandlerIfNeeded() {
        guard !isInstalled else { return }
        isInstalled = true
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, _ in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )
            let id = hotKeyID.id
            MainActor.assumeIsolated { HotKeys.shared.fire(id) }
            return noErr
        }, 1, &spec, nil, nil)
    }
}
