import SwiftUI

public struct DFColorTokens: Sendable {

    // MARK: Brand
    public var primary: Color
    public var secondary: Color
    public var accent: Color

    // MARK: Surfaces
    public var background: Color
    public var surface: Color
    public var surfaceElevated: Color

    // MARK: Content
    public var textPrimary: Color
    public var textSecondary: Color
    public var textDisabled: Color
    public var border: Color

    // MARK: Interactive states
    public var interactiveFill: Color
    public var interactiveHover: Color
    public var interactivePressed: Color
    public var interactiveDisabled: Color

    // MARK: Feedback
    public var destructive: Color
    public var success: Color
    public var warning: Color
    public var info: Color

    // MARK: Behaviour
    /// When true, components automatically adapt to the system \.colorScheme.
    /// Setting to false locks components to the token values regardless of dark/light mode.
    public var respectsColorScheme: Bool

    public init(
        primary: Color? = nil,
        secondary: Color? = nil,
        accent: Color? = nil,
        background: Color? = nil,
        surface: Color? = nil,
        surfaceElevated: Color? = nil,
        textPrimary: Color? = nil,
        textSecondary: Color? = nil,
        textDisabled: Color? = nil,
        border: Color? = nil,
        interactiveFill: Color? = nil,
        interactiveHover: Color? = nil,
        interactivePressed: Color? = nil,
        interactiveDisabled: Color? = nil,
        destructive: Color? = nil,
        success: Color? = nil,
        warning: Color? = nil,
        info: Color? = nil,
        respectsColorScheme: Bool = true
    ) {
        self.primary = primary ?? Color(red: 0.0, green: 0.478, blue: 1.0)
        self.secondary = secondary ?? Color(white: 0.55)
        self.accent = accent ?? Color(red: 0.0, green: 0.478, blue: 1.0)
        self.background = background ?? Color(white: 0.95)
        self.surface = surface ?? Color(white: 0.9)
        self.surfaceElevated = surfaceElevated ?? Color(white: 0.85)
        self.textPrimary = textPrimary ?? Color(white: 0.1)
        self.textSecondary = textSecondary ?? Color(white: 0.4)
        self.textDisabled = textDisabled ?? Color(white: 0.6)
        self.border = border ?? Color(white: 0.7)
        self.interactiveFill = interactiveFill ?? Color(red: 0.0, green: 0.478, blue: 1.0)
        self.interactiveHover = interactiveHover ?? Color(red: 0.0, green: 0.478, blue: 1.0).opacity(0.85)
        self.interactivePressed = interactivePressed ?? Color(red: 0.0, green: 0.478, blue: 1.0).opacity(0.7)
        self.interactiveDisabled = interactiveDisabled ?? Color(white: 0.8)
        self.destructive = destructive ?? Color(red: 1.0, green: 0.231, blue: 0.188)
        self.success = success ?? Color(red: 0.204, green: 0.78, blue: 0.349)
        self.warning = warning ?? Color(red: 1.0, green: 0.584, blue: 0.0)
        self.info = info ?? Color(red: 0.0, green: 0.478, blue: 1.0)
        self.respectsColorScheme = respectsColorScheme
    }

    public static let `default` = DFColorTokens()
}
