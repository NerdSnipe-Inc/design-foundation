import SwiftUI

/// Named `DFQuantityStepper` (not `DFStepper`) to avoid colliding with SwiftUI's own `Stepper`
/// and to be explicit about its commerce/quantity-editing use case.
public struct DFQuantityStepper: View {
    @Binding private var value: Int
    private let range: ClosedRange<Int>
    private let step: Int

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfQuantityStepperStyle) private var style
    @Environment(\.isEnabled) private var isEnabled

    public init(value: Binding<Int>, range: ClosedRange<Int> = 0...99, step: Int = 1) {
        self._value = value
        self.range = range
        self.step = step
    }

    @MainActor
    public var body: some View {
        let config = DFQuantityStepperStyleConfiguration(
            value: value,
            range: range,
            isDisabled: !isEnabled,
            theme: theme,
            onIncrement: { self.value = min(range.upperBound, value + step) },
            onDecrement: { self.value = max(range.lowerBound, value - step) }
        )
        style.makeBody(configuration: config)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Quantity")
            .accessibilityValue("\(value)")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    self.value = min(range.upperBound, value + step)
                case .decrement:
                    self.value = max(range.lowerBound, value - step)
                @unknown default:
                    break
                }
            }
    }
}
