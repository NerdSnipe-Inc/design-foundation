import SwiftUI

public struct DFSlider: View {
    private let label: String?
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double?

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfSliderStyle) private var style

    public init(
        _ label: String? = nil,
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...1,
        step: Double? = nil
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
    }

    public var body: some View {
        let config = DFSliderStyleConfiguration(
            label: label,
            value: $value,
            range: range,
            step: step,
            isDisabled: !isEnabled,
            theme: theme
        )
        style.makeBody(configuration: config)
            .accessibilityLabel(label ?? "Slider")
            .accessibilityValue(String(format: "%.0f", value))
    }
}
