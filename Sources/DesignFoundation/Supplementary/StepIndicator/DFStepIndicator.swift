import SwiftUI

/// A progress-steps indicator (checkout, onboarding, order tracking). Not to be confused with
/// `DFQuantityStepper`, the +/- number control.
///
/// States come from `currentIndex` (see `DFStepState.resolve(count:currentIndex:errorIndices:)`):
/// earlier steps are complete, the step at `currentIndex` is current, later steps are upcoming.
/// Horizontal layouts collapse to numbers-only markers when the titles do not fit the available width.
public struct DFStepIndicator: View {
    private let steps: [DFStep]
    private let currentIndex: Int
    private let axis: Axis

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfStepIndicatorStyle) private var style

    public init(steps: [DFStep], currentIndex: Int, axis: Axis = .horizontal) {
        self.steps = steps
        self.currentIndex = currentIndex
        self.axis = axis
    }

    public var body: some View {
        let states = DFStepState.resolve(steps: steps, currentIndex: currentIndex)
        Group {
            if axis == .horizontal {
                ViewThatFits(in: .horizontal) {
                    style.makeBody(configuration: configuration(states: states, compact: false))
                    style.makeBody(configuration: configuration(states: states, compact: true))
                }
            } else {
                style.makeBody(configuration: configuration(states: states, compact: false))
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func configuration(states: [DFStepState], compact: Bool) -> DFStepIndicatorStyleConfiguration {
        DFStepIndicatorStyleConfiguration(
            steps: steps,
            states: states,
            axis: axis,
            isCompact: compact,
            theme: theme
        )
    }
}
