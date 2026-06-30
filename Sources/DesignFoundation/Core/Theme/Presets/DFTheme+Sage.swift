import SwiftUI

public extension DFTheme {
    /// The light variant of the Sage preset theme.
    static let sageLight = DFTheme(colors: .sageLight, radius: .sageRadius, shadows: .sageShadows)
    /// The dark variant of the Sage preset theme.
    static let sageDark  = DFTheme(colors: .sageDark,  radius: .sageRadius, shadows: .sageShadows)
}

private extension DFColorTokens {

    static var sageLight: DFColorTokens {
        let fill = Color(red: 0.176, green: 0.416, blue: 0.310)
        return DFColorTokens(
            primary:             Color(red: 0.176, green: 0.416, blue: 0.310),
            secondary:           Color(red: 0.322, green: 0.475, blue: 0.435),
            accent:              Color(red: 0.322, green: 0.718, blue: 0.533),
            background:          Color(red: 0.969, green: 0.980, blue: 0.969),
            surface:             Color(red: 0.929, green: 0.957, blue: 0.933),
            surfaceElevated:     .white,
            textPrimary:         Color(red: 0.039, green: 0.137, blue: 0.094),
            textSecondary:       Color(red: 0.322, green: 0.475, blue: 0.435),
            textDisabled:        Color(red: 0.624, green: 0.722, blue: 0.686),
            border:              Color(red: 0.784, green: 0.875, blue: 0.800),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.847, green: 0.929, blue: 0.878),
            destructive:         Color(red: 0.776, green: 0.157, blue: 0.157),
            success:             Color(red: 0.106, green: 0.369, blue: 0.125),
            warning:             Color(red: 0.961, green: 0.486, blue: 0.0),
            info:                Color(red: 0.004, green: 0.341, blue: 0.608),
            respectsColorScheme: false
        )
    }

    static var sageDark: DFColorTokens {
        let fill = Color(red: 0.455, green: 0.776, blue: 0.616)
        return DFColorTokens(
            primary:             Color(red: 0.455, green: 0.776, blue: 0.616),
            secondary:           Color(red: 0.420, green: 0.620, blue: 0.561),
            accent:              Color(red: 0.584, green: 0.835, blue: 0.698),
            background:          Color(red: 0.039, green: 0.102, blue: 0.059),
            surface:             Color(red: 0.086, green: 0.169, blue: 0.110),
            surfaceElevated:     Color(red: 0.122, green: 0.239, blue: 0.153),
            textPrimary:         Color(red: 0.910, green: 0.961, blue: 0.925),
            textSecondary:       Color(red: 0.502, green: 0.690, blue: 0.565),
            textDisabled:        Color(red: 0.227, green: 0.361, blue: 0.259),
            border:              Color(red: 0.122, green: 0.290, blue: 0.173),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.082, green: 0.165, blue: 0.102),
            destructive:         Color(red: 0.937, green: 0.325, blue: 0.314),
            success:             Color(red: 0.400, green: 0.733, blue: 0.416),
            warning:             Color(red: 1.0,   green: 0.655, blue: 0.149),
            info:                Color(red: 0.392, green: 0.710, blue: 0.965),
            respectsColorScheme: false
        )
    }
}

private extension DFRadiusTokens {
    static let sageRadius = DFRadiusTokens(none: 0, sm: 6, md: 12, lg: 18, full: 9999)
}

private extension DFShadowTokens {
    static let sageShadows = DFShadowTokens(
        none: .none,
        sm:   DFShadow(color: .black.opacity(0.04), radius: 8,  x: 0, y: 1),
        md:   DFShadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 3),
        lg:   DFShadow(color: .black.opacity(0.10), radius: 24, x: 0, y: 5)
    )
}
