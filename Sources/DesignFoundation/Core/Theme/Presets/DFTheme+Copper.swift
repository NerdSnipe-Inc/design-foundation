import SwiftUI

public extension DFTheme {
    /// The light variant of the Copper preset theme.
    static let copperLight = DFTheme(colors: .copperLight, radius: .copperRadius, shadows: .copperShadows)
    /// The dark variant of the Copper preset theme.
    static let copperDark  = DFTheme(colors: .copperDark,  radius: .copperRadius, shadows: .copperShadows)
}

private extension DFColorTokens {

    static var copperLight: DFColorTokens {
        let fill = Color(red: 0.769, green: 0.384, blue: 0.176)
        return DFColorTokens(
            primary:             Color(red: 0.769, green: 0.384, blue: 0.176),
            secondary:           Color(red: 0.553, green: 0.431, blue: 0.388),
            accent:              Color(red: 0.910, green: 0.537, blue: 0.294),
            background:          Color(red: 0.984, green: 0.973, blue: 0.961),
            surface:             Color(red: 0.961, green: 0.929, blue: 0.890),
            surfaceElevated:     Color(red: 1.0,   green: 0.980, blue: 0.965),
            textPrimary:         Color(red: 0.173, green: 0.094, blue: 0.063),
            textSecondary:       Color(red: 0.553, green: 0.431, blue: 0.388),
            textDisabled:        Color(red: 0.737, green: 0.659, blue: 0.612),
            border:              Color(red: 0.890, green: 0.816, blue: 0.765),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.941, green: 0.878, blue: 0.816),
            destructive:         Color(red: 0.776, green: 0.157, blue: 0.157),
            success:             Color(red: 0.180, green: 0.490, blue: 0.196),
            warning:             Color(red: 0.902, green: 0.318, blue: 0.0),
            info:                Color(red: 0.082, green: 0.396, blue: 0.753),
            respectsColorScheme: false
        )
    }

    static var copperDark: DFColorTokens {
        let fill = Color(red: 0.957, green: 0.635, blue: 0.380)
        return DFColorTokens(
            primary:             Color(red: 0.957, green: 0.635, blue: 0.380),
            secondary:           Color(red: 0.631, green: 0.533, blue: 0.498),
            accent:              Color(red: 1.0,   green: 0.718, blue: 0.302),
            background:          Color(red: 0.102, green: 0.063, blue: 0.031),
            surface:             Color(red: 0.173, green: 0.122, blue: 0.071),
            surfaceElevated:     Color(red: 0.239, green: 0.173, blue: 0.110),
            textPrimary:         Color(red: 1.0,   green: 0.953, blue: 0.910),
            textSecondary:       Color(red: 0.749, green: 0.627, blue: 0.565),
            textDisabled:        Color(red: 0.361, green: 0.251, blue: 0.188),
            border:              Color(red: 0.290, green: 0.188, blue: 0.125),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.180, green: 0.110, blue: 0.063),
            destructive:         Color(red: 0.937, green: 0.325, blue: 0.314),
            success:             Color(red: 0.400, green: 0.733, blue: 0.416),
            warning:             Color(red: 1.0,   green: 0.655, blue: 0.149),
            info:                Color(red: 0.392, green: 0.710, blue: 0.965),
            respectsColorScheme: false
        )
    }
}

private extension DFRadiusTokens {
    static let copperRadius = DFRadiusTokens(none: 0, sm: 3, md: 6, lg: 10, full: 9999)
}

private extension DFShadowTokens {
    static let copperShadows = DFShadowTokens(
        none: .none,
        sm:   DFShadow(color: .black.opacity(0.12), radius: 3,  x: 0, y: 3),
        md:   DFShadow(color: .black.opacity(0.16), radius: 6,  x: 0, y: 5),
        lg:   DFShadow(color: .black.opacity(0.22), radius: 12, x: 0, y: 10)
    )
}
