import SwiftUI

// MARK: - Configuration

public struct DFQuantityStepperStyleConfiguration: Sendable {
    public let value: Int
    public let range: ClosedRange<Int>
    public let isDisabled: Bool
    public let theme: DFTheme
    public let onIncrement: @MainActor @Sendable () -> Void
    public let onDecrement: @MainActor @Sendable () -> Void

    public init(
        value: Int,
        range: ClosedRange<Int>,
        isDisabled: Bool,
        theme: DFTheme,
        onIncrement: @escaping @MainActor @Sendable () -> Void,
        onDecrement: @escaping @MainActor @Sendable () -> Void
    ) {
        self.value = value
        self.range = range
        self.isDisabled = isDisabled
        self.theme = theme
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    public var canIncrement: Bool { value < range.upperBound }
    public var canDecrement: Bool { value > range.lowerBound }
}

// MARK: - Protocol

public protocol DFQuantityStepperStyle {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(configuration: DFQuantityStepperStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFQuantityStepperStyle: DFQuantityStepperStyle, @unchecked Sendable {
    private let _makeBody: @MainActor (DFQuantityStepperStyleConfiguration) -> AnyView

    public init<S: DFQuantityStepperStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    public func makeBody(configuration: DFQuantityStepperStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFQuantityStepperStyleKey: EnvironmentKey {
    static let defaultValue = AnyDFQuantityStepperStyle(DFBorderedQuantityStepperStyle())
}

public extension EnvironmentValues {
    var dfQuantityStepperStyle: AnyDFQuantityStepperStyle {
        get { self[DFQuantityStepperStyleKey.self] }
        set { self[DFQuantityStepperStyleKey.self] = newValue }
    }
}

public extension View {
    func dfQuantityStepperStyle<S: DFQuantityStepperStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfQuantityStepperStyle, AnyDFQuantityStepperStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFQuantityStepperStyle where Self == DFBorderedQuantityStepperStyle {
    static var bordered: DFBorderedQuantityStepperStyle { DFBorderedQuantityStepperStyle() }
}
public extension DFQuantityStepperStyle where Self == DFCompactQuantityStepperStyle {
    static var compact: DFCompactQuantityStepperStyle { DFCompactQuantityStepperStyle() }
}

// MARK: - Built-in: Bordered (default)

public struct DFBorderedQuantityStepperStyle: DFQuantityStepperStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFQuantityStepperStyleConfiguration) -> some View {
        let theme = configuration.theme
        let cornerRadius = theme.components.quantityStepper.cornerRadius ?? theme.radius.full
        let buttonSize = theme.components.quantityStepper.buttonSize ?? 28

        HStack(spacing: 0) {
            Button(action: configuration.onDecrement) {
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: buttonSize, height: buttonSize)
            }
            .buttonStyle(.plain)
            .disabled(configuration.isDisabled || !configuration.canDecrement)

            Text("\(configuration.value)")
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.textPrimary)
                .frame(minWidth: buttonSize, alignment: .center)

            Button(action: configuration.onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: buttonSize, height: buttonSize)
            }
            .buttonStyle(.plain)
            .disabled(configuration.isDisabled || !configuration.canIncrement)
        }
        .foregroundStyle(theme.colors.textPrimary)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Built-in: Compact

public struct DFCompactQuantityStepperStyle: DFQuantityStepperStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFQuantityStepperStyleConfiguration) -> some View {
        let theme = configuration.theme
        let buttonSize = theme.components.quantityStepper.buttonSize ?? 24

        HStack(spacing: theme.spacing.sm) {
            Button(action: configuration.onDecrement) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: buttonSize))
                    .foregroundStyle(configuration.canDecrement ? theme.colors.primary : theme.colors.border)
            }
            .buttonStyle(.plain)
            .disabled(configuration.isDisabled || !configuration.canDecrement)

            Text("\(configuration.value)")
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.textPrimary)
                .monospacedDigit()

            Button(action: configuration.onIncrement) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: buttonSize))
                    .foregroundStyle(configuration.canIncrement ? theme.colors.primary : theme.colors.border)
            }
            .buttonStyle(.plain)
            .disabled(configuration.isDisabled || !configuration.canIncrement)
        }
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}
