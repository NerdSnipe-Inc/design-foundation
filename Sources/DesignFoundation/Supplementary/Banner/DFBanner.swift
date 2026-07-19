import SwiftUI

/// A full-width, persistent, inline banner — not built on `DFToastQueue`. Toast's
/// floating-capsule, auto-dismiss, global-overlay-queue model doesn't fit a banner's
/// full-width, user-dismissed, inline-in-content shape, so retrofitting the queue would
/// conflate two different presentation patterns. `DFBanner` is a plain value-driven view:
/// place it directly in your view hierarchy (e.g. `if showBanner { DFBanner(...) }` at the
/// top of a VStack), the same way `DFAlert`/`DFEmptyState` work.
public struct DFBanner: View {
    private let icon: String?
    private let message: String
    private let severity: DFToastSeverity
    private let actionTitle: String?
    private let onAction: (@MainActor @Sendable () -> Void)?
    private let isDismissible: Bool
    private let onDismiss: (@MainActor @Sendable () -> Void)?

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfBannerStyle) private var style

    public init(
        icon: String? = nil,
        message: String,
        severity: DFToastSeverity = .info,
        actionTitle: String? = nil,
        onAction: (@MainActor @Sendable () -> Void)? = nil,
        isDismissible: Bool = false,
        onDismiss: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.icon = icon
        self.message = message
        self.severity = severity
        self.actionTitle = actionTitle
        self.onAction = onAction
        self.isDismissible = isDismissible
        self.onDismiss = onDismiss
    }

    @MainActor
    public var body: some View {
        let config = DFBannerStyleConfiguration(
            icon: icon,
            message: message,
            severity: severity,
            actionTitle: actionTitle,
            onAction: onAction,
            isDismissible: isDismissible,
            onDismiss: onDismiss,
            theme: theme
        )
        style.makeBody(configuration: config)
            .accessibilityElement(children: .combine)
    }
}
