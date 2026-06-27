import SwiftUI

public struct DFBadge: View {
    private let variant: DFBadgeVariant

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfBadgeStyle) private var style

    public init(_ variant: DFBadgeVariant) {
        self.variant = variant
    }

    /// Convenience: numeric badge
    public init(count: Int) {
        self.variant = .numeric(count)
    }

    /// Convenience: text badge
    public init(text: String) {
        self.variant = .text(text)
    }

    public var body: some View {
        let config = DFBadgeStyleConfiguration(variant: variant, theme: theme)
        style.makeBody(configuration: config)
            .accessibilityElement()
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits(.isStaticText)
    }

    private var accessibilityLabel: String {
        switch variant {
        case .numeric(let n): return "\(n) notifications"
        case .dot: return "indicator"
        case .text(let s): return s
        }
    }
}
