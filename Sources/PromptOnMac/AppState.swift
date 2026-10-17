import SwiftUI
import Observation

enum FontStyle: String, CaseIterable, Identifiable {
    case standard, serif, rounded, mono

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: "Sans"
        case .serif: "Serif"
        case .rounded: "Rounded"
        case .mono: "Mono"
        }
    }

    var design: Font.Design {
        switch self {
        case .standard: .default
        case .serif: .serif
        case .rounded: .rounded
        case .mono: .monospaced
        }
    }
}

enum TextAlign: String, CaseIterable, Identifiable {
    case leading, center, trailing

    var id: String { rawValue }

    var textAlignment: TextAlignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }

    var frameAlignment: Alignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }

    var symbol: String {
        switch self {
        case .leading: "text.alignleft"
        case .center: "text.aligncenter"
        case .trailing: "text.alignright"
        }
    }
}

enum PanelPlacement: String, CaseIterable, Identifiable {
    case left, notch, right

    var id: String { rawValue }

    var title: String {
        switch self {
        case .left: "Left"
        case .notch: "Notch"
        case .right: "Right"
        }
    }
}

@MainActor
@Observable
final class AppState {
    static let shared = AppState()

    private let defaults = UserDefaults.standard

    var script: String { didSet { defaults.set(script, forKey: "script") } }
    var fontStyle: FontStyle { didSet { defaults.set(fontStyle.rawValue, forKey: "fontStyle") } }
    var fontSize: Double { didSet { defaults.set(fontSize, forKey: "fontSize") } }
    var lineSpacing: Double { didSet { defaults.set(lineSpacing, forKey: "lineSpacing") } }
    var alignment: TextAlign { didSet { defaults.set(alignment.rawValue, forKey: "alignment") } }
    var panelWidth: Double { didSet { defaults.set(panelWidth, forKey: "panelWidth") } }
    var panelHeight: Double { didSet { defaults.set(panelHeight, forKey: "panelHeight") } }
    var placement: PanelPlacement { didSet { defaults.set(placement.rawValue, forKey: "placement") } }
    var screenName: String { didSet { defaults.set(screenName, forKey: "screenName") } }
    var speed: Double { didSet { defaults.set(speed, forKey: "speed") } }
    var pauseOnHover: Bool { didSet { defaults.set(pauseOnHover, forKey: "pauseOnHover") } }
    var loops: Bool { didSet { defaults.set(loops, forKey: "loops") } }
    var hideFromCapture: Bool { didSet { defaults.set(hideFromCapture, forKey: "hideFromCapture") } }

    var isPlaying = false
    var isPanelVisible = true
    var isHovering = false
    var offset: CGFloat = 0
    var contentHeight: CGFloat = 0
    var topInset: CGFloat = 0

    private var timer: Timer?
    private var lastTick: Date?

    private init() {
        script = defaults.string(forKey: "script") ?? AppState.sampleScript
        fontStyle = FontStyle(rawValue: defaults.string(forKey: "fontStyle") ?? "") ?? .standard
        fontSize = defaults.object(forKey: "fontSize") as? Double ?? 20
        lineSpacing = defaults.object(forKey: "lineSpacing") as? Double ?? 4
        alignment = TextAlign(rawValue: defaults.string(forKey: "alignment") ?? "") ?? .leading
        panelWidth = defaults.object(forKey: "panelWidth") as? Double ?? 520
        panelHeight = defaults.object(forKey: "panelHeight") as? Double ?? 140
        placement = PanelPlacement(rawValue: defaults.string(forKey: "placement") ?? "") ?? .notch
        screenName = defaults.string(forKey: "screenName") ?? ""
        speed = defaults.object(forKey: "speed") as? Double ?? 30
        pauseOnHover = defaults.object(forKey: "pauseOnHover") as? Bool ?? true
        loops = defaults.object(forKey: "loops") as? Bool ?? false
        hideFromCapture = defaults.object(forKey: "hideFromCapture") as? Bool ?? true
    }

    func togglePlayback() {
        isPlaying ? pause() : play()
    }

    func play() {
        if offset >= contentHeight { offset = 0 }
        isPanelVisible = true
        isPlaying = true
        lastTick = .now
        timer?.invalidate()
        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func pause() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    func restart() {
        offset = 0
    }

    func toggleVisibility() {
        isPanelVisible.toggle()
        if !isPanelVisible { pause() }
    }

    func adjustSpeed(by delta: Double) {
        speed = min(max(speed + delta, 5), 150)
    }

    func scroll(by delta: CGFloat) {
        offset = min(max(offset + delta, 0), contentHeight)
    }

    private func tick() {
        let now = Date.now
        let elapsed = now.timeIntervalSince(lastTick ?? now)
        lastTick = now
        if pauseOnHover && isHovering { return }
        offset += speed * elapsed
        if offset >= contentHeight {
            if loops {
                offset = 0
            } else {
                offset = contentHeight
                pause()
            }
        }
    }

    private static let sampleScript = """
    [Pause]

    Hi there. [Short Pause] This little window sits right under your camera, so you can read while looking straight into the lens.

    Paste your script on the left, press play, and the text will scroll at the speed you choose.

    Anything inside square brackets, like [Breathe], shows up as a dimmed cue.
    """
}
