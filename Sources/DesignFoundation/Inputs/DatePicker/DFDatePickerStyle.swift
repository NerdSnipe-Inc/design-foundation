import SwiftUI

// MARK: - Configuration

/// Passed to every DFDatePickerStyle.makeBody.
/// Not Sendable: holds AnyView.
public struct DFDatePickerStyleConfiguration {
    public let label: String
    /// The native SwiftUI DatePicker, configured with selection, range, and displayedComponents
    /// but without .datePickerStyle(). Styles apply .datePickerStyle(...) on this view.
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

public protocol DFDatePickerStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFDatePickerStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFDatePickerStyle: DFDatePickerStyle, @unchecked Sendable {
    private let _makeBody: (DFDatePickerStyleConfiguration) -> AnyView

    public init<S: DFDatePickerStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFDatePickerStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFDatePickerStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFDatePickerStyle = AnyDFDatePickerStyle(DFCompactDatePickerStyle())
}

public extension EnvironmentValues {
    var dfDatePickerStyle: AnyDFDatePickerStyle {
        get { self[DFDatePickerStyleKey.self] }
        set { self[DFDatePickerStyleKey.self] = newValue }
    }
}

public extension View {
    func dfDatePickerStyle<S: DFDatePickerStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfDatePickerStyle, AnyDFDatePickerStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFDatePickerStyle where Self == DFCompactDatePickerStyle {
    static var compact: DFCompactDatePickerStyle { DFCompactDatePickerStyle() }
}
public extension DFDatePickerStyle where Self == DFGraphicalDatePickerStyle {
    static var graphical: DFGraphicalDatePickerStyle { DFGraphicalDatePickerStyle() }
}
public extension DFDatePickerStyle where Self == DFWheelDatePickerStyle {
    static var wheel: DFWheelDatePickerStyle { DFWheelDatePickerStyle() }
}

// MARK: - Built-in: Compact (default)

public struct DFCompactDatePickerStyle: DFDatePickerStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFDatePickerStyleConfiguration) -> some View {
        configuration.content
            .datePickerStyle(.compact)
            .tint(configuration.theme.colors.primary)
            .disabled(configuration.isDisabled)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Built-in: Graphical (calendar view)

public struct DFGraphicalDatePickerStyle: DFDatePickerStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFDatePickerStyleConfiguration) -> some View {
        configuration.content
            .datePickerStyle(.graphical)
            .tint(configuration.theme.colors.primary)
            .disabled(configuration.isDisabled)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Built-in: Wheel (iOS/visionOS) — falls back to graphical on macOS

public struct DFWheelDatePickerStyle: DFDatePickerStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFDatePickerStyleConfiguration) -> some View {
#if os(iOS) || os(visionOS)
        configuration.content
            .datePickerStyle(.wheel)
            .tint(configuration.theme.colors.primary)
            .disabled(configuration.isDisabled)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
#else
        configuration.content
            .datePickerStyle(.graphical)
            .tint(configuration.theme.colors.primary)
            .disabled(configuration.isDisabled)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
#endif
    }
}

// MARK: - Convenience static var for glass

@available(iOS 26, macOS 26, *)
public extension DFDatePickerStyle where Self == DFGlassDatePickerStyle {
    static var glass: DFGlassDatePickerStyle { DFGlassDatePickerStyle() }
}

// MARK: - Built-in: Glass (iOS/macOS 26+)

@available(iOS 26, macOS 26, *)
public struct DFGlassDatePickerStyle: DFDatePickerStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFDatePickerStyleConfiguration) -> some View {
        let theme = configuration.theme
        configuration.content
            .datePickerStyle(.compact)
            .tint(.white)
            .disabled(configuration.isDisabled)
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md)
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}
