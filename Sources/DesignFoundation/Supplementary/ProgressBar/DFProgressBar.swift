import SwiftUI

public struct DFProgressBar: View {
    private let variant: DFProgressBarVariant
    private let value: Double
    private let label: String?

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfProgressBarStyle) private var style

    public init(variant: DFProgressBarVariant = .linear, value: Double = 0.0, label: String? = nil) {
        self.variant = variant
        self.value = value
        self.label = label
    }

    public var body: some View {
        style.makeBody(configuration: DFProgressBarStyleConfiguration(
            variant: variant,
            value: value,
            label: label,
            theme: theme
        ))
        .accessibilityLabel(label ?? "Progress")
        .accessibilityValue(variant == .indeterminate ? "Loading" : "\(Int(max(0, min(1, value)) * 100)) percent")
    }
}
