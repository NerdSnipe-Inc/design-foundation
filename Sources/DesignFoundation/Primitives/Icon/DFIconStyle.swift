import SwiftUI

// MARK: - Source

public enum DFIconSource: Sendable {
    case symbol(String)    // SF Symbol name
    case image(Image)      // Custom image
}

// MARK: - Configuration

public struct DFIconStyleConfiguration: Sendable {
    public let source: DFIconSource
    public let size: CGFloat
    public let isDisabled: Bool
    public let theme: DFTheme

    public init(source: DFIconSource, size: CGFloat, isDisabled: Bool, theme: DFTheme) {
        self.source = source
        self.size = size
        self.isDisabled = isDisabled
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFIconStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFIconStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFIconStyle: DFIconStyle, @unchecked Sendable {
    private let _makeBody: (DFIconStyleConfiguration) -> AnyView

    public init<S: DFIconStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFIconStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFIconStyleKey: EnvironmentKey {
    static let defaultValue = AnyDFIconStyle(DFStandardIconStyle())
}

public extension EnvironmentValues {
    var dfIconStyle: AnyDFIconStyle {
        get { self[DFIconStyleKey.self] }
        set { self[DFIconStyleKey.self] = newValue }
    }
}

public extension View {
    func dfIconStyle<S: DFIconStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfIconStyle, AnyDFIconStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFIconStyle where Self == DFStandardIconStyle {
    static var standard: DFStandardIconStyle { DFStandardIconStyle() }
}
public extension DFIconStyle where Self == DFTintedIconStyle {
    static var tinted: DFTintedIconStyle { DFTintedIconStyle() }
}
public extension DFIconStyle where Self == DFSecondaryIconStyle {
    static var secondary: DFSecondaryIconStyle { DFSecondaryIconStyle() }
}

// MARK: - Helper: resolve source to SwiftUI Image

private func resolveImage(source: DFIconSource, size: CGFloat) -> some View {
    Group {
        switch source {
        case .symbol(let name):
            Image(systemName: name)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        case .image(let image):
            // Caller is responsible for providing a resizable Image; non-resizable assets will not scale correctly
            image
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Built-in: Standard (default)

public struct DFStandardIconStyle: DFIconStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFIconStyleConfiguration) -> some View {
        resolveImage(source: configuration.source, size: configuration.size)
            .foregroundStyle(
                configuration.isDisabled
                    ? configuration.theme.colors.textDisabled
                    : configuration.theme.colors.textPrimary
            )
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Built-in: Tinted

public struct DFTintedIconStyle: DFIconStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFIconStyleConfiguration) -> some View {
        resolveImage(source: configuration.source, size: configuration.size)
            .foregroundStyle(
                configuration.isDisabled
                    ? configuration.theme.colors.textDisabled
                    : configuration.theme.colors.primary
            )
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Built-in: Secondary

public struct DFSecondaryIconStyle: DFIconStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFIconStyleConfiguration) -> some View {
        resolveImage(source: configuration.source, size: configuration.size)
            .foregroundStyle(
                configuration.isDisabled
                    ? configuration.theme.colors.textDisabled
                    : configuration.theme.colors.textSecondary
            )
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}
