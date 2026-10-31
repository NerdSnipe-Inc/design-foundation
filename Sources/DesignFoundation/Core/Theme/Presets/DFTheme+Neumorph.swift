import SwiftUI

public extension DFTheme {
    /// The light variant of the Neumorph preset theme — soft, low-contrast surfaces with large radii.
    static let neumorphLight = DFTheme(colors: .neumorphLight, radius: .neumorphRadius, shadows: .neumorphShadows)
    /// The dark variant of the Neumorph preset theme.
    static let neumorphDark  = DFTheme(colors: .neumorphDark,  radius: .neumorphRadius, shadows: .neumorphShadows)
}

private extension DFColorTokens {

    static var neumorphLight: DFColorTokens {
        let fill = Color(red: 0.400, green: 0.345, blue: 0.918)
        return DFColorTokens(
            primary:             Color(red: 0.400, green: 0.345, blue: 0.918),
            secondary:           Color(red: 0.455, green: 0.455, blue: 0.502),
            accent:              Color(red: 0.545, green: 0.361, blue: 0.965),
            // Background and surface are intentionally close in value — neumorphism
            // relies on soft shadow for separation, not a hard surface/background split.
            background:          Color(red: 0.925, green: 0.925, blue: 0.937),
            surface:             Color(red: 0.933, green: 0.933, blue: 0.945),
            surfaceElevated:     Color(red: 0.949, green: 0.949, blue: 0.961),
            textPrimary:         Color(red: 0.173, green: 0.173, blue: 0.208),
            textSecondary:       Color(red: 0.455, green: 0.455, blue: 0.502),
            textDisabled:        Color(red: 0.690, green: 0.690, blue: 0.722),
            border:              Color(red: 0.839, green: 0.839, blue: 0.863),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.863, green: 0.863, blue: 0.886),
            destructive:         Color(red: 0.863, green: 0.267, blue: 0.267),
            success:             Color(red: 0.251, green: 0.627, blue: 0.329),
            warning:             Color(red: 0.898, green: 0.580, blue: 0.071),
            info:                Color(red: 0.267, green: 0.545, blue: 0.863),
            respectsColorScheme: false
        )
    }

    static var neumorphDark: DFColorTokens {
        // interactiveFill uses a deeper indigo than `primary` so white button labels keep
        // WCAG AA contrast — the brighter `primary` is reserved for text/icon accents.
        let fill = Color(red: 0.400, green: 0.345, blue: 0.843)
        return DFColorTokens(
            primary:             Color(red: 0.580, green: 0.510, blue: 0.976),
            secondary:           Color(red: 0.624, green: 0.624, blue: 0.671),
            accent:              Color(red: 0.682, green: 0.580, blue: 1.0),
            background:          Color(red: 0.129, green: 0.129, blue: 0.149),
            surface:             Color(red: 0.141, green: 0.141, blue: 0.165),
            surfaceElevated:     Color(red: 0.161, green: 0.161, blue: 0.188),
            textPrimary:         Color(red: 0.925, green: 0.925, blue: 0.945),
            textSecondary:       Color(red: 0.624, green: 0.624, blue: 0.671),
            textDisabled:        Color(red: 0.345, green: 0.345, blue: 0.388),
            border:              Color(red: 0.212, green: 0.212, blue: 0.243),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.180, green: 0.180, blue: 0.208),
            destructive:         Color(red: 0.937, green: 0.325, blue: 0.314),
            success:             Color(red: 0.400, green: 0.733, blue: 0.416),
            warning:             Color(red: 1.0,   green: 0.655, blue: 0.149),
            info:                Color(red: 0.392, green: 0.573, blue: 0.965),
            respectsColorScheme: false
        )
    }
}

private extension DFRadiusTokens {
    static let neumorphRadius = DFRadiusTokens(none: 0, sm: 10, md: 16, lg: 24, full: 9999)
}

private extension DFShadowTokens {
    // Large blur radius, low opacity — the soft, diffuse "pressed into the surface" look.
    static let neumorphShadows = DFShadowTokens(
        none: .none,
        sm:   DFShadow(color: .black.opacity(0.10), radius: 8,  x: 0, y: 4),
        md:   DFShadow(color: .black.opacity(0.14), radius: 14, x: 0, y: 6),
        lg:   DFShadow(color: .black.opacity(0.18), radius: 22, x: 0, y: 10)
    )
}
