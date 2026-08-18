import SwiftUI

public struct DFButton: View {
    private let label: String
    private let action: () -> Void
    private let role: DFButtonRole?
    private let styleOverride: AnyDFButtonStyle?

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
        //
        // The button's real content is `Text(label)` (not a zero-size placeholder) so that
        // `DFBrandedButtonStyle` receives actual content via `configuration.label` — the same
        // path a caller gets by applying `.buttonStyle(.df(...))` directly to their own `Button`,
        // icon included.
        Button(action: action) {
            Text(label)
        }
        .buttonStyle(DFBrandedButtonStyle(styleOverride ?? envStyle, role: role))
    }
}

/// Bridges SwiftUI's own `ButtonStyle` (which supplies real `isPressed`/`isEnabled` state tied to
/// an actual `Button`) to this package's `DFButtonStyle` protocol (which styles know how to draw).
///
/// Public and usable directly on any native `Button` — not just `DFButton` — so branding can be
/// applied via `.buttonStyle(.df(.outlined))` to a `Button` with arbitrary content (icons, `Label`,
/// custom layouts), the same way `.buttonStyle(.bordered)` works on stock SwiftUI buttons.
public struct DFBrandedButtonStyle: ButtonStyle {
    let activeStyle: AnyDFButtonStyle
    let role: DFButtonRole?

    @Environment(\.dfTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init<S: DFButtonStyle & Sendable>(_ style: S, role: DFButtonRole? = nil) {
        self.activeStyle = AnyDFButtonStyle(style)
        self.role = role
    }

    init(_ style: AnyDFButtonStyle, role: DFButtonRole?) {
        self.activeStyle = style
        self.role = role
    }

    public func makeBody(configuration: Configuration) -> some View {
        let config = DFButtonStyleConfiguration(
            label: AnyView(configuration.label),
            isPressed: configuration.isPressed && !reduceMotion,
            isDisabled: !isEnabled,
            role: role,
            theme: theme
        )
        activeStyle.makeBody(configuration: config)
            .accessibilityHint(role == .destructive ? "Destructive action" : "")
    }
}

public extension ButtonStyle where Self == DFBrandedButtonStyle {
    /// Brands a native `Button` with a `DesignFoundation` style, preserving its real content
    /// (icons, `Label`, custom layouts) — unlike `DFButton`, which only accepts a `String` title.
    static func df<S: DFButtonStyle & Sendable>(_ style: S, role: DFButtonRole? = nil) -> DFBrandedButtonStyle {
        DFBrandedButtonStyle(style, role: role)
    }
}
