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
    /// App canvas. iOS: `systemBackground`. macOS: `textBackgroundColor` (not `windowBackgroundColor`).
    public var background: Color
    /// Grouped panels and secondary regions. iOS: `secondarySystemBackground`. macOS: `controlBackgroundColor`.
    public var surface: Color
    /// Cards and raised panels. iOS: `tertiarySystemBackground`. macOS: `windowBackgroundColor`.
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

#if os(iOS) || os(tvOS)
    public init(
        primary: Color = Color(red: 0.0, green: 0.478, blue: 1.0),
        secondary: Color = Color(white: 0.55),
        accent: Color = Color(red: 0.0, green: 0.478, blue: 1.0),
        background: Color = Color(UIColor.systemBackground),
        surface: Color = Color(UIColor.secondarySystemBackground),
        surfaceElevated: Color = Color(UIColor.tertiarySystemBackground),
        textPrimary: Color = Color(UIColor.label),
        textSecondary: Color = Color(UIColor.secondaryLabel),
        textDisabled: Color = Color(UIColor.tertiaryLabel),
        border: Color = Color(UIColor.separator),
        interactiveFill: Color = Color(red: 0.0, green: 0.478, blue: 1.0),
        interactiveHover: Color = Color(red: 0.0, green: 0.478, blue: 1.0).opacity(0.85),
        interactivePressed: Color = Color(red: 0.0, green: 0.478, blue: 1.0).opacity(0.7),
        interactiveDisabled: Color = Color(UIColor.systemGray5),
        destructive: Color = Color(UIColor.systemRed),
        success: Color = Color(UIColor.systemGreen),
        warning: Color = Color(UIColor.systemOrange),
        info: Color = Color(UIColor.systemBlue),
        respectsColorScheme: Bool = true
    ) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.background = background
        self.surface = surface
        self.surfaceElevated = surfaceElevated
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textDisabled = textDisabled
        self.border = border
        self.interactiveFill = interactiveFill
        self.interactiveHover = interactiveHover
        self.interactivePressed = interactivePressed
        self.interactiveDisabled = interactiveDisabled
        self.destructive = destructive
        self.success = success
        self.warning = warning
        self.info = info
        self.respectsColorScheme = respectsColorScheme
    }
#else
    public init(
        primary: Color = Color(red: 0.0, green: 0.478, blue: 1.0),
        secondary: Color = Color(white: 0.55),
        accent: Color = Color(red: 0.0, green: 0.478, blue: 1.0),
        // Canvas → grouped surface → elevated card (darkest to lightest in dark mode).
        // Avoid windowBackgroundColor as canvas — it reads as bright gray beside sidebars.
        background: Color = Color(NSColor.textBackgroundColor),
        surface: Color = Color(NSColor.controlBackgroundColor),
        surfaceElevated: Color = Color(NSColor.windowBackgroundColor),
        textPrimary: Color = Color(NSColor.labelColor),
        textSecondary: Color = Color(NSColor.secondaryLabelColor),
        textDisabled: Color = Color(NSColor.tertiaryLabelColor),
        border: Color = Color(NSColor.separatorColor),
        interactiveFill: Color = Color(red: 0.0, green: 0.478, blue: 1.0),
        interactiveHover: Color = Color(red: 0.0, green: 0.478, blue: 1.0).opacity(0.85),
        interactivePressed: Color = Color(red: 0.0, green: 0.478, blue: 1.0).opacity(0.7),
        interactiveDisabled: Color = Color(NSColor.disabledControlTextColor),
        destructive: Color = Color(NSColor.systemRed),
        success: Color = Color(NSColor.systemGreen),
        warning: Color = Color(NSColor.systemOrange),
        info: Color = Color(NSColor.systemBlue),
        respectsColorScheme: Bool = true
    ) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.background = background
        self.surface = surface
        self.surfaceElevated = surfaceElevated
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textDisabled = textDisabled
        self.border = border
        self.interactiveFill = interactiveFill
        self.interactiveHover = interactiveHover
        self.interactivePressed = interactivePressed
        self.interactiveDisabled = interactiveDisabled
        self.destructive = destructive
        self.success = success
        self.warning = warning
        self.info = info
        self.respectsColorScheme = respectsColorScheme
    }
#endif

    public static let `default` = DFColorTokens()
}
