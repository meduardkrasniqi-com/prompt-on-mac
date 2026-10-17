import AppKit
import SwiftUI

final class PrompterHostingView: NSHostingView<PrompterView> {
    var onScroll: ((CGFloat) -> Void)?

    override func scrollWheel(with event: NSEvent) {
        onScroll?(-event.scrollingDeltaY)
    }
}

@MainActor
final class PrompterPanelController {
    private let state: AppState
    private let panel: NSPanel

    init(state: AppState) {
        self.state = state
        panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.isMovable = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]

        let host = PrompterHostingView(rootView: PrompterView(state: state))
        host.sizingOptions = []
        host.onScroll = { [weak state] delta in state?.scroll(by: delta) }
        panel.contentView = host

        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.updateLayout() }
        }

        updateLayout()
        observe()
    }

    private func observe() {
        withObservationTracking {
            _ = state.panelWidth
            _ = state.panelHeight
            _ = state.placement
            _ = state.screenName
            _ = state.hideFromCapture
            _ = state.isPanelVisible
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.updateLayout()
                self?.observe()
            }
        }
    }

    private func targetScreen() -> NSScreen? {
        let screens = NSScreen.screens
        if let match = screens.first(where: { $0.localizedName == state.screenName }) {
            return match
        }
        return screens.first(where: { $0.safeAreaInsets.top > 0 }) ?? NSScreen.main ?? screens.first
    }

    private func updateLayout() {
        guard let screen = targetScreen() else { return }
        let inset = screen.safeAreaInsets.top
        state.topInset = inset

        let frame = screen.frame
        let width = min(state.panelWidth, frame.width)
        let height = state.panelHeight + inset
        let x: CGFloat = switch state.placement {
        case .left: frame.minX + 16
        case .notch: frame.midX - width / 2
        case .right: frame.maxX - width - 16
        }

        panel.setFrame(NSRect(x: x, y: frame.maxY - height, width: width, height: height), display: true)
        panel.sharingType = state.hideFromCapture ? .none : .readOnly

        if state.isPanelVisible {
            panel.orderFrontRegardless()
        } else {
            panel.orderOut(nil)
        }
    }
}
