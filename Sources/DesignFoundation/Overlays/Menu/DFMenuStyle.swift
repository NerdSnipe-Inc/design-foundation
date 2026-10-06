import SwiftUI

// MARK: - Configuration

/// Configuration for menu styles. Passed to style.makeBody() to produce the menu panel.
///
/// `content` is the already-built list of sections and item rows. Styles draw the panel around it
/// (padding, background, material). They must not apply presentation modifiers; `DFMenu` owns the
/// popover, dismissal and keyboard handling.
///
/// Not Sendable: holds AnyView (main-thread only).
public struct DFMenuStyleConfiguration {
    public let content: AnyView
    public let theme: DFTheme
}

// MARK: - Protocol

public protocol DFMenuStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFMenuStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFMenuStyle: DFMenuStyle, @unchecked Sendable {
    private let _makeBody: (DFMenuStyleConfiguration) -> AnyView

    public init<S: DFMenuStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFMenuStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFMenuStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFMenuStyle = AnyDFMenuStyle(DFStandardMenuStyle())
}

public extension EnvironmentValues {
    var dfMenuStyle: AnyDFMenuStyle {
        get { self[DFMenuStyleKey.self] }
        set { self[DFMenuStyleKey.self] = newValue }
    }
}

public extension View {
    func dfMenuStyle<S: DFMenuStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfMenuStyle, AnyDFMenuStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFMenuStyle where Self == DFStandardMenuStyle {
    static var standard: DFStandardMenuStyle { DFStandardMenuStyle() }
}
public extension DFMenuStyle where Self == DFCompactMenuStyle {
    static var compact: DFCompactMenuStyle { DFCompactMenuStyle() }
}

// MARK: - Built-in: Standard (default)

/// Themed panel with comfortable padding on `theme.colors.surfaceElevated`.
public struct DFStandardMenuStyle: DFMenuStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFMenuStyleConfiguration) -> some View {
        let theme = configuration.theme
        configuration.content
            .padding(.vertical, theme.spacing.xs)
            .frame(minWidth: 220)
            .background(theme.colors.surfaceElevated)
    }
}

// MARK: - Built-in: Compact

/// Narrower panel with no vertical padding. Row height on iOS stays at the 44pt minimum.
public struct DFCompactMenuStyle: DFMenuStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFMenuStyleConfiguration) -> some View {
        let theme = configuration.theme
        configuration.content
            .frame(minWidth: 160)
            .background(theme.colors.surfaceElevated)
    }
}

// MARK: - Convenience static var for glass

@available(iOS 26, macOS 26, *)
public extension DFMenuStyle where Self == DFGlassMenuStyle {
    static var glass: DFGlassMenuStyle { DFGlassMenuStyle() }
}

// MARK: - Built-in: Glass (iOS/macOS 26+)

/// Liquid Glass panel. When `theme.materials.preferLiquidGlass` is false, or when built with an
/// SDK older than iOS/macOS 26, it falls back to the theme's elevated surface color.
@available(iOS 26, macOS 26, *)
public struct DFGlassMenuStyle: DFMenuStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFMenuStyleConfiguration) -> some View {
        let theme = configuration.theme
        #if compiler(>=6.2)
        if theme.materials.preferLiquidGlass {
            configuration.content
                .padding(.vertical, theme.spacing.xs)
                .frame(minWidth: 220)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: theme.radius.md))
        } else {
            configuration.content
                .padding(.vertical, theme.spacing.xs)
                .frame(minWidth: 220)
                .background(theme.colors.surfaceElevated)
        }
        #else
        configuration.content
            .padding(.vertical, theme.spacing.xs)
            .frame(minWidth: 220)
            .background(theme.colors.surfaceElevated)
        #endif
    }
}
