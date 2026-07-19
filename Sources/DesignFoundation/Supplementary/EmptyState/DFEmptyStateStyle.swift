import SwiftUI

// MARK: - Configuration

public struct DFEmptyStateStyleConfiguration: Sendable {
    public let icon: String
    public let title: String
    public let message: String?
    public let actionTitle: String?
    public let onAction: (@MainActor @Sendable () -> Void)?
    public let secondaryActionTitle: String?
    public let onSecondaryAction: (@MainActor @Sendable () -> Void)?
    public let theme: DFTheme

    public init(
        icon: String,
        title: String,
        message: String?,
        actionTitle: String?,
        onAction: (@MainActor @Sendable () -> Void)?,
        secondaryActionTitle: String? = nil,
        onSecondaryAction: (@MainActor @Sendable () -> Void)? = nil,
        theme: DFTheme
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.onAction = onAction
        self.secondaryActionTitle = secondaryActionTitle
        self.onSecondaryAction = onSecondaryAction
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFEmptyStateStyle {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(configuration: DFEmptyStateStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFEmptyStateStyle: DFEmptyStateStyle, @unchecked Sendable {
    // @unchecked Sendable: _makeBody captures a concrete Sendable style value; internal storage is never mutated after init.
    private let _makeBody: @MainActor (DFEmptyStateStyleConfiguration) -> AnyView

    public init<S: DFEmptyStateStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    public func makeBody(configuration: DFEmptyStateStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFEmptyStateStyleKey: EnvironmentKey {
    static let defaultValue = AnyDFEmptyStateStyle(DFStandardEmptyStateStyle())
}

public extension EnvironmentValues {
    var dfEmptyStateStyle: AnyDFEmptyStateStyle {
        get { self[DFEmptyStateStyleKey.self] }
        set { self[DFEmptyStateStyleKey.self] = newValue }
    }
}

public extension View {
    func dfEmptyStateStyle<S: DFEmptyStateStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfEmptyStateStyle, AnyDFEmptyStateStyle(style))
    }
}

// MARK: - Convenience static var

public extension DFEmptyStateStyle where Self == DFStandardEmptyStateStyle {
    static var standard: DFStandardEmptyStateStyle { DFStandardEmptyStateStyle() }
}

// MARK: - Built-in: Standard

public struct DFStandardEmptyStateStyle: DFEmptyStateStyle, Sendable {
    public init() {}

    @MainActor
    public func makeBody(configuration: DFEmptyStateStyleConfiguration) -> some View {
        let theme = configuration.theme
        let iconSize = (theme.components.icon.defaultSize ?? 24) * 2

        VStack(spacing: theme.spacing.xl) {
            VStack(spacing: theme.spacing.sm) {
                DFIcon(configuration.icon, size: iconSize)
                    .dfIconStyle(.secondary)

                DFText(configuration.title, scale: .headline)
                    .multilineTextAlignment(.center)

                if let message = configuration.message {
                    DFText(message, scale: .bodySmall)
                        .dfTextViewStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .accessibilityElement(children: .combine)

            if let actionTitle = configuration.actionTitle, let onAction = configuration.onAction {
                VStack(spacing: theme.spacing.sm) {
                    DFButton(actionTitle) { onAction() }

                    if let secondaryActionTitle = configuration.secondaryActionTitle,
                       let onSecondaryAction = configuration.onSecondaryAction {
                        DFButton(secondaryActionTitle) { onSecondaryAction() }
                            .dfButtonStyle(.ghost)
                    }
                }
            }
        }
        .padding(theme.spacing.xxl)
        .frame(maxWidth: .infinity)
    }
}
