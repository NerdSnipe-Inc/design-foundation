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

        // A fill + shadow alone reads as flat on themes where `surface` and the
        // surrounding `background` are nearly identical by design (e.g. `DFTheme.workspace`
        // on macOS: `controlBackgroundColor` vs. `textBackgroundColor`) — the shadow at
        // `shadows.sm`'s 0.08 opacity isn't enough on its own to read as "elevated" there.
        // A hairline border makes the card's edge legible regardless of how close the
        // theme's surface/background tones are; `shadows.md` gives it real depth instead
        // of "a rectangle that happens to be there."
        configuration.content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(theme.colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(theme.colors.border.opacity(0.7), lineWidth: 1)
            )
            .shadow(
                color: theme.shadows.md.color,
                radius: theme.shadows.md.radius,
                x: theme.shadows.md.x,
                y: theme.shadows.md.y
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
        let theme = configuration.theme
        let radius = theme.components.card.cornerRadius ?? theme.radius.lg
        let padding = theme.components.card.padding ?? theme.spacing.lg
        let useGlass = theme.materials.preferLiquidGlass

        let background: AnyShapeStyle = useGlass
            ? AnyShapeStyle(theme.materials.surfaceMaterial)
            : AnyShapeStyle(theme.colors.surface)

        configuration.content
            .padding(padding)
            .background(RoundedRectangle(cornerRadius: radius).fill(background))
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay {
                if useGlass {
                    RoundedRectangle(cornerRadius: radius).stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                }
            }
            .scaleEffect(configuration.isInteractive && configuration.isPressed ? 0.98 : 1.0)
            .animation(theme.animation.fast, value: configuration.isPressed)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}
