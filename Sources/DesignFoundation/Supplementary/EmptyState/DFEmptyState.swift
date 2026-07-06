import SwiftUI

public struct DFEmptyState: View {
    private let icon: String
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let onAction: (@MainActor @Sendable () -> Void)?

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfEmptyStateStyle) private var style

    public init(
        icon: String,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        onAction: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.onAction = onAction
    }

    public var body: some View {
        let config = DFEmptyStateStyleConfiguration(
            icon: icon,
            title: title,
            message: message,
            actionTitle: actionTitle,
            onAction: onAction,
            theme: theme
        )
        style.makeBody(configuration: config)
    }
}
