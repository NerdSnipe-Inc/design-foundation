import SwiftUI

// MARK: - Configuration

/// Sendable: Binding<Double>: Sendable on iOS 18+, all other fields Sendable.
public struct DFSliderStyleConfiguration: Sendable {
    public let label: String?
    public let value: Binding<Double>
    public let range: ClosedRange<Double>
    public let step: Double?
    public let isDisabled: Bool
    public let theme: DFTheme

    public init(
        label: String?,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double?,
        isDisabled: Bool,
        theme: DFTheme
    ) {
        self.label = label
        self.value = value
        self.range = range
        self.step = step
        self.isDisabled = isDisabled
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFSliderStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFSliderStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFSliderStyle: DFSliderStyle, @unchecked Sendable {
    private let _makeBody: (DFSliderStyleConfiguration) -> AnyView

    public init<S: DFSliderStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFSliderStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFSliderStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFSliderStyle = AnyDFSliderStyle(DFStandardSliderStyle())
}

public extension EnvironmentValues {
    var dfSliderStyle: AnyDFSliderStyle {
        get { self[DFSliderStyleKey.self] }
        set { self[DFSliderStyleKey.self] = newValue }
    }
}

public extension View {
    func dfSliderStyle<S: DFSliderStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfSliderStyle, AnyDFSliderStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFSliderStyle where Self == DFStandardSliderStyle {
    static var standard: DFStandardSliderStyle { DFStandardSliderStyle() }
}
public extension DFSliderStyle where Self == DFLabeledSliderStyle {
    static var labeled: DFLabeledSliderStyle { DFLabeledSliderStyle() }
}

// MARK: - Private helper — builds the correct Slider based on step
// File-level so both DFStandardSliderStyle and future glass style (Task 7) can reference it.

private func nativeSlider(value: Binding<Double>, range: ClosedRange<Double>, step: Double?) -> some View {
    Group {
        if let step {
            Slider(value: value, in: range, step: step)
        } else {
            Slider(value: value, in: range)
        }
    }
}

// MARK: - Built-in: Standard (default)

public struct DFStandardSliderStyle: DFSliderStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFSliderStyleConfiguration) -> some View {
        let theme = configuration.theme
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if let label = configuration.label {
                Text(label)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(
                        configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textSecondary
                    )
            }
            nativeSlider(value: configuration.value, range: configuration.range, step: configuration.step)
                .tint(theme.colors.primary)
                .disabled(configuration.isDisabled)
        }
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Built-in: Labeled (shows min / current / max values)

public struct DFLabeledSliderStyle: DFSliderStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFSliderStyleConfiguration) -> some View {
        let theme = configuration.theme
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if let label = configuration.label {
                HStack {
                    Text(label)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(
                            configuration.isDisabled ? theme.colors.textDisabled : theme.colors.textSecondary
                        )
                    Spacer()
                    Text(String(format: "%.0f", configuration.value.wrappedValue))
                        .font(theme.typography.caption.font)
                        .foregroundStyle(
                            configuration.isDisabled ? theme.colors.textDisabled : theme.colors.primary
                        )
                        .monospacedDigit()
                }
            }
            nativeSlider(value: configuration.value, range: configuration.range, step: configuration.step)
                .tint(theme.colors.primary)
                .disabled(configuration.isDisabled)
            HStack {
                Text(String(format: "%.0f", configuration.range.lowerBound))
                Spacer()
                Text(String(format: "%.0f", configuration.range.upperBound))
            }
            .font(theme.typography.caption.font)
            .foregroundStyle(theme.colors.textDisabled)
        }
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}
