import SwiftUI

public extension DFTheme {
    /// The light variant of the Midnight preset theme.
    static let midnightLight = DFTheme(colors: .midnightLight, radius: .midnightRadius, shadows: .midnightShadows)
    /// The dark variant of the Midnight preset theme — true-black, OLED-tuned.
    static let midnightDark  = DFTheme(colors: .midnightDark,  radius: .midnightRadius, shadows: .midnightShadows)
}

private extension DFColorTokens {

    static var midnightLight: DFColorTokens {
        let fill = Color(red: 0.0,   green: 0.447, blue: 0.416)
        return DFColorTokens(
            primary:             Color(red: 0.0,   green: 0.447, blue: 0.416),
            secondary:           Color(red: 0.325, green: 0.400, blue: 0.400),
            accent:              Color(red: 0.0,   green: 0.675, blue: 0.627),
            background:          Color(red: 0.949, green: 0.961, blue: 0.961),
            surface:             Color(red: 0.973, green: 0.984, blue: 0.984),
            surfaceElevated:     Color(red: 0.992, green: 0.996, blue: 0.996),
            textPrimary:         Color(red: 0.055, green: 0.090, blue: 0.090),
            textSecondary:       Color(red: 0.325, green: 0.400, blue: 0.400),
            textDisabled:        Color(red: 0.651, green: 0.690, blue: 0.690),
            border:              Color(red: 0.800, green: 0.843, blue: 0.843),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.839, green: 0.875, blue: 0.875),
            destructive:         Color(red: 0.863, green: 0.188, blue: 0.188),
            success:             Color(red: 0.180, green: 0.490, blue: 0.196),
            warning:             Color(red: 0.902, green: 0.580, blue: 0.0),
            info:                Color(red: 0.082, green: 0.396, blue: 0.753),
            respectsColorScheme: false
        )
    }

    static var midnightDark: DFColorTokens {
        // True-black (OLED) background. interactiveFill is a muted mid-teal, not the bright
        // primary, so white button labels clear WCAG AA 4.5:1 — same approach as slateDark/copperDark.
        let fill = Color(red: 0.102, green: 0.388, blue: 0.365)
        return DFColorTokens(
            primary:             Color(red: 0.0,   green: 0.898, blue: 0.831),
            secondary:           Color(red: 0.471, green: 0.580, blue: 0.573),
            accent:              Color(red: 0.337, green: 0.976, blue: 0.933),
            background:          Color(red: 0.0,   green: 0.0,   blue: 0.0),
            surface:             Color(red: 0.071, green: 0.071, blue: 0.078),
            surfaceElevated:     Color(red: 0.110, green: 0.110, blue: 0.122),
            textPrimary:         Color(red: 0.961, green: 0.969, blue: 0.976),
            textSecondary:       Color(red: 0.588, green: 0.616, blue: 0.639),
            textDisabled:        Color(red: 0.278, green: 0.294, blue: 0.306),
            border:              Color(red: 0.165, green: 0.165, blue: 0.180),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.110, green: 0.110, blue: 0.122),
            destructive:         Color(red: 0.937, green: 0.325, blue: 0.314),
            success:             Color(red: 0.400, green: 0.733, blue: 0.416),
            warning:             Color(red: 1.0,   green: 0.655, blue: 0.149),
            info:                Color(red: 0.392, green: 0.710, blue: 0.965),
            respectsColorScheme: false
        )
    }
}

private extension DFRadiusTokens {
    static let midnightRadius = DFRadiusTokens(none: 0, sm: 6, md: 10, lg: 16, full: 9999)
}

private extension DFShadowTokens {
    // Dark-UI-appropriate: subtle, since black-on-black shadows read mostly through elevation
    // color steps rather than cast shadow.
    static let midnightShadows = DFShadowTokens(
        none: .none,
        sm:   DFShadow(color: .black.opacity(0.30), radius: 4,  x: 0, y: 2),
        md:   DFShadow(color: .black.opacity(0.40), radius: 8,  x: 0, y: 4),
        lg:   DFShadow(color: .black.opacity(0.55), radius: 16, x: 0, y: 8)
    )
}
