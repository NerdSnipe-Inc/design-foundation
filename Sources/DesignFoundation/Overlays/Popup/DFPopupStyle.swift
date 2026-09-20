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

public extension DFPopupStyle where Self == DFStandardPopupStyle {
    static var standard: DFStandardPopupStyle { DFStandardPopupStyle() }
}

// MARK: - Built-in: Standard (default)

/// Themed elevated surface. Toasts are flush and bleed under the safe area on their
/// resting edge; center and floater popups are rounded cards.
public struct DFStandardPopupStyle: DFPopupStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPopupStyleConfiguration) -> some View {
        let theme = configuration.theme
        let tokens = theme.components.popup
        let padding = tokens.padding ?? theme.spacing.lg
        let radius = tokens.cornerRadius ?? theme.radius.lg
        let shadow = theme.shadows.md

        switch configuration.kind {
        case .toast:
            let bleed: Edge.Set = configuration.position.exitEdge == .top ? .top : .bottom
            configuration.content
                .padding(padding)
                .frame(maxWidth: .infinity)
                .background(
                    theme.colors.surfaceElevated
                        .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
                        .ignoresSafeArea(edges: bleed)
                )
        case .center, .floater:
            configuration.content
                .padding(padding)
                .background(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(theme.colors.surfaceElevated)
                        .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
                )
        }
    }
}
