import SwiftUI

// MARK: - Display mode

/// Controls whether the navigation bar uses a large title, inline title, or system default.
public enum DFNavigationBarDisplayMode: Sendable, Equatable {
    case automatic
    case large
    case inline
}

// MARK: - Configuration

/// Not Sendable: holds AnyView (main-thread only).
public struct DFNavigationBarStyleConfiguration {
    public let content: AnyView
    public let theme: DFTheme

    public init(content: AnyView, theme: DFTheme) {
        self.content = content
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFNavigationBarStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFNavigationBarStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFNavigationBarStyle: DFNavigationBarStyle, @unchecked Sendable {
    private let _makeBody: (DFNavigationBarStyleConfiguration) -> AnyView

    public init<S: DFNavigationBarStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFNavigationBarStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFNavigationBarStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFNavigationBarStyle = AnyDFNavigationBarStyle(DFStandardNavigationBarStyle())
}

public extension EnvironmentValues {
    var dfNavigationBarStyle: AnyDFNavigationBarStyle {
        get { self[DFNavigationBarStyleKey.self] }
        set { self[DFNavigationBarStyleKey.self] = newValue }
    }
}

public extension View {
    func dfNavigationBarStyle<S: DFNavigationBarStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfNavigationBarStyle, AnyDFNavigationBarStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFNavigationBarStyle where Self == DFStandardNavigationBarStyle {
    static var standard: DFStandardNavigationBarStyle { DFStandardNavigationBarStyle() }
}
public extension DFNavigationBarStyle where Self == DFTransparentNavigationBarStyle {
    static var transparent: DFTransparentNavigationBarStyle { DFTransparentNavigationBarStyle() }
}

// MARK: - Built-in: Standard (default)

/// Navigation bar with an opaque background using the theme surface color.
public struct DFStandardNavigationBarStyle: DFNavigationBarStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFNavigationBarStyleConfiguration) -> some View {
        #if os(iOS) || os(visionOS)
        configuration.content
            .toolbarBackground(configuration.theme.colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        #else
        configuration.content
            .toolbarBackground(configuration.theme.colors.surface, for: .windowToolbar)
        #endif
    }
}

// MARK: - Built-in: Transparent

/// Navigation bar with hidden background — content scrolls beneath it.
public struct DFTransparentNavigationBarStyle: DFNavigationBarStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFNavigationBarStyleConfiguration) -> some View {
        #if os(iOS) || os(visionOS)
        configuration.content
            .toolbarBackground(.hidden, for: .navigationBar)
        #else
        configuration.content
        #endif
    }
}

// MARK: - Convenience static var for glass

@available(iOS 26, macOS 26, *)
public extension DFNavigationBarStyle where Self == DFGlassNavigationBarStyle {
    static var glass: DFGlassNavigationBarStyle { DFGlassNavigationBarStyle() }
}

// MARK: - Built-in: Glass (iOS/macOS 26+)

@available(iOS 26, macOS 26, *)
public struct DFGlassNavigationBarStyle: DFNavigationBarStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFNavigationBarStyleConfiguration) -> some View {
        #if os(iOS) || os(visionOS)
        configuration.content
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        #else
        configuration.content
            .toolbarBackground(.regularMaterial, for: .windowToolbar)
        #endif
    }
}
