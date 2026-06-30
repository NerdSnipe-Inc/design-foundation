import SwiftUI

public extension DFTheme {
    /// The light variant of the Aurora preset theme.
    static let auroraLight = DFTheme(colors: .auroraLight, radius: .auroraRadius, shadows: .auroraShadows)
    /// The dark variant of the Aurora preset theme.
    static let auroraDark  = DFTheme(colors: .auroraDark,  radius: .auroraRadius, shadows: .auroraShadows)
}

private extension DFColorTokens {

    static var auroraLight: DFColorTokens {
        let fill = Color(red: 0.424, green: 0.278, blue: 1.0)
        return DFColorTokens(
            primary:             Color(red: 0.424, green: 0.278, blue: 1.0),
            secondary:           Color(red: 0.608, green: 0.447, blue: 0.812),
            accent:              Color(red: 0.655, green: 0.545, blue: 0.980),
            background:          Color(white: 0.980),
            surface:             Color(red: 0.953, green: 0.941, blue: 1.0),
            surfaceElevated:     .white,
            textPrimary:         Color(red: 0.102, green: 0.039, blue: 0.310),
            textSecondary:       Color(red: 0.420, green: 0.373, blue: 0.627),
            textDisabled:        Color(red: 0.702, green: 0.663, blue: 0.851),
            border:              Color(red: 0.851, green: 0.820, blue: 0.961),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.910, green: 0.890, blue: 1.0),
            destructive:         Color(red: 0.898, green: 0.224, blue: 0.208),
            success:             Color(red: 0.180, green: 0.490, blue: 0.196),
            warning:             Color(red: 0.961, green: 0.486, blue: 0.0),
            info:                Color(red: 0.424, green: 0.278, blue: 1.0),
            respectsColorScheme: false
        )
    }

    static var auroraDark: DFColorTokens {
        let fill = Color(red: 0.655, green: 0.545, blue: 0.980)
        return DFColorTokens(
            primary:             Color(red: 0.655, green: 0.545, blue: 0.980),
            secondary:           Color(red: 0.486, green: 0.420, blue: 0.678),
            accent:              Color(red: 0.769, green: 0.710, blue: 0.992),
            background:          Color(red: 0.051, green: 0.039, blue: 0.118),
            surface:             Color(red: 0.102, green: 0.082, blue: 0.208),
            surfaceElevated:     Color(red: 0.141, green: 0.114, blue: 0.278),
            textPrimary:         Color(red: 0.929, green: 0.914, blue: 1.0),
            textSecondary:       Color(red: 0.616, green: 0.561, blue: 0.831),
            textDisabled:        Color(red: 0.290, green: 0.247, blue: 0.478),
            border:              Color(red: 0.180, green: 0.145, blue: 0.341),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.122, green: 0.098, blue: 0.251),
            destructive:         Color(red: 0.937, green: 0.325, blue: 0.314),
            success:             Color(red: 0.400, green: 0.733, blue: 0.416),
            warning:             Color(red: 1.0,   green: 0.655, blue: 0.149),
            info:                Color(red: 0.655, green: 0.545, blue: 0.980),
            respectsColorScheme: false
        )
    }
}

private extension DFRadiusTokens {
    static let auroraRadius = DFRadiusTokens(none: 0, sm: 4, md: 10, lg: 16, full: 9999)
}

private extension DFShadowTokens {
    static let auroraShadows = DFShadowTokens(
        none: .none,
        sm:   DFShadow(color: .black.opacity(0.06), radius: 6,  x: 0, y: 2),
        md:   DFShadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4),
        lg:   DFShadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 6)
    )
}
