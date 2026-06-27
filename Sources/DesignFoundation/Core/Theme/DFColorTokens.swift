import SwiftUI
#if os(iOS) || os(tvOS)
import UIKit
#else
import AppKit
#endif

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
#if os(iOS) || os(tvOS)
        self.background = background ?? Color(UIColor.systemBackground)
        self.surface = surface ?? Color(UIColor.secondarySystemBackground)
        self.surfaceElevated = surfaceElevated ?? Color(UIColor.tertiarySystemBackground)
        self.textPrimary = textPrimary ?? Color(UIColor.label)
        self.textSecondary = textSecondary ?? Color(UIColor.secondaryLabel)
        self.textDisabled = textDisabled ?? Color(UIColor.tertiaryLabel)
        self.border = border ?? Color(UIColor.separator)
        self.interactiveDisabled = interactiveDisabled ?? Color(UIColor.systemFill)
        self.destructive = destructive ?? Color(UIColor.systemRed)
        self.success = success ?? Color(UIColor.systemGreen)
        self.warning = warning ?? Color(UIColor.systemOrange)
        self.info = info ?? Color(UIColor.systemBlue)
#else
        self.background = background ?? Color(NSColor.windowBackgroundColor)
        self.surface = surface ?? Color(NSColor.controlBackgroundColor)
        self.surfaceElevated = surfaceElevated ?? Color(NSColor.controlColor)
        self.textPrimary = textPrimary ?? Color(NSColor.textColor)
        self.textSecondary = textSecondary ?? Color(NSColor.secondaryLabelColor)
        self.textDisabled = textDisabled ?? Color(NSColor.tertiaryLabelColor)
        self.border = border ?? Color(NSColor.separatorColor)
        self.interactiveDisabled = interactiveDisabled ?? Color(NSColor.disabledControlTextColor)
        self.destructive = destructive ?? Color(NSColor.systemRed)
        self.success = success ?? Color(NSColor.systemGreen)
        self.warning = warning ?? Color(NSColor.systemOrange)
        self.info = info ?? Color(NSColor.systemBlue)
#endif
        self.interactiveFill = interactiveFill ?? Color(red: 0.0, green: 0.478, blue: 1.0)
        self.interactiveHover = interactiveHover ?? Color(red: 0.0, green: 0.478, blue: 1.0).opacity(0.85)
        self.interactivePressed = interactivePressed ?? Color(red: 0.0, green: 0.478, blue: 1.0).opacity(0.7)
        self.respectsColorScheme = respectsColorScheme
    }

    public static let `default` = DFColorTokens()
}
