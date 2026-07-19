import SwiftUI

// MARK: - Configuration

public struct DFBannerStyleConfiguration: Sendable {
    public let icon: String?
    public let message: String
    public let severity: DFToastSeverity
    public let actionTitle: String?
    public let onAction: (@MainActor @Sendable () -> Void)?
    public let isDismissible: Bool
    public let onDismiss: (@MainActor @Sendable () -> Void)?
    public let theme: DFTheme

    public init(
        icon: String?,
        message: String,
        severity: DFToastSeverity,
        actionTitle: String?,
        onAction: (@MainActor @Sendable () -> Void)?,
        isDismissible: Bool,
        onDismiss: (@MainActor @Sendable () -> Void)?,
        theme: DFTheme
    ) {
        self.icon = icon
        self.message = message
        self.severity = severity
        self.actionTitle = actionTitle
        self.onAction = onAction
        self.isDismissible = isDismissible
        self.onDismiss = onDismiss
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFBannerStyle {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(configuration: DFBannerStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFBannerStyle: DFBannerStyle, @unchecked Sendable {
    private let _makeBody: @MainActor (DFBannerStyleConfiguration) -> AnyView

    public init<S: DFBannerStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    public func makeBody(configuration: DFBannerStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFBannerStyleKey: EnvironmentKey {
    static let defaultValue = AnyDFBannerStyle(DFStandardBannerStyle())
}

public extension EnvironmentValues {
    var dfBannerStyle: AnyDFBannerStyle {
        get { self[DFBannerStyleKey.self] }
        set { self[DFBannerStyleKey.self] = newValue }
    }
}

public extension View {
    func dfBannerStyle<S: DFBannerStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfBannerStyle, AnyDFBannerStyle(style))
    }
}

// MARK: - Convenience static var

public extension DFBannerStyle where Self == DFStandardBannerStyle {
    static var standard: DFStandardBannerStyle { DFStandardBannerStyle() }
}

// MARK: - Built-in: Standard (default)

public struct DFStandardBannerStyle: DFBannerStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFBannerStyleConfiguration) -> some View {
        let theme = configuration.theme
        let cornerRadius = theme.components.banner.cornerRadius ?? theme.radius.md
        let padding = theme.components.banner.padding ?? theme.spacing.md
        let tintColor = Self.tintColor(for: configuration.severity, theme: theme)

        HStack(alignment: .top, spacing: theme.spacing.sm) {
            if let icon = configuration.icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(tintColor)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(configuration.message)
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.textPrimary)

                if let actionTitle = configuration.actionTitle, let onAction = configuration.onAction {
                    DFButton(actionTitle) { onAction() }
                        .dfButtonStyle(.ghost)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if configuration.isDismissible {
                Button {
                    configuration.onDismiss?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss")
            }
        }
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(tintColor.opacity(0.12))
        )
    }

    private static func tintColor(for severity: DFToastSeverity, theme: DFTheme) -> Color {
        switch severity {
        case .info:    return theme.colors.info
        case .success: return theme.colors.success
        case .warning: return theme.colors.warning
        case .error:   return theme.colors.destructive
        }
    }
}
