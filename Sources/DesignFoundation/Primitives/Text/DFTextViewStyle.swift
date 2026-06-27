import SwiftUI

// MARK: - Scale

public enum DFTextScale: String, Sendable, CaseIterable {
    case display, title, headline, body, caption, label

    func style(from theme: DFTheme) -> DFTextStyle {
        switch self {
        case .display:  return theme.typography.display
        case .title:    return theme.typography.title
        case .headline: return theme.typography.headline
        case .body:     return theme.typography.body
        case .caption:  return theme.typography.caption
        case .label:    return theme.typography.label
        }
    }
}

// MARK: - Configuration

public struct DFTextViewStyleConfiguration {
    public let content: String
    public let scale: DFTextScale
    public let isDisabled: Bool
    public let theme: DFTheme

    public init(content: String, scale: DFTextScale, isDisabled: Bool, theme: DFTheme) {
        self.content = content
        self.scale = scale
        self.isDisabled = isDisabled
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFTextViewStyle: Sendable {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFTextViewStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFTextViewStyle: DFTextViewStyle {
    private let _makeBody: @Sendable (DFTextViewStyleConfiguration) -> AnyView

    public init<S: DFTextViewStyle>(_ style: S) {
        _makeBody = { @Sendable config in AnyView(style.makeBody(configuration: config)) }
    }

    public func makeBody(configuration: DFTextViewStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFTextViewStyleKey: EnvironmentKey {
    static let defaultValue = AnyDFTextViewStyle(DFStandardTextViewStyle())
}

public extension EnvironmentValues {
    var dfTextViewStyle: AnyDFTextViewStyle {
        get { self[DFTextViewStyleKey.self] }
        set { self[DFTextViewStyleKey.self] = newValue }
    }
}

public extension View {
    func dfTextViewStyle<S: DFTextViewStyle>(_ style: S) -> some View {
        environment(\.dfTextViewStyle, AnyDFTextViewStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFTextViewStyle where Self == DFStandardTextViewStyle {
    static var standard: DFStandardTextViewStyle { DFStandardTextViewStyle() }
}
public extension DFTextViewStyle where Self == DFSecondaryTextViewStyle {
    static var secondary: DFSecondaryTextViewStyle { DFSecondaryTextViewStyle() }
}
public extension DFTextViewStyle where Self == DFMutedTextViewStyle {
    static var muted: DFMutedTextViewStyle { DFMutedTextViewStyle() }
}

// MARK: - Built-in: Standard (default)

public struct DFStandardTextViewStyle: DFTextViewStyle {
    public init() {}

    public func makeBody(configuration: DFTextViewStyleConfiguration) -> some View {
        let textStyle = configuration.scale.style(from: configuration.theme)
        return Text(configuration.content)
            .font(textStyle.font)
            .tracking(textStyle.tracking)
            .lineSpacing(textStyle.lineSpacing)
            .foregroundStyle(
                configuration.isDisabled
                    ? configuration.theme.colors.textDisabled
                    : configuration.theme.colors.textPrimary
            )
    }
}

// MARK: - Built-in: Secondary

public struct DFSecondaryTextViewStyle: DFTextViewStyle {
    public init() {}

    public func makeBody(configuration: DFTextViewStyleConfiguration) -> some View {
        let textStyle = configuration.scale.style(from: configuration.theme)
        return Text(configuration.content)
            .font(textStyle.font)
            .tracking(textStyle.tracking)
            .lineSpacing(textStyle.lineSpacing)
            .foregroundStyle(
                configuration.isDisabled
                    ? configuration.theme.colors.textDisabled
                    : configuration.theme.colors.textSecondary
            )
    }
}

// MARK: - Built-in: Muted

public struct DFMutedTextViewStyle: DFTextViewStyle {
    public init() {}

    public func makeBody(configuration: DFTextViewStyleConfiguration) -> some View {
        let textStyle = configuration.scale.style(from: configuration.theme)
        return Text(configuration.content)
            .font(textStyle.font)
            .tracking(textStyle.tracking)
            .lineSpacing(textStyle.lineSpacing)
            .foregroundStyle(configuration.theme.colors.textDisabled)
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
}
