import SwiftUI

public struct DFButton: View {
    private let label: String
    private let action: () -> Void
    private let role: DFButtonRole?
    private let styleOverride: AnyDFButtonStyle?

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfButtonStyle) private var envStyle

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
        // A real `Button` (not `.onTapGesture`) — `.onTapGesture` combined with a
        // `simultaneousGesture(DragGesture(minimumDistance: 0))` (the previous implementation,
        // used to drive a hand-rolled `isPressed`) is a known-fragile SwiftUI pattern: the two
        // gesture recognizers can race, and the tap silently never fires — confirmed live, where
        // clicking a real, on-screen DFButton with a real mouse did not invoke `action` at all.
        // A native `Button` wrapped in a real `ButtonStyle` gets `configuration.isPressed` and
        // `.isEnabled` for free, and is the one thing macOS reliably delivers clicks to.
        Button(action: action) {
            Color.clear.frame(width: 0, height: 0)
        }
        .buttonStyle(DFButtonStyleBridge(activeStyle: styleOverride ?? envStyle, label: label, role: role, theme: theme))
    }
}

/// Bridges SwiftUI's own `ButtonStyle` (which supplies real `isPressed`/`isEnabled` state tied to
/// an actual `Button`) to this package's `DFButtonStyle` protocol (which styles know how to draw).
private struct DFButtonStyleBridge: ButtonStyle {
    let activeStyle: AnyDFButtonStyle
    let label: String
    let role: DFButtonRole?
    let theme: DFTheme

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let config = DFButtonStyleConfiguration(
            label: AnyView(Text(label)),
            isPressed: configuration.isPressed && !reduceMotion,
            isDisabled: !isEnabled,
            role: role,
            theme: theme
        )
        activeStyle.makeBody(configuration: config)
            .accessibilityLabel(label)
            .accessibilityHint(role == .destructive ? "Destructive action" : "")
    }
}
