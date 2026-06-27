import SwiftUI

public struct DFButton: View {
    private let label: String
    private let action: () -> Void
    private let role: DFButtonRole?

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfButtonStyle) private var style
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
    }

    public var body: some View {
        let config = DFButtonStyleConfiguration(
            label: AnyView(Text(label)),
            isPressed: isPressed && !reduceMotion,
            isDisabled: !isEnabled,
            role: role,
            theme: theme
        )
        AnyView(style.makeBody(configuration: config))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in
                        isPressed = false
                        if isEnabled { action() }
                    }
            )
            .accessibilityElement()
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
            .accessibilityAddTraits(role == .destructive ? [.isButton] : [])
            .accessibilityRemoveTraits(isEnabled ? [] : .isButton)
    }
}
