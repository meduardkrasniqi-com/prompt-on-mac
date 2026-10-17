import SwiftUI

private struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct PrompterView: View {
    let state: AppState

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20, style: .continuous)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Text(ScriptFormatter.format(state.script))
                .font(.system(size: state.fontSize, weight: .medium, design: state.fontStyle.design))
                .foregroundStyle(.white)
                .lineSpacing(state.lineSpacing)
                .multilineTextAlignment(state.alignment.textAlignment)
                .frame(maxWidth: .infinity, alignment: state.alignment.frameAlignment)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: ContentHeightKey.self, value: proxy.size.height)
                    }
                )
                .offset(y: -state.offset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, state.topInset + 10)
        .clipped()
        .mask(fadeMask)
        .background(shape.fill(.black))
        .clipShape(shape)
        .onPreferenceChange(ContentHeightKey.self) { state.contentHeight = $0 }
        .onHover { state.isHovering = $0 }
    }

    private var fadeMask: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: state.topInset)
            LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                .frame(height: 14)
            Color.black
            LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: 24)
        }
    }
}

enum ScriptFormatter {
    static func format(_ script: String) -> AttributedString {
        var result = AttributedString()
        var rest = script[...]
        while let range = rest.range(of: #"\[[^\]]*\]"#, options: .regularExpression) {
            result += AttributedString(String(rest[..<range.lowerBound]))
            var cue = AttributedString(String(rest[range]))
            cue.foregroundColor = .white.opacity(0.4)
            cue.inlinePresentationIntent = .emphasized
            result += cue
            rest = rest[range.upperBound...]
        }
        result += AttributedString(String(rest))
        return result
    }
}
