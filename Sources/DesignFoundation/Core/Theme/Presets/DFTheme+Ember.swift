import SwiftUI

public extension DFTheme {
    /// The light variant of the Ember preset theme — bold, energetic orange-red.
    static let emberLight = DFTheme(colors: .emberLight, radius: .emberRadius, shadows: .emberShadows)
    /// The dark variant of the Ember preset theme.
    static let emberDark  = DFTheme(colors: .emberDark,  radius: .emberRadius, shadows: .emberShadows)
}

private extension DFColorTokens {

    static var emberLight: DFColorTokens {
        let fill = Color(red: 0.918, green: 0.267, blue: 0.102)
        return DFColorTokens(
            primary:             Color(red: 0.918, green: 0.267, blue: 0.102),
            secondary:           Color(red: 0.498, green: 0.337, blue: 0.251),
            accent:              Color(red: 1.0,   green: 0.447, blue: 0.102),
            background:          Color(red: 0.988, green: 0.965, blue: 0.945),
            surface:             Color(red: 1.0,   green: 0.980, blue: 0.961),
            surfaceElevated:     Color(red: 1.0,   green: 1.0,   blue: 0.996),
            textPrimary:         Color(red: 0.149, green: 0.067, blue: 0.035),
            textSecondary:       Color(red: 0.498, green: 0.337, blue: 0.251),
            textDisabled:        Color(red: 0.737, green: 0.624, blue: 0.561),
            border:              Color(red: 0.918, green: 0.835, blue: 0.773),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.918, green: 0.839, blue: 0.784),
            destructive:         Color(red: 0.776, green: 0.157, blue: 0.157),
            success:             Color(red: 0.180, green: 0.490, blue: 0.196),
            warning:             Color(red: 0.961, green: 0.698, blue: 0.0),
            info:                Color(red: 0.082, green: 0.396, blue: 0.753),
            respectsColorScheme: false
        )
    }

    static var emberDark: DFColorTokens {
        // interactiveFill is a deeper, less saturated orange-red than `primary` so white
        // button labels clear WCAG AA 4.5:1 contrast — `primary` stays bright for accents.
        let fill = Color(red: 0.776, green: 0.267, blue: 0.102)
        return DFColorTokens(
            primary:             Color(red: 1.0,   green: 0.447, blue: 0.267),
            secondary:           Color(red: 0.776, green: 0.600, blue: 0.533),
            accent:              Color(red: 1.0,   green: 0.573, blue: 0.302),
            background:          Color(red: 0.078, green: 0.039, blue: 0.027),
            surface:             Color(red: 0.141, green: 0.078, blue: 0.055),
            surfaceElevated:     Color(red: 0.188, green: 0.106, blue: 0.078),
            textPrimary:         Color(red: 1.0,   green: 0.953, blue: 0.933),
            textSecondary:       Color(red: 0.776, green: 0.600, blue: 0.533),
            textDisabled:        Color(red: 0.400, green: 0.278, blue: 0.220),
            border:              Color(red: 0.267, green: 0.149, blue: 0.102),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.173, green: 0.094, blue: 0.067),
            destructive:         Color(red: 0.937, green: 0.325, blue: 0.314),
            success:             Color(red: 0.400, green: 0.733, blue: 0.416),
            warning:             Color(red: 1.0,   green: 0.776, blue: 0.149),
            info:                Color(red: 0.392, green: 0.710, blue: 0.965),
            respectsColorScheme: false
        )
    }
}

private extension DFRadiusTokens {
    static let emberRadius = DFRadiusTokens(none: 0, sm: 2, md: 4, lg: 8, full: 9999)
}

private extension DFShadowTokens {
    static let emberShadows = DFShadowTokens(
        none: .none,
        sm:   DFShadow(color: .black.opacity(0.14), radius: 3,  x: 0, y: 2),
        md:   DFShadow(color: .black.opacity(0.20), radius: 7,  x: 0, y: 4),
        lg:   DFShadow(color: .black.opacity(0.28), radius: 14, x: 0, y: 8)
    )
}
