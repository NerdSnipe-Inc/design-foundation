import SwiftUI

public extension DFTheme {
    // Slate uses default radius and shadows — DFTheme() defaults apply.
    /// The light variant of the Slate preset theme.
    static let slateLight = DFTheme(colors: .slateLight)
    /// The dark variant of the Slate preset theme.
    static let slateDark  = DFTheme(colors: .slateDark)
}

private extension DFColorTokens {

    static var slateLight: DFColorTokens {
        // Deep navy — far from system blue's bright azure
        let fill = Color(red: 0.118, green: 0.239, blue: 0.490)
        return DFColorTokens(
            primary:             Color(red: 0.110, green: 0.239, blue: 0.353),
            secondary:           Color(red: 0.329, green: 0.431, blue: 0.478),
            accent:              Color(red: 0.220, green: 0.427, blue: 0.765),
            // Visibly cool blue-grey — distinguishable from neutral white at a glance
            background:          Color(red: 0.894, green: 0.906, blue: 0.922),
            surface:             Color(red: 0.925, green: 0.933, blue: 0.945),
            surfaceElevated:     Color(red: 0.961, green: 0.965, blue: 0.973),
            textPrimary:         Color(red: 0.051, green: 0.106, blue: 0.165),
            textSecondary:       Color(red: 0.329, green: 0.431, blue: 0.478),
            textDisabled:        Color(red: 0.620, green: 0.667, blue: 0.710),
            border:              Color(red: 0.761, green: 0.800, blue: 0.839),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.839, green: 0.863, blue: 0.890),
            destructive:         Color(red: 0.898, green: 0.224, blue: 0.208),
            success:             Color(red: 0.180, green: 0.490, blue: 0.196),
            warning:             Color(red: 0.961, green: 0.486, blue: 0.0),
            info:                Color(red: 0.008, green: 0.467, blue: 0.741),
            respectsColorScheme: false
        )
    }

    static var slateDark: DFColorTokens {
        let fill = Color(red: 0.392, green: 0.710, blue: 0.965)
        return DFColorTokens(
            primary:             Color(red: 0.392, green: 0.710, blue: 0.965),
            secondary:           Color(red: 0.471, green: 0.565, blue: 0.612),
            accent:              Color(red: 0.510, green: 0.769, blue: 1.0),
            background:          Color(red: 0.059, green: 0.098, blue: 0.137),
            surface:             Color(red: 0.110, green: 0.169, blue: 0.227),
            surfaceElevated:     Color(red: 0.141, green: 0.204, blue: 0.278),
            textPrimary:         Color(red: 0.910, green: 0.941, blue: 0.973),
            textSecondary:       Color(red: 0.565, green: 0.643, blue: 0.682),
            textDisabled:        Color(red: 0.290, green: 0.376, blue: 0.439),
            border:              Color(red: 0.180, green: 0.251, blue: 0.341),
            interactiveFill:     fill,
            interactiveHover:    fill.opacity(0.85),
            interactivePressed:  fill.opacity(0.70),
            interactiveDisabled: Color(red: 0.122, green: 0.200, blue: 0.282),
            destructive:         Color(red: 0.937, green: 0.325, blue: 0.314),
            success:             Color(red: 0.400, green: 0.733, blue: 0.416),
            warning:             Color(red: 1.0,   green: 0.655, blue: 0.149),
            info:                Color(red: 0.161, green: 0.714, blue: 0.965),
            respectsColorScheme: false
        )
    }
}
