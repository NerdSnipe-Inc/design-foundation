import SwiftUI

// MARK: - Configuration

/// Configuration for command palette styles. Passed to style.makeBody() to produce styled content.
///
/// Styles should transform the content View (the search field + filtered results list, already
/// built by `DFCommandPalette`) into a floating panel — background, corner radius, shadow, and
/// sizing. Styles should not apply presentation modifiers; the palette's own modifier owns the
/// backdrop and dismissal behavior.
///
/// Not Sendable: holds AnyView (main-thread only).
public struct DFCommandPaletteStyleConfiguration {
    public let content: AnyView
    public let theme: DFTheme
}

// MARK: - Protocol

public protocol DFCommandPaletteStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFCommandPaletteStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFCommandPaletteStyle: DFCommandPaletteStyle, @unchecked Sendable {
    private let _makeBody: (DFCommandPaletteStyleConfiguration) -> AnyView

    public init<S: DFCommandPaletteStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFCommandPaletteStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFCommandPaletteStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFCommandPaletteStyle = AnyDFCommandPaletteStyle(DFStandardCommandPaletteStyle())
}

public extension EnvironmentValues {
    var dfCommandPaletteStyle: AnyDFCommandPaletteStyle {
        get { self[DFCommandPaletteStyleKey.self] }
        set { self[DFCommandPaletteStyleKey.self] = newValue }
    }
}

public extension View {
    func dfCommandPaletteStyle<S: DFCommandPaletteStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfCommandPaletteStyle, AnyDFCommandPaletteStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFCommandPaletteStyle where Self == DFStandardCommandPaletteStyle {
    static var standard: DFStandardCommandPaletteStyle { DFStandardCommandPaletteStyle() }
}

// MARK: - Built-in: Standard (default)

/// Standard command palette: a centered, elevated panel with themed background, corner
/// radius, and shadow.
public struct DFStandardCommandPaletteStyle: DFCommandPaletteStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFCommandPaletteStyleConfiguration) -> some View {
        let theme = configuration.theme
        configuration.content
            .background(theme.colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.lg)
                    .stroke(theme.colors.border, lineWidth: 1)
            )
            .shadow(
                color: theme.shadows.lg.color,
                radius: theme.shadows.lg.radius,
                x: theme.shadows.lg.x,
                y: theme.shadows.lg.y
            )
            .frame(maxWidth: 560)
    }
}
