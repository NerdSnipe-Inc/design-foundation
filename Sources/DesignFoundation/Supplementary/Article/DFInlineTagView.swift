import SwiftUI

/// A small decorative label pill, distinct from `DFChip`: no selection, dismiss,
/// or interaction state — purely a static category/tag marker.
public struct DFInlineTagView: View {
    public let text: String

    @Environment(\.dfTheme) private var theme

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(theme.typography.caption.font)
            .foregroundStyle(theme.colors.accent)
            .padding(.horizontal, theme.spacing.xs)
            .padding(.vertical, 2)
            .background(Capsule().fill(theme.colors.accent.opacity(0.15)))
            .accessibilityLabel(text)
    }
}
