import SwiftUI

enum InspectorTab: String, CaseIterable, Identifiable {
    case text, window, playback, keys

    var id: String { rawValue }

    var title: String {
        switch self {
        case .text: "Text"
        case .window: "Window"
        case .playback: "Playback"
        case .keys: "Keys"
        }
    }

    var symbol: String {
        switch self {
        case .text: "textformat"
        case .window: "macwindow"
        case .playback: "gauge.with.dots.needle.33percent"
        case .keys: "command"
        }
    }
}

struct MainView: View {
    @Bindable var state: AppState
    @State private var tab: InspectorTab = .text

    var body: some View {
        HStack(spacing: 0) {
            ScriptEditor(state: state)
            Divider()
            VStack(spacing: 0) {
                TabStrip(selection: $tab)
                    .padding(12)
                Divider()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        switch tab {
                        case .text: TextSettings(state: state)
                        case .window: WindowSettings(state: state)
                        case .playback: PlaybackSettings(state: state)
                        case .keys: KeySettings()
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(width: 310)
            .background(.background.secondary)
        }
        .frame(minWidth: 820, minHeight: 520)
        .navigationTitle("Prompt on Mac")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    state.restart()
                } label: {
                    Label("Back to start", systemImage: "backward.end.fill")
                }
                .help("Back to start")

                Button {
                    state.toggleVisibility()
                } label: {
                    Label(state.isPanelVisible ? "Hide" : "Show", systemImage: state.isPanelVisible ? "eye" : "eye.slash")
                }
                .help(state.isPanelVisible ? "Hide prompter" : "Show prompter")

                Button {
                    state.togglePlayback()
                } label: {
                    Label(state.isPlaying ? "Pause" : "Play", systemImage: state.isPlaying ? "pause.fill" : "play.fill")
                }
                .help(state.isPlaying ? "Pause" : "Play")
            }
        }
    }
}

struct ScriptEditor: View {
    @Bindable var state: AppState

    private var wordCount: Int {
        state.script.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
    }

    private var duration: String {
        let seconds = Int((Double(wordCount) / 150.0 * 60).rounded())
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private var progress: Double {
        guard state.contentHeight > 0 else { return 0 }
        return min(state.offset / state.contentHeight, 1)
    }

    var body: some View {
        VStack(spacing: 0) {
            TextEditor(text: $state.script)
                .font(.system(size: 15))
                .lineSpacing(4)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .controlSize(.mini)
                .padding(.horizontal, 20)

            HStack {
                Text("\(wordCount) words")
                Spacer()
                Text(duration)
            }
            .font(.caption)
            .monospacedDigit()
            .foregroundStyle(.secondary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
}

struct TabStrip: View {
    @Binding var selection: InspectorTab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(InspectorTab.allCases) { tab in
                let isSelected = tab == selection
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 14, weight: .medium))
                            .frame(height: 16)
                        Text(tab.title)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(isSelected ? Color.accentColor.opacity(0.12) : .clear)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct InspectorSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(.tertiary)
            content
        }
    }
}

struct ValueSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(value.rounded())) \(unit)")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .font(.callout)
            Slider(value: $value, in: range)
                .controlSize(.small)
        }
    }
}

struct LabeledToggle: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title).font(.callout)
        }
        .toggleStyle(.switch)
        .controlSize(.small)
    }
}

struct TextSettings: View {
    @Bindable var state: AppState

    var body: some View {
        InspectorSection(title: "Typeface") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(FontStyle.allCases) { style in
                    let isSelected = style == state.fontStyle
                    Button {
                        state.fontStyle = style
                    } label: {
                        VStack(spacing: 3) {
                            Text("Aa")
                                .font(.system(size: 18, weight: .medium, design: style.design))
                            Text(style.title)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 1.5)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }

        InspectorSection(title: "Layout") {
            ValueSlider(title: "Size", value: $state.fontSize, range: 12...48, unit: "pt")
            ValueSlider(title: "Line spacing", value: $state.lineSpacing, range: 0...24, unit: "pt")
            Picker("Alignment", selection: $state.alignment) {
                ForEach(TextAlign.allCases) { align in
                    Image(systemName: align.symbol).tag(align)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }
}

struct WindowSettings: View {
    @Bindable var state: AppState

    var body: some View {
        InspectorSection(title: "Size") {
            ValueSlider(title: "Width", value: $state.panelWidth, range: 280...1000, unit: "px")
            ValueSlider(title: "Height", value: $state.panelHeight, range: 60...480, unit: "px")
        }

        InspectorSection(title: "Position") {
            Picker("Placement", selection: $state.placement) {
                ForEach(PanelPlacement.allCases) { placement in
                    Text(placement.title).tag(placement)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            Picker("Display", selection: $state.screenName) {
                Text("Automatic").tag("")
                ForEach(NSScreen.screens, id: \.localizedName) { screen in
                    Text(screen.localizedName).tag(screen.localizedName)
                }
            }
            .font(.callout)
        }

        InspectorSection(title: "Privacy") {
            LabeledToggle(title: "Hide from screen sharing", isOn: $state.hideFromCapture)
        }
    }
}

struct PlaybackSettings: View {
    @Bindable var state: AppState

    var body: some View {
        InspectorSection(title: "Scrolling") {
            ValueSlider(title: "Speed", value: $state.speed, range: 5...150, unit: "pt/s")
        }

        InspectorSection(title: "Behavior") {
            LabeledToggle(title: "Pause while hovering", isOn: $state.pauseOnHover)
            LabeledToggle(title: "Loop at the end", isOn: $state.loops)
        }
    }
}

struct KeySettings: View {
    var body: some View {
        InspectorSection(title: "Global shortcuts") {
            ForEach(Shortcut.allCases) { shortcut in
                HStack {
                    Text(shortcut.title).font(.callout)
                    Spacer()
                    HStack(spacing: 3) {
                        ForEach(shortcut.keys, id: \.self) { key in
                            Text(key)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .fill(Color.primary.opacity(0.06))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .strokeBorder(Color.primary.opacity(0.12))
                                )
                        }
                    }
                }
            }
        }
    }
}
