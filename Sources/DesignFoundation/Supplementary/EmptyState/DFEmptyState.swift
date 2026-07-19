import SwiftUI

public struct DFEmptyState: View {
    private let icon: String
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let onAction: (@MainActor @Sendable () -> Void)?
    private let secondaryActionTitle: String?
    private let onSecondaryAction: (@MainActor @Sendable () -> Void)?

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfEmptyStateStyle) private var style

    /// - Parameters:
    ///   - secondaryActionTitle/onSecondaryAction: an optional second, lower-emphasis action
    ///     (e.g. "Not Now") rendered alongside the primary action — this is what makes
    ///     `DFEmptyState` also cover permission-prompt-shaped two-choice screens (icon/title/
    ///     message/primary+secondary action) without a separate near-duplicate component.
    public init(
        icon: String,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        onAction: (@MainActor @Sendable () -> Void)? = nil,
        secondaryActionTitle: String? = nil,
        onSecondaryAction: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.onAction = onAction
        self.secondaryActionTitle = secondaryActionTitle
        self.onSecondaryAction = onSecondaryAction
    }

    public var body: some View {
        let config = DFEmptyStateStyleConfiguration(
            icon: icon,
            title: title,
            message: message,
            actionTitle: actionTitle,
            onAction: onAction,
            secondaryActionTitle: secondaryActionTitle,
            onSecondaryAction: onSecondaryAction,
            theme: theme
        )
        style.makeBody(configuration: config)
    }
}
