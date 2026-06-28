import SwiftUI

// MARK: - Configuration

/// Not Sendable: holds AnyView (main-thread only).
public struct DFModalStyleConfiguration {
    public let content: AnyView
    public let theme: DFTheme
}

// MARK: - Protocol

public protocol DFModalStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFModalStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFModalStyle: DFModalStyle, @unchecked Sendable {
    private let _makeBody: (DFModalStyleConfiguration) -> AnyView

    public init<S: DFModalStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFModalStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFModalStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFModalStyle = AnyDFModalStyle(DFStandardModalStyle())
}

public extension EnvironmentValues {
    var dfModalStyle: AnyDFModalStyle {
        get { self[DFModalStyleKey.self] }
        set { self[DFModalStyleKey.self] = newValue }
    }
}

public extension View {
    func dfModalStyle<S: DFModalStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfModalStyle, AnyDFModalStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFModalStyle where Self == DFStandardModalStyle {
    static var standard: DFStandardModalStyle { DFStandardModalStyle() }
}

// MARK: - Built-in: Standard (default)

/// Standard modal: wraps content with the theme background color filling all safe area.
public struct DFStandardModalStyle: DFModalStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFModalStyleConfiguration) -> some View {
        configuration.content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(configuration.theme.colors.background.ignoresSafeArea())
    }
}

// MARK: - Built-in: Glass (iOS/macOS 26+) — Stub for Task 6

@available(iOS 26, macOS 26, *)
public struct DFGlassModalStyle: DFModalStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFModalStyleConfiguration) -> some View {
        configuration.content
    }
}
