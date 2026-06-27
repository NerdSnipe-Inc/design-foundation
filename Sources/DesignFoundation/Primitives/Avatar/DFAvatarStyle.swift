import SwiftUI

// MARK: - Source

public enum DFAvatarSource: Sendable {
    case image(Image)
    case initials(String)
}

// MARK: - Presence

public enum DFAvatarPresence: String, Sendable, CaseIterable {
    case none
    case online
    case away
    case busy
}

// MARK: - Configuration

public struct DFAvatarStyleConfiguration: Sendable {
    public let source: DFAvatarSource
    public let size: CGFloat
    public let presence: DFAvatarPresence
    public let theme: DFTheme

    public init(
        source: DFAvatarSource,
        size: CGFloat,
        presence: DFAvatarPresence,
        theme: DFTheme
    ) {
        self.source = source
        self.size = size
        self.presence = presence
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFAvatarStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFAvatarStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFAvatarStyle: DFAvatarStyle, @unchecked Sendable {
    private let _makeBody: (DFAvatarStyleConfiguration) -> AnyView

    public init<S: DFAvatarStyle>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFAvatarStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFAvatarStyleKey: EnvironmentKey {
    static let defaultValue = AnyDFAvatarStyle(DFCircleAvatarStyle())
}

public extension EnvironmentValues {
    var dfAvatarStyle: AnyDFAvatarStyle {
        get { self[DFAvatarStyleKey.self] }
        set { self[DFAvatarStyleKey.self] = newValue }
    }
}

public extension View {
    func dfAvatarStyle<S: DFAvatarStyle>(_ style: S) -> some View {
        environment(\.dfAvatarStyle, AnyDFAvatarStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFAvatarStyle where Self == DFCircleAvatarStyle {
    static var circle: DFCircleAvatarStyle { DFCircleAvatarStyle() }
}
public extension DFAvatarStyle where Self == DFRoundedAvatarStyle {
    static var rounded: DFRoundedAvatarStyle { DFRoundedAvatarStyle() }
}
public extension DFAvatarStyle where Self == DFRingAvatarStyle {
    static var ring: DFRingAvatarStyle { DFRingAvatarStyle() }
}

// MARK: - Helper: presence ring color

private func presenceColor(_ presence: DFAvatarPresence, theme: DFTheme) -> Color? {
    switch presence {
    case .none:   return nil
    case .online: return theme.colors.success
    case .away:   return theme.colors.warning
    case .busy:   return theme.colors.destructive
    }
}

// MARK: - Helper: avatar content

private func avatarContent(source: DFAvatarSource, size: CGFloat, theme: DFTheme) -> some View {
    Group {
        switch source {
        case .image(let img):
            img.resizable().scaledToFill()
        case .initials(let text):
            ZStack {
                Rectangle().fill(theme.colors.primary.opacity(0.15))
                Text(text.prefix(2).uppercased())
                    .font(.system(size: size * 0.35, weight: .semibold))
                    .foregroundStyle(theme.colors.primary)
            }
        }
    }
    .frame(width: size, height: size)
}

// MARK: - Built-in: Circle (default)

public struct DFCircleAvatarStyle: DFAvatarStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFAvatarStyleConfiguration) -> some View {
        let size = configuration.theme.components.avatar.defaultSize ?? configuration.size
        ZStack(alignment: .bottomTrailing) {
            avatarContent(source: configuration.source, size: size, theme: configuration.theme)
                .clipShape(Circle())
            if let color = presenceColor(configuration.presence, theme: configuration.theme) {
                Circle()
                    .fill(color)
                    .frame(width: size * 0.25, height: size * 0.25)
                    .overlay(Circle().stroke(configuration.theme.colors.background, lineWidth: 1.5))
                    .offset(x: 2, y: 2)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Built-in: Rounded

public struct DFRoundedAvatarStyle: DFAvatarStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFAvatarStyleConfiguration) -> some View {
        let size = configuration.theme.components.avatar.defaultSize ?? configuration.size
        let radius = configuration.theme.radius.md
        ZStack(alignment: .bottomTrailing) {
            avatarContent(source: configuration.source, size: size, theme: configuration.theme)
                .clipShape(RoundedRectangle(cornerRadius: radius))
            if let color = presenceColor(configuration.presence, theme: configuration.theme) {
                Circle()
                    .fill(color)
                    .frame(width: size * 0.25, height: size * 0.25)
                    .overlay(Circle().stroke(configuration.theme.colors.background, lineWidth: 1.5))
                    .offset(x: 2, y: 2)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Built-in: Ring

public struct DFRingAvatarStyle: DFAvatarStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFAvatarStyleConfiguration) -> some View {
        let size = configuration.theme.components.avatar.defaultSize ?? configuration.size
        let borderWidth = configuration.theme.components.avatar.borderWidth ?? 2
        avatarContent(source: configuration.source, size: size, theme: configuration.theme)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(configuration.theme.colors.primary, lineWidth: borderWidth)
            )
            .frame(width: size, height: size)
    }
}

// MARK: - Convenience static var for glass

@available(iOS 26, macOS 26, *)
public extension DFAvatarStyle where Self == DFGlassAvatarStyle {
    static var glass: DFGlassAvatarStyle { DFGlassAvatarStyle() }
}

// MARK: - Built-in: Glass (iOS/macOS 26+)

@available(iOS 26, macOS 26, *)
public struct DFGlassAvatarStyle: DFAvatarStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFAvatarStyleConfiguration) -> some View {
        let size = configuration.theme.components.avatar.defaultSize ?? configuration.size
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)
            avatarContent(source: configuration.source, size: size - 4, theme: configuration.theme)
                .clipShape(Circle())
        }
        .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 0.5))
        .frame(width: size, height: size)
    }
}
