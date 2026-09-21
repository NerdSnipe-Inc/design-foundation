import SwiftUI

// MARK: - Severity

public enum DFToastSeverity: Sendable {
    case info
    case success
    case warning
    case error
}

// MARK: - Message

public struct DFToastMessage: Identifiable, Sendable {
    public let id: UUID
    public let text: String
    public let icon: String?
    public let duration: TimeInterval
    public let severity: DFToastSeverity
    public let position: DFPopupPosition
    /// Optional bold headline drawn above `text`.
    public let title: String?
    /// Title of the trailing action button (for example "Undo"). Shown only together with `action`.
    public let actionTitle: String?
    /// Runs when the action button is tapped; the toast dismisses afterwards.
    public let action: (@MainActor @Sendable () -> Void)?

    public init(
        text: String,
        icon: String? = nil,
        duration: TimeInterval = 3.0,
        severity: DFToastSeverity = .info,
        position: DFPopupPosition = .top,
        title: String? = nil,
        actionTitle: String? = nil,
        action: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.id = UUID()
        self.text = text
        self.icon = icon
        self.duration = duration
        self.severity = severity
        self.position = position
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    /// True when both an action title and an action closure are present.
    public var hasAction: Bool { actionTitle != nil && action != nil }
}

// MARK: - Layout

/// How a toast style relates to the screen edges; picks the popup kind that hosts it.
public enum DFToastLayout: Sendable {
    /// A floating pill or card inset from the edges.
    case floating
    /// Full-width and flush with the resting edge, extending under the safe area.
    case flush
}

// MARK: - Configuration
// IS Sendable: holds DFToastMessage (Sendable) and DFTheme (Sendable).

public struct DFToastStyleConfiguration: Sendable {
    public let message: DFToastMessage
    public let theme: DFTheme
    /// Dismisses this toast. A no-op when the configuration is built outside the toast layer.
    public let dismiss: @MainActor @Sendable () -> Void

    public init(
        message: DFToastMessage,
        theme: DFTheme,
        dismiss: @escaping @MainActor @Sendable () -> Void = {}
    ) {
        self.message = message
        self.theme = theme
        self.dismiss = dismiss
    }

    /// Runs the message's action, then dismisses the toast. Call this from an action button.
    @MainActor
    public func performAction() {
        message.action?()
        dismiss()
    }
}

// MARK: - Protocol

public protocol DFToastStyle {
    associatedtype Body: View
    /// Whether the style floats inset from the edges or sits flush against one. Defaults to `.floating`.
    var layout: DFToastLayout { get }
    @ViewBuilder func makeBody(configuration: DFToastStyleConfiguration) -> Body
}

public extension DFToastStyle {
    var layout: DFToastLayout { .floating }
}

// MARK: - Type Erasure

public struct AnyDFToastStyle: DFToastStyle, @unchecked Sendable {
    // @unchecked Sendable: _makeBody captures a concrete Sendable style value; internal storage is never mutated after init.
    private let _makeBody: (DFToastStyleConfiguration) -> AnyView
    public let layout: DFToastLayout

    public init<S: DFToastStyle & Sendable>(_ style: S) {
        layout = style.layout
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFToastStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFToastStyleKey: EnvironmentKey {
    static let defaultValue: AnyDFToastStyle = AnyDFToastStyle(DFDefaultToastStyle())
}

public extension EnvironmentValues {
    var dfToastStyle: AnyDFToastStyle {
        get { self[DFToastStyleKey.self] }
        set { self[DFToastStyleKey.self] = newValue }
    }
}

public extension View {
    func dfToastStyle<S: DFToastStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfToastStyle, AnyDFToastStyle(style))
    }
}

// MARK: - Convenience static members

public extension DFToastStyle where Self == DFDefaultToastStyle {
    static var `default`: DFDefaultToastStyle { DFDefaultToastStyle() }
}
public extension DFToastStyle where Self == DFTintedToastStyle {
    static var tinted: DFTintedToastStyle { DFTintedToastStyle() }
}
public extension DFToastStyle where Self == DFFilledToastStyle {
    static var filled: DFFilledToastStyle { DFFilledToastStyle() }
}
public extension DFToastStyle where Self == DFInverseToastStyle {
    static var inverse: DFInverseToastStyle { DFInverseToastStyle() }
}
public extension DFToastStyle where Self == DFFrostedToastStyle {
    static var frosted: DFFrostedToastStyle { DFFrostedToastStyle() }
}
public extension DFToastStyle where Self == DFBannerToastStyle {
    static var banner: DFBannerToastStyle { DFBannerToastStyle() }
}
public extension DFToastStyle where Self == DFCompactToastStyle {
    static var compact: DFCompactToastStyle { DFCompactToastStyle() }
}
@available(iOS 26, macOS 26, *)
public extension DFToastStyle where Self == DFGlassToastStyle {
    static var glass: DFGlassToastStyle { DFGlassToastStyle() }
}

// MARK: - Built-ins

/// Themed capsule: elevated surface, hairline border, layered shadow, severity icon badge.
public struct DFDefaultToastStyle: DFToastStyle, Sendable {
    public init() {}
    public func makeBody(configuration: DFToastStyleConfiguration) -> some View {
        DFToastBody(configuration: configuration, look: .standard)
    }
}

/// Elevated surface washed with the severity color, with a matching border.
public struct DFTintedToastStyle: DFToastStyle, Sendable {
    public init() {}
    public func makeBody(configuration: DFToastStyleConfiguration) -> some View {
        DFToastBody(configuration: configuration, look: .tinted)
    }
}

/// Solid severity-colored capsule with a contrast-adapted foreground.
public struct DFFilledToastStyle: DFToastStyle, Sendable {
    public init() {}
    public func makeBody(configuration: DFToastStyleConfiguration) -> some View {
        DFToastBody(configuration: configuration, look: .filled)
    }
}

/// High-contrast pill: `textPrimary` background with `background` text.
public struct DFInverseToastStyle: DFToastStyle, Sendable {
    public init() {}
    public func makeBody(configuration: DFToastStyleConfiguration) -> some View {
        DFToastBody(configuration: configuration, look: .inverse)
    }
}

/// Material blur capsule with a light rim.
public struct DFFrostedToastStyle: DFToastStyle, Sendable {
    public init() {}
    public func makeBody(configuration: DFToastStyleConfiguration) -> some View {
        DFToastBody(configuration: configuration, look: .frosted)
    }
}

/// Liquid Glass capsule tinted with the severity color. Falls back to frosted when
/// `theme.materials.preferLiquidGlass` is false.
@available(iOS 26, macOS 26, *)
public struct DFGlassToastStyle: DFToastStyle, Sendable {
    public init() {}
    public func makeBody(configuration: DFToastStyleConfiguration) -> some View {
        DFToastBody(
            configuration: configuration,
            look: configuration.theme.materials.preferLiquidGlass ? .glass : .frosted
        )
    }
}

/// Full-width bar flush with the screen edge and a leading severity stripe.
public struct DFBannerToastStyle: DFToastStyle, Sendable {
    public init() {}
    public var layout: DFToastLayout { .flush }
    public func makeBody(configuration: DFToastStyleConfiguration) -> some View {
        DFToastBody(configuration: configuration, look: .banner)
    }
}

/// Small single-line pill for terse confirmations.
public struct DFCompactToastStyle: DFToastStyle, Sendable {
    public init() {}
    public func makeBody(configuration: DFToastStyleConfiguration) -> some View {
        DFToastBody(configuration: configuration, look: .compact)
    }
}
