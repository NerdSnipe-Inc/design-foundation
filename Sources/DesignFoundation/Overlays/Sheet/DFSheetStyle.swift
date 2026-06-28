import SwiftUI

// MARK: - Configuration

/// Configuration for sheet styles. Passed to style.makeBody() to produce styled content.
///
/// Styles should transform the content View and return it styled. Presentation modifiers
/// (detents, background) are applied by the individual styles in their makeBody methods.
///
/// Not Sendable: holds AnyView (main-thread only).
public struct DFSheetStyleConfiguration {
    public let content: AnyView
    public let theme: DFTheme
}


// MARK: - Protocol

public protocol DFSheetStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFSheetStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFSheetStyle: DFSheetStyle, @unchecked Sendable {
    private let _makeBody: (DFSheetStyleConfiguration) -> AnyView

    public init<S: DFSheetStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFSheetStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFSheetStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFSheetStyle = AnyDFSheetStyle(DFStandardSheetStyle())
}

public extension EnvironmentValues {
    var dfSheetStyle: AnyDFSheetStyle {
        get { self[DFSheetStyleKey.self] }
        set { self[DFSheetStyleKey.self] = newValue }
    }
}

public extension View {
    func dfSheetStyle<S: DFSheetStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfSheetStyle, AnyDFSheetStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFSheetStyle where Self == DFStandardSheetStyle {
    static var standard: DFStandardSheetStyle { DFStandardSheetStyle() }
}
public extension DFSheetStyle where Self == DFCompactSheetStyle {
    static var compact: DFCompactSheetStyle { DFCompactSheetStyle() }
}

// MARK: - Built-in: Standard (default)

/// Standard sheet with medium + large detents and a visible drag indicator.
public struct DFStandardSheetStyle: DFSheetStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFSheetStyleConfiguration) -> some View {
        configuration.content
            .presentationDetents([.medium, .large])
            .presentationBackground(configuration.theme.colors.background)
    }
}

// MARK: - Built-in: Compact

/// Sheet locked to medium detent — use for short content like action lists or filters.
public struct DFCompactSheetStyle: DFSheetStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFSheetStyleConfiguration) -> some View {
        configuration.content
            .presentationDetents([.medium])
            .presentationBackground(configuration.theme.colors.background)
    }
}

// MARK: - Convenience static var for glass

@available(iOS 26, macOS 26, *)
public extension DFSheetStyle where Self == DFGlassSheetStyle {
    static var glass: DFGlassSheetStyle { DFGlassSheetStyle() }
}

// MARK: - Built-in: Glass (iOS/macOS 26+) — Stub for Task 6

@available(iOS 26, macOS 26, *)
public struct DFGlassSheetStyle: DFSheetStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFSheetStyleConfiguration) -> some View {
        configuration.content
    }
}
