import SwiftUI

// MARK: - Configuration

/// Not Sendable: holds AnyView (main-thread only).
public struct DFCardStyleConfiguration {
    public let content: AnyView
    public let isPressed: Bool
    public let isDisabled: Bool
    public let isInteractive: Bool
    public let theme: DFTheme

    public init(
        content: AnyView,
        isPressed: Bool,
        isDisabled: Bool,
        isInteractive: Bool,
        theme: DFTheme
    ) {
        self.content = content
        self.isPressed = isPressed
        self.isDisabled = isDisabled
        self.isInteractive = isInteractive
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFCardStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFCardStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFCardStyle: DFCardStyle, @unchecked Sendable {
    private let _makeBody: (DFCardStyleConfiguration) -> AnyView

    public init<S: DFCardStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFCardStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFCardStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFCardStyle = AnyDFCardStyle(DFElevatedCardStyle())
}

public extension EnvironmentValues {
    var dfCardStyle: AnyDFCardStyle {
        get { self[DFCardStyleKey.self] }
        set { self[DFCardStyleKey.self] = newValue }
    }
}

public extension View {
    func dfCardStyle<S: DFCardStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfCardStyle, AnyDFCardStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFCardStyle where Self == DFElevatedCardStyle {
    static var elevated: DFElevatedCardStyle { DFElevatedCardStyle() }
}
public extension DFCardStyle where Self == DFOutlinedCardStyle {
    static var outlined: DFOutlinedCardStyle { DFOutlinedCardStyle() }
}
public extension DFCardStyle where Self == DFFilledCardStyle {
    static var filled: DFFilledCardStyle { DFFilledCardStyle() }
}

// MARK: - Built-in: Elevated (default)

public struct DFElevatedCardStyle: DFCardStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFCardStyleConfiguration) -> some View {
        let theme = configuration.theme
        let radius = theme.components.card.cornerRadius ?? theme.radius.lg
        let padding = theme.components.card.padding ?? theme.spacing.lg

        configuration.content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(theme.colors.surface)
                    .shadow(
                        color: theme.shadows.sm.color,
                        radius: theme.shadows.sm.radius,
                        x: theme.shadows.sm.x,
                        y: theme.shadows.sm.y
                    )
            )
            .scaleEffect(configuration.isInteractive && configuration.isPressed ? 0.98 : 1.0)
            .animation(theme.animation.fast, value: configuration.isPressed)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Built-in: Outlined

public struct DFOutlinedCardStyle: DFCardStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFCardStyleConfiguration) -> some View {
        let theme = configuration.theme
        let radius = theme.components.card.cornerRadius ?? theme.radius.lg
        let padding = theme.components.card.padding ?? theme.spacing.lg

        configuration.content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(theme.colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isInteractive && configuration.isPressed ? 0.98 : 1.0)
            .animation(theme.animation.fast, value: configuration.isPressed)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Built-in: Filled

public struct DFFilledCardStyle: DFCardStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFCardStyleConfiguration) -> some View {
        let theme = configuration.theme
        let radius = theme.components.card.cornerRadius ?? theme.radius.lg
        let padding = theme.components.card.padding ?? theme.spacing.lg

        configuration.content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(theme.colors.surfaceElevated)
            )
            .scaleEffect(configuration.isInteractive && configuration.isPressed ? 0.98 : 1.0)
            .animation(theme.animation.fast, value: configuration.isPressed)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Convenience static var for glass

@available(iOS 26, macOS 26, *)
public extension DFCardStyle where Self == DFGlassCardStyle {
    static var glass: DFGlassCardStyle { DFGlassCardStyle() }
}

// MARK: - Built-in: Glass (iOS/macOS 26+) — Stub for Task 6

@available(iOS 26, macOS 26, *)
public struct DFGlassCardStyle: DFCardStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFCardStyleConfiguration) -> some View {
        configuration.content
    }
}
