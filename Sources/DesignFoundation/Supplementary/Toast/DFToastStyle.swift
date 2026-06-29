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

    public init(
        text: String,
        icon: String? = nil,
        duration: TimeInterval = 3.0,
        severity: DFToastSeverity = .info
    ) {
        self.id = UUID()
        self.text = text
        self.icon = icon
        self.duration = duration
        self.severity = severity
    }
}

// MARK: - Configuration
// IS Sendable: holds DFToastMessage (Sendable) and DFTheme (Sendable).

public struct DFToastStyleConfiguration: Sendable {
    public let message: DFToastMessage
    public let theme: DFTheme

    public init(message: DFToastMessage, theme: DFTheme) {
        self.message = message
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFToastStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFToastStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFToastStyle: DFToastStyle, @unchecked Sendable {
    // @unchecked Sendable: _makeBody captures a concrete Sendable style value; internal storage is never mutated after init.
    private let _makeBody: (DFToastStyleConfiguration) -> AnyView

    public init<S: DFToastStyle & Sendable>(_ style: S) {
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

// MARK: - Convenience static var

public extension DFToastStyle where Self == DFDefaultToastStyle {
    static var `default`: DFDefaultToastStyle { DFDefaultToastStyle() }
}

// MARK: - Built-in: Default

public struct DFDefaultToastStyle: DFToastStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFToastStyleConfiguration) -> some View {
        let theme = configuration.theme
        let message = configuration.message
        let iconColor = Self.iconColor(for: message.severity, theme: theme)
        HStack(spacing: theme.spacing.sm) {
            if let icon = message.icon {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(iconColor)
            }
            Text(message.text)
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, theme.spacing.sm)
        .background(
            Capsule()
                .fill(theme.colors.surfaceElevated)
                .shadow(
                    color: theme.shadows.sm.color,
                    radius: theme.shadows.sm.radius,
                    x: theme.shadows.sm.x,
                    y: theme.shadows.sm.y
                )
        )
    }

    private static func iconColor(for severity: DFToastSeverity, theme: DFTheme) -> Color {
        switch severity {
        case .info:    return theme.colors.info
        case .success: return theme.colors.success
        case .warning: return theme.colors.warning
        case .error:   return theme.colors.destructive
        }
    }
}
