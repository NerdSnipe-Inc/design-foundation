import SwiftUI

// MARK: - Configuration

/// Configuration for popover styles. Passed to style.makeBody() to produce styled content.
///
/// Styles should transform the content View and return it styled. Presentation modifiers
/// are applied by SwiftUI's .popover() modifier in the DFPopoverModifier.
///
/// Not Sendable: holds AnyView (main-thread only).
public struct DFPopoverStyleConfiguration {
    public let content: AnyView
    public let theme: DFTheme
}


// MARK: - Protocol

public protocol DFPopoverStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFPopoverStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFPopoverStyle: DFPopoverStyle, @unchecked Sendable {
    private let _makeBody: (DFPopoverStyleConfiguration) -> AnyView

    public init<S: DFPopoverStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFPopoverStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFPopoverStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFPopoverStyle = AnyDFPopoverStyle(DFArrowPopoverStyle())
}

public extension EnvironmentValues {
    var dfPopoverStyle: AnyDFPopoverStyle {
        get { self[DFPopoverStyleKey.self] }
        set { self[DFPopoverStyleKey.self] = newValue }
    }
}

public extension View {
    func dfPopoverStyle<S: DFPopoverStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfPopoverStyle, AnyDFPopoverStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFPopoverStyle where Self == DFArrowPopoverStyle {
    static var arrow: DFArrowPopoverStyle { DFArrowPopoverStyle() }
}
public extension DFPopoverStyle where Self == DFCompactPopoverStyle {
    static var compact: DFCompactPopoverStyle { DFCompactPopoverStyle() }
}

// MARK: - Built-in: Arrow (default)

/// Standard popover with generous padding and themed background.
public struct DFArrowPopoverStyle: DFPopoverStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPopoverStyleConfiguration) -> some View {
        let theme = configuration.theme
        configuration.content
            .padding(theme.spacing.md)
            .frame(minWidth: 180)
            .background(theme.colors.surface)
    }
}

// MARK: - Built-in: Compact

/// Popover with minimal padding — use for icon-only or very short content.
public struct DFCompactPopoverStyle: DFPopoverStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPopoverStyleConfiguration) -> some View {
        let theme = configuration.theme
        configuration.content
            .padding(theme.spacing.sm)
            .background(theme.colors.surface)
    }
}

// MARK: - Convenience static var for glass

@available(iOS 26, macOS 26, *)
public extension DFPopoverStyle where Self == DFGlassPopoverStyle {
    static var glass: DFGlassPopoverStyle { DFGlassPopoverStyle() }
}

// MARK: - Built-in: Glass (iOS/macOS 26+) — Stub for Task 6

@available(iOS 26, macOS 26, *)
public struct DFGlassPopoverStyle: DFPopoverStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPopoverStyleConfiguration) -> some View {
        let theme = configuration.theme
        configuration.content
            .padding(theme.spacing.md)
            .frame(minWidth: 180)
            .background(.regularMaterial)
            .overlay(RoundedRectangle(cornerRadius: theme.radius.md).stroke(Color.white.opacity(0.2), lineWidth: 0.5))
    }
}
