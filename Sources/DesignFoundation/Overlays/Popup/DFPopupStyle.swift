import SwiftUI

// MARK: - Configuration

/// Not Sendable: holds AnyView (main-thread only).
public struct DFPopupStyleConfiguration {
    public let content: AnyView
    public let kind: DFPopupKind
    public let position: DFPopupPosition
    public let theme: DFTheme

    public init(content: AnyView, kind: DFPopupKind, position: DFPopupPosition, theme: DFTheme) {
        self.content = content
        self.kind = kind
        self.position = position
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFPopupStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFPopupStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFPopupStyle: DFPopupStyle, @unchecked Sendable {
    // @unchecked Sendable: _makeBody captures a concrete Sendable style value; never mutated after init.
    private let _makeBody: (DFPopupStyleConfiguration) -> AnyView

    public init<S: DFPopupStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFPopupStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFPopupStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFPopupStyle = AnyDFPopupStyle(DFStandardPopupStyle())
}

public extension EnvironmentValues {
    var dfPopupStyle: AnyDFPopupStyle {
        get { self[DFPopupStyleKey.self] }
        set { self[DFPopupStyleKey.self] = newValue }
    }
}

public extension View {
    func dfPopupStyle<S: DFPopupStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfPopupStyle, AnyDFPopupStyle(style))
    }
}

// MARK: - Convenience static members

public extension DFPopupStyle where Self == DFStandardPopupStyle {
    static var standard: DFStandardPopupStyle { DFStandardPopupStyle() }
}
public extension DFPopupStyle where Self == DFFrostedPopupStyle {
    static var frosted: DFFrostedPopupStyle { DFFrostedPopupStyle() }
}
public extension DFPopupStyle where Self == DFAccentPopupStyle {
    static var accent: DFAccentPopupStyle { DFAccentPopupStyle() }
}
public extension DFPopupStyle where Self == DFGradientPopupStyle {
    static var gradient: DFGradientPopupStyle { DFGradientPopupStyle() }
}
public extension DFPopupStyle where Self == DFInversePopupStyle {
    static var inverse: DFInversePopupStyle { DFInversePopupStyle() }
}
public extension DFPopupStyle where Self == DFOutlinedPopupStyle {
    static var outlined: DFOutlinedPopupStyle { DFOutlinedPopupStyle() }
}
public extension DFPopupStyle where Self == DFTintedPopupStyle {
    static func tinted(_ severity: DFToastSeverity) -> DFTintedPopupStyle { DFTintedPopupStyle(severity: severity) }
}
@available(iOS 26, macOS 26, *)
public extension DFPopupStyle where Self == DFGlassPopupStyle {
    static var glass: DFGlassPopupStyle { DFGlassPopupStyle() }
}

// MARK: - Built-in: Standard (default)

/// Themed elevated surface: hairline border, layered soft shadow, continuous corners.
/// Toasts are flush and bleed under the safe area on their resting edge; center and
/// floater popups are rounded cards; sheets are bottom-anchored with a grabber.
public struct DFStandardPopupStyle: DFPopupStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPopupStyleConfiguration) -> some View {
        let theme = configuration.theme
        DFPopupChrome(configuration: configuration, appearance: DFPopupAppearance(
            fills: [AnyShapeStyle(theme.colors.surfaceElevated)],
            border: theme.colors.border,
            shadows: theme.layeredShadows
        ))
    }
}

// MARK: - Built-in: Frosted

/// Material blur surface with a light rim along the top edge. Works on every OS version.
public struct DFFrostedPopupStyle: DFPopupStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPopupStyleConfiguration) -> some View {
        let theme = configuration.theme
        DFPopupChrome(configuration: configuration, appearance: DFPopupAppearance(
            fills: [AnyShapeStyle(theme.materials.elevatedMaterial), AnyShapeStyle(theme.colors.surfaceElevated.opacity(0.62))],
            rimHighlight: true,
            shadows: [theme.shadows.lg.scaled(0.8)],
            translucent: true
        ))
    }
}

// MARK: - Built-in: Glass (iOS/macOS 26+)

/// Liquid Glass tinted faintly with the theme's primary color. When
/// `theme.materials.preferLiquidGlass` is false it falls back to the frosted appearance.
@available(iOS 26, macOS 26, *)
public struct DFGlassPopupStyle: DFPopupStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPopupStyleConfiguration) -> some View {
        let theme = configuration.theme
        if theme.materials.preferLiquidGlass {
            DFPopupChrome(configuration: configuration, appearance: DFPopupAppearance(
                fills: [],
                border: nil,
                shadows: [],
                glassTint: theme.colors.primary.opacity(0.06),
                usesGlass: true
            ))
        } else {
            DFFrostedPopupStyle().makeBody(configuration: configuration)
        }
    }
}

// MARK: - Built-in: Accent

/// Solid `theme.colors.primary` surface with a colored shadow. Content is drawn in a
/// contrast-adapted foreground, and default `DFButton`s become light-on-color pills.
public struct DFAccentPopupStyle: DFPopupStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPopupStyleConfiguration) -> some View {
        let theme = configuration.theme
        DFPopupChrome(configuration: configuration, appearance: DFPopupAppearance(
            fills: [],
            border: Color.white.opacity(0.16),
            shadows: [],
            onFillColors: [theme.colors.primary],
            glowOpacity: 0.35
        ))
    }
}

// MARK: - Built-in: Gradient

/// Diagonal `primary` to `accent` gradient with a soft colored glow.
public struct DFGradientPopupStyle: DFPopupStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPopupStyleConfiguration) -> some View {
        let theme = configuration.theme
        DFPopupChrome(configuration: configuration, appearance: DFPopupAppearance(
            fills: [],
            border: Color.white.opacity(0.16),
            shadows: [],
            onFillColors: [theme.colors.primary, theme.colors.accent],
            glowOpacity: 0.32
        ))
    }
}

// MARK: - Built-in: Inverse

/// High-contrast surface: `textPrimary` background with `background` text, like a
/// native dark pill in light mode and a light pill in dark mode.
public struct DFInversePopupStyle: DFPopupStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPopupStyleConfiguration) -> some View {
        let theme = configuration.theme
        DFPopupChrome(configuration: configuration, appearance: DFPopupAppearance(
            fills: [AnyShapeStyle(theme.colors.textPrimary)],
            border: theme.colors.background.opacity(0.12),
            shadows: theme.layeredShadows,
            explicitForeground: theme.colors.background
        ))
    }
}

// MARK: - Built-in: Outlined

/// Near-transparent surface with a 1.5 pt theme border and a whisper of shadow.
public struct DFOutlinedPopupStyle: DFPopupStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPopupStyleConfiguration) -> some View {
        let theme = configuration.theme
        DFPopupChrome(configuration: configuration, appearance: DFPopupAppearance(
            fills: [AnyShapeStyle(theme.colors.background.opacity(0.9))],
            border: theme.colors.primary.opacity(0.55),
            borderWidth: 1.5,
            shadows: [theme.shadows.sm.scaled(0.6)]
        ))
    }
}

// MARK: - Built-in: Tinted

/// Severity-tinted surface: the theme's semantic color at low opacity over the
/// elevated surface, with a stronger border and severity-colored tint for content.
public struct DFTintedPopupStyle: DFPopupStyle, Sendable {
    public let severity: DFToastSeverity

    public init(severity: DFToastSeverity = .info) {
        self.severity = severity
    }

    public func makeBody(configuration: DFPopupStyleConfiguration) -> some View {
        let theme = configuration.theme
        let color = severity.color(in: theme)
        DFPopupChrome(configuration: configuration, appearance: DFPopupAppearance(
            fills: [AnyShapeStyle(theme.colors.surfaceElevated), AnyShapeStyle(color.opacity(0.10))],
            border: color.opacity(0.45),
            shadows: [theme.shadows.sm, DFShadow(color: color.opacity(0.18), radius: 18, x: 0, y: 8)],
            tint: color
        ))
    }
}
