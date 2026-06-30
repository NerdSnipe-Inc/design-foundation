import SwiftUI

// MARK: - Role

public enum DFAlertActionRole: Sendable, Equatable {
    case destructive
    case cancel

    var buttonRole: ButtonRole {
        switch self {
        case .destructive: .destructive
        case .cancel: .cancel
        }
    }
}

// MARK: - Action

public struct DFAlertAction: Sendable {
    public let title: String
    public let role: DFAlertActionRole?
    public let action: (@MainActor @Sendable () -> Void)?

    public init(title: String, role: DFAlertActionRole? = nil, action: (@MainActor @Sendable () -> Void)? = nil) {
        self.title = title
        self.role = role
        self.action = action
    }
}

// MARK: - Configuration

public struct DFAlertConfiguration: Sendable {
    public let title: String
    public let message: String?
    public let actions: [DFAlertAction]

    public init(title: String, message: String? = nil, actions: [DFAlertAction] = [DFAlertAction(title: "OK")]) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}

// MARK: - Modifier

private struct DFAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let configuration: DFAlertConfiguration

    func body(content: Content) -> some View {
        content.alert(configuration.title, isPresented: $isPresented) {
            ForEach(Array(configuration.actions.enumerated()), id: \.offset) { _, alertAction in
                Button(alertAction.title, role: alertAction.role?.buttonRole) {
                    alertAction.action?()
                }
            }
        } message: {
            if let message = configuration.message {
                Text(message)
            }
        }
    }
}

// MARK: - View extension

public extension View {
    func dfAlert(isPresented: Binding<Bool>, configuration: DFAlertConfiguration) -> some View {
        modifier(DFAlertModifier(isPresented: isPresented, configuration: configuration))
    }

    func dfAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        actions: [DFAlertAction] = [DFAlertAction(title: "OK")]
    ) -> some View {
        dfAlert(isPresented: isPresented, configuration: DFAlertConfiguration(
            title: title,
            message: message,
            actions: actions
        ))
    }
}
