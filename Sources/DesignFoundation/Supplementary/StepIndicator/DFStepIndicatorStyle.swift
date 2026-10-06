import SwiftUI

// MARK: - Configuration
// IS Sendable: holds [DFStep] (Sendable), [DFStepState] (Sendable), Axis, Bool, DFTheme (Sendable).

public struct DFStepIndicatorStyleConfiguration: Sendable {
    public let steps: [DFStep]
    /// One resolved state per step, in the same order as `steps`.
    public let states: [DFStepState]
    public let axis: Axis
    /// True when DFStepIndicator fell back to its numbers-only horizontal layout because the titles do not fit.
    public let isCompact: Bool
    public let theme: DFTheme

    public init(steps: [DFStep], states: [DFStepState], axis: Axis, isCompact: Bool, theme: DFTheme) {
        self.steps = steps
        self.states = states
        self.axis = axis
        self.isCompact = isCompact
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFStepIndicatorStyle {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(configuration: DFStepIndicatorStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFStepIndicatorStyle: DFStepIndicatorStyle, @unchecked Sendable {
    // @unchecked Sendable: _makeBody captures a concrete Sendable style value; internal storage is never mutated after init.
    private let _makeBody: @MainActor (DFStepIndicatorStyleConfiguration) -> AnyView

    public init<S: DFStepIndicatorStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    public func makeBody(configuration: DFStepIndicatorStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFStepIndicatorStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFStepIndicatorStyle = AnyDFStepIndicatorStyle(DFStandardStepIndicatorStyle())
}

public extension EnvironmentValues {
    var dfStepIndicatorStyle: AnyDFStepIndicatorStyle {
        get { self[DFStepIndicatorStyleKey.self] }
        set { self[DFStepIndicatorStyleKey.self] = newValue }
    }
}

public extension View {
    func dfStepIndicatorStyle<S: DFStepIndicatorStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfStepIndicatorStyle, AnyDFStepIndicatorStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFStepIndicatorStyle where Self == DFStandardStepIndicatorStyle {
    static var standard: DFStandardStepIndicatorStyle { DFStandardStepIndicatorStyle() }
}

public extension DFStepIndicatorStyle where Self == DFMinimalStepIndicatorStyle {
    static var minimal: DFMinimalStepIndicatorStyle { DFMinimalStepIndicatorStyle() }
}

public extension DFStepIndicatorStyle where Self == DFNumberedStepIndicatorStyle {
    static var numbered: DFNumberedStepIndicatorStyle { DFNumberedStepIndicatorStyle() }
}

// MARK: - Built-in: Standard (filled circles)

public struct DFStandardStepIndicatorStyle: DFStepIndicatorStyle, Sendable {
    public init() {}

    @MainActor
    public func makeBody(configuration: DFStepIndicatorStyleConfiguration) -> some View {
        DFStepIndicatorLayout(
            configuration: configuration,
            kind: .filled,
            markerSize: configuration.theme.components.stepIndicator.markerSize ?? 28
        )
    }
}

// MARK: - Built-in: Minimal (dots + line)

public struct DFMinimalStepIndicatorStyle: DFStepIndicatorStyle, Sendable {
    public init() {}

    @MainActor
    public func makeBody(configuration: DFStepIndicatorStyleConfiguration) -> some View {
        DFStepIndicatorLayout(
            configuration: configuration,
            kind: .dot,
            markerSize: (configuration.theme.components.stepIndicator.markerSize ?? 28) / 2
        )
    }
}

// MARK: - Built-in: Numbered

public struct DFNumberedStepIndicatorStyle: DFStepIndicatorStyle, Sendable {
    public init() {}

    @MainActor
    public func makeBody(configuration: DFStepIndicatorStyleConfiguration) -> some View {
        DFStepIndicatorLayout(
            configuration: configuration,
            kind: .numbered,
            markerSize: configuration.theme.components.stepIndicator.markerSize ?? 28
        )
    }
}
