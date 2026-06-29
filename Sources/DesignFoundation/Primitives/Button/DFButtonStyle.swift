import SwiftUI

// MARK: - Role

public enum DFButtonRole: String, Sendable, CaseIterable {
    case destructive
    case cancel
}

// MARK: - Configuration

/// Passed to every DFButtonStyle.makeBody — contains all state the style needs.
/// Not Sendable: contains AnyView (main-thread only).
public struct DFButtonStyleConfiguration {
    public let label: AnyView
    public let isPressed: Bool
    public let isDisabled: Bool
    public let role: DFButtonRole?
    public let theme: DFTheme

    public init(
        label: AnyView,
        isPressed: Bool,
        isDisabled: Bool,
        role: DFButtonRole?,
        theme: DFTheme
    ) {
        self.label = label
        self.isPressed = isPressed
        self.isDisabled = isDisabled
        self.role = role
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFButtonStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFButtonStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFButtonStyle: DFButtonStyle, @unchecked Sendable {
    private let _makeBody: (DFButtonStyleConfiguration) -> AnyView

    public init<S: DFButtonStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFButtonStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFButtonStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFButtonStyle = AnyDFButtonStyle(DFFilledButtonStyle())
}

public extension EnvironmentValues {
    var dfButtonStyle: AnyDFButtonStyle {
        get { self[DFButtonStyleKey.self] }
        set { self[DFButtonStyleKey.self] = newValue }
    }
}

public extension View {
    func dfButtonStyle<S: DFButtonStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfButtonStyle, AnyDFButtonStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFButtonStyle where Self == DFFilledButtonStyle {
    static var filled: DFFilledButtonStyle { DFFilledButtonStyle() }
}
public extension DFButtonStyle where Self == DFOutlinedButtonStyle {
    static var outlined: DFOutlinedButtonStyle { DFOutlinedButtonStyle() }
}
public extension DFButtonStyle where Self == DFGhostButtonStyle {
    static var ghost: DFGhostButtonStyle { DFGhostButtonStyle() }
}
public extension DFButtonStyle where Self == DFTintedButtonStyle {
    static var tinted: DFTintedButtonStyle { DFTintedButtonStyle() }
}

// MARK: - Built-in: Filled (default)

public struct DFFilledButtonStyle: DFButtonStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFButtonStyleConfiguration) -> some View {
        let theme = configuration.theme
        let radius = theme.components.button.cornerRadius ?? theme.radius.md
        let hPad = theme.components.button.horizontalPadding ?? theme.spacing.lg
        let vPad = theme.components.button.verticalPadding ?? theme.spacing.md
        let bg = configuration.role == .destructive
            ? theme.colors.destructive
            : theme.colors.interactiveFill

        return configuration.label
            .font((theme.components.button.labelStyle ?? theme.typography.label).font)
            .foregroundStyle(configuration.isDisabled ? theme.colors.textDisabled : .white)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(configuration.isDisabled
                          ? theme.colors.interactiveDisabled
                          : configuration.isPressed ? bg.opacity(0.75) : bg)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(theme.animation.fast, value: configuration.isPressed)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Built-in: Outlined

public struct DFOutlinedButtonStyle: DFButtonStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFButtonStyleConfiguration) -> some View {
        let theme = configuration.theme
        let radius = theme.components.button.cornerRadius ?? theme.radius.md
        let hPad = theme.components.button.horizontalPadding ?? theme.spacing.lg
        let vPad = theme.components.button.verticalPadding ?? theme.spacing.md
        let color = configuration.role == .destructive
            ? theme.colors.destructive
            : theme.colors.primary

        return configuration.label
            .font((theme.components.button.labelStyle ?? theme.typography.label).font)
            .foregroundStyle(configuration.isDisabled ? theme.colors.textDisabled : color)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(configuration.isDisabled ? theme.colors.border : color, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(theme.animation.fast, value: configuration.isPressed)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Built-in: Ghost

public struct DFGhostButtonStyle: DFButtonStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFButtonStyleConfiguration) -> some View {
        let theme = configuration.theme
        let hPad = theme.components.button.horizontalPadding ?? theme.spacing.lg
        let vPad = theme.components.button.verticalPadding ?? theme.spacing.md
        let color = configuration.role == .destructive
            ? theme.colors.destructive
            : theme.colors.primary

        return configuration.label
            .font((theme.components.button.labelStyle ?? theme.typography.label).font)
            .foregroundStyle(configuration.isDisabled ? theme.colors.textDisabled : color)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .opacity(configuration.isPressed ? 0.6 : (configuration.isDisabled ? 0.5 : 1.0))
            .animation(theme.animation.fast, value: configuration.isPressed)
    }
}

// MARK: - Built-in: Tinted

public struct DFTintedButtonStyle: DFButtonStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFButtonStyleConfiguration) -> some View {
        let theme = configuration.theme
        let radius = theme.components.button.cornerRadius ?? theme.radius.md
        let hPad = theme.components.button.horizontalPadding ?? theme.spacing.lg
        let vPad = theme.components.button.verticalPadding ?? theme.spacing.md
        let color = configuration.role == .destructive
            ? theme.colors.destructive
            : theme.colors.primary

        return configuration.label
            .font((theme.components.button.labelStyle ?? theme.typography.label).font)
            .foregroundStyle(configuration.isDisabled ? theme.colors.textDisabled : color)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(configuration.isDisabled
                          ? theme.colors.interactiveDisabled
                          : color.opacity(configuration.isPressed ? 0.25 : 0.15))
            )
            .animation(theme.animation.fast, value: configuration.isPressed)
    }
}

// MARK: - Convenience static var for glass

@available(iOS 26, macOS 26, *)
public extension DFButtonStyle where Self == DFGlassButtonStyle {
    static var glass: DFGlassButtonStyle { DFGlassButtonStyle() }
}

// MARK: - Built-in: Glass (iOS/macOS 26+)

@available(iOS 26, macOS 26, *)
public struct DFGlassButtonStyle: DFButtonStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFButtonStyleConfiguration) -> some View {
        let theme = configuration.theme
        let radius = theme.components.button.cornerRadius ?? theme.radius.md
        let hPad = theme.components.button.horizontalPadding ?? theme.spacing.lg
        let vPad = theme.components.button.verticalPadding ?? theme.spacing.md

        configuration.label
            .font((theme.components.button.labelStyle ?? theme.typography.label).font)
            .foregroundStyle(
                configuration.isDisabled
                    ? theme.colors.textDisabled
                    : theme.colors.textPrimary
            )
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(theme.animation.fast, value: configuration.isPressed)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}
