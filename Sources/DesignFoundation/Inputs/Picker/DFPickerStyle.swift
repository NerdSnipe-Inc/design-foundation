import SwiftUI

// MARK: - Configuration

/// Passed to every DFPickerStyle.makeBody.
/// Not Sendable: holds AnyView.
public struct DFPickerStyleConfiguration {
    public let label: String
    /// The native SwiftUI Picker, configured with selection + content but without .pickerStyle().
    /// Styles call `.pickerStyle(...)` on this to set the variant.
    public let content: AnyView
    public let isDisabled: Bool
    public let theme: DFTheme

    public init(label: String, content: AnyView, isDisabled: Bool, theme: DFTheme) {
        self.label = label
        self.content = content
        self.isDisabled = isDisabled
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFPickerStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFPickerStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFPickerStyle: DFPickerStyle, @unchecked Sendable {
    private let _makeBody: (DFPickerStyleConfiguration) -> AnyView

    public init<S: DFPickerStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFPickerStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFPickerStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFPickerStyle = AnyDFPickerStyle(DFMenuPickerStyle())
}

public extension EnvironmentValues {
    var dfPickerStyle: AnyDFPickerStyle {
        get { self[DFPickerStyleKey.self] }
        set { self[DFPickerStyleKey.self] = newValue }
    }
}

public extension View {
    func dfPickerStyle<S: DFPickerStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfPickerStyle, AnyDFPickerStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFPickerStyle where Self == DFSegmentedPickerStyle {
    static var segmented: DFSegmentedPickerStyle { DFSegmentedPickerStyle() }
}
public extension DFPickerStyle where Self == DFMenuPickerStyle {
    static var menu: DFMenuPickerStyle { DFMenuPickerStyle() }
}
public extension DFPickerStyle where Self == DFWheelPickerStyle {
    static var wheel: DFWheelPickerStyle { DFWheelPickerStyle() }
}

// MARK: - Built-in: Segmented

public struct DFSegmentedPickerStyle: DFPickerStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPickerStyleConfiguration) -> some View {
        configuration.content
            .pickerStyle(.segmented)
            .disabled(configuration.isDisabled)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Built-in: Menu (default)

public struct DFMenuPickerStyle: DFPickerStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPickerStyleConfiguration) -> some View {
        configuration.content
            .pickerStyle(.menu)
            .tint(configuration.theme.colors.primary)
            .disabled(configuration.isDisabled)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Built-in: Wheel

public struct DFWheelPickerStyle: DFPickerStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPickerStyleConfiguration) -> some View {
#if os(iOS) || os(watchOS)
        configuration.content
            .pickerStyle(.wheel)
            .disabled(configuration.isDisabled)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
#else
        configuration.content
            .pickerStyle(.menu)
            .disabled(configuration.isDisabled)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
#endif
    }
}
