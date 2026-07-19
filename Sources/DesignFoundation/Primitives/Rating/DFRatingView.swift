import SwiftUI

public struct DFRatingView: View {
    private let value: Double
    private let maxValue: Int
    private let allowsHalfStars: Bool
    private let mode: DFRatingMode

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfRatingViewStyle) private var style

    public init(
        value: Double,
        maxValue: Int = 5,
        allowsHalfStars: Bool = true,
        mode: DFRatingMode = .readOnly
    ) {
        self.value = value
        self.maxValue = maxValue
        self.allowsHalfStars = allowsHalfStars
        self.mode = mode
    }

    public var body: some View {
        let config = DFRatingStyleConfiguration(
            value: value,
            maxValue: maxValue,
            allowsHalfStars: allowsHalfStars,
            mode: mode,
            theme: theme
        )

        switch mode {
        case .readOnly:
            style.makeBody(configuration: config)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Rating")
                .accessibilityValue(accessibilityValueText)

        case .interactive(let onChange):
            style.makeBody(configuration: config)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Rating")
                .accessibilityValue(accessibilityValueText)
                .accessibilityAddTraits(.allowsDirectInteraction)
                .accessibilityAdjustableAction { direction in
                    let step = allowsHalfStars ? 0.5 : 1.0
                    switch direction {
                    case .increment:
                        onChange(min(Double(maxValue), value + step))
                    case .decrement:
                        onChange(max(0, value - step))
                    @unknown default:
                        break
                    }
                }
        }
    }

    private var accessibilityValueText: String {
        "\(formattedValue) out of \(maxValue) stars"
    }

    private var formattedValue: String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}
