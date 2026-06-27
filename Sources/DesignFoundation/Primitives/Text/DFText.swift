import SwiftUI

public struct DFText: View {
    private let content: String
    private let scale: DFTextScale

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfTextViewStyle) private var style

    public init(_ content: String, scale: DFTextScale = .body) {
        self.content = content
        self.scale = scale
    }

    public var body: some View {
        let config = DFTextViewStyleConfiguration(
            content: content,
            scale: scale,
            isDisabled: !isEnabled,
            theme: theme
        )
        style.makeBody(configuration: config)
            .accessibilityLabel(content)
    }
}
