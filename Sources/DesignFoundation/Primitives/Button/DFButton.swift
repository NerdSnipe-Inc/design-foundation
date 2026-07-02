import SwiftUI

public struct DFButton: View {
    private let label: String
    private let action: () -> Void
    private let role: DFButtonRole?
    private let styleOverride: AnyDFButtonStyle?

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfButtonStyle) private var envStyle
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isPressed = false

    public init(
        _ label: String,
        role: DFButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.role = role
        self.action = action
        self.styleOverride = nil
    }

    public init<S: DFButtonStyle & Sendable>(
        _ label: String,
        style: S,
        role: DFButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.role = role
        self.action = action
        self.styleOverride = AnyDFButtonStyle(style)
    }

    public var body: some View {
        let activeStyle = styleOverride ?? envStyle
        let config = DFButtonStyleConfiguration(
            label: AnyView(Text(label)),
            isPressed: isPressed && !reduceMotion,
            isDisabled: !isEnabled,
            role: role,
            theme: theme
        )
        activeStyle.makeBody(configuration: config)
            .onTapGesture {
                if isEnabled { action() }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
            .accessibilityElement()
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(role == .destructive ? "Destructive action" : "")
    }
}
