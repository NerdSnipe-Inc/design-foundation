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
        let styled = style.makeBody(configuration: config)
            .accessibilityElement(children: .contain)
            .accessibilityAddTraits(action != nil ? .isButton : [])

        // Only attach tap/press gestures when the card is actually interactive. A
        // `DragGesture(minimumDistance: 0)` — even one whose handlers no-op — still
        // participates in gesture resolution, and at zero distance it can win against a
        // parent ScrollView's own drag recognizer, silently blocking scrolling for every
        // non-interactive card in a scrollable stack (confirmed: cards with no `action`
        // swallowed scroll gestures until this was made conditional).
        if let action {
            styled
                .contentShape(Rectangle())
                .onTapGesture {
                    if isEnabled { action() }
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in isPressed = false }
                )
        } else {
            styled
        }
    }
}
