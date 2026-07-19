import SwiftUI

public struct DFChip: View {
    private let variant: DFChipVariant
    private let isSelected: Bool

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfChipStyle) private var style

    public init(_ variant: DFChipVariant, isSelected: Bool = false) {
        self.variant = variant
        self.isSelected = isSelected
    }

    /// Convenience: plain label chip
    public init(_ text: String) {
        self.variant = .label(text)
        self.isSelected = false
    }

    public var body: some View {
        let config = DFChipStyleConfiguration(variant: variant, isSelected: isSelected, theme: theme)
        style.makeBody(configuration: config)
            .accessibilityElement()
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits(accessibilityTraits)
    }

    private var accessibilityLabel: String {
        switch variant {
        case .label(let text): return text
        case .labelWithIcon(let text, _): return text
        case .dismissible(let text, _): return "\(text), dismiss"
        case .selectable(let text): return text
        }
    }

    private var accessibilityTraits: AccessibilityTraits {
        switch variant {
        case .selectable, .dismissible:
            return isSelected ? [.isButton, .isSelected] : .isButton
        case .label, .labelWithIcon:
            return .isStaticText
        }
    }
}
