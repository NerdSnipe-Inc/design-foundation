import SwiftUI

public struct DFCard<Content: View>: View {
    private let content: Content
    private let action: (() -> Void)?

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dfCardStyle) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isPressed = false

    public init(action: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    public var body: some View {
        let config = DFCardStyleConfiguration(
            content: AnyView(content),
            isPressed: isPressed && !reduceMotion,
            isDisabled: !isEnabled,
            isInteractive: action != nil,
            theme: theme
        )
        style.makeBody(configuration: config)
            .contentShape(Rectangle())
            .onTapGesture {
                if isEnabled { action?() }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in if action != nil { isPressed = true } }
                    .onEnded { _ in isPressed = false }
            )
            .accessibilityElement(children: .contain)
            .accessibilityAddTraits(action != nil ? .isButton : [])
    }
}
