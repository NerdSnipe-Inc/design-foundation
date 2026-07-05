import SwiftUI

// MARK: - Garnet Preset
//
// A bold, saturated red preset — confident and gallery-clean rather than warm/earthy
// (contrast with .copper). Reads well for brands that want a strong, editorial accent
// color without leaning into orange or brown undertones.
//
// Light: #F5F5F5 background, white cards, deep garnet red (#C8102E) as primary
// Dark:  Near-black (#1C1C1C) background, dark-gray cards, brightened red (#E8203E)
// Radius: 8pt base

public extension DFTheme {
    static let garnetLight = DFTheme(colors: .garnetLight, radius: .garnetRadius, shadows: .garnetShadows)
    static let garnetDark  = DFTheme(colors: .garnetDark,  radius: .garnetRadius, shadows: .garnetShadows)
}

private extension DFColorTokens {

    // ── Light ──────────────────────────────────────────────────────────────
    // background: #F5F5F5  card: #FFFFFF  primary: #C8102E
    // muted-foreground: #6B6B6B  border: #D4D4D4

    static var garnetLight: DFColorTokens {
        // #C8102E — deep garnet red (r:200 g:16 b:46)
        let red = Color(red: 0.784, green: 0.063, blue: 0.180)
        return DFColorTokens(
            primary:             red,
            secondary:           Color(red: 0.420, green: 0.420, blue: 0.420),  // #6B6B6B muted-fg
            accent:              red,
            background:          Color(red: 0.961, green: 0.961, blue: 0.961),  // #F5F5F5
            surface:             Color(red: 1.000, green: 1.000, blue: 1.000),  // #FFFFFF cards
            surfaceElevated:     Color(red: 0.941, green: 0.941, blue: 0.941),  // #F0F0F0 muted
            textPrimary:         Color(red: 0.169, green: 0.169, blue: 0.169),  // #2B2B2B
            textSecondary:       Color(red: 0.420, green: 0.420, blue: 0.420),  // #6B6B6B
            textDisabled:        Color(red: 0.659, green: 0.659, blue: 0.659),  // #A8A8A8
            border:              Color(red: 0.831, green: 0.831, blue: 0.831),  // #D4D4D4
            interactiveFill:     red,
            interactiveHover:    red.opacity(0.86),
            interactivePressed:  red.opacity(0.72),
            interactiveDisabled: Color(red: 0.910, green: 0.910, blue: 0.910),  // #E8E8E8
            destructive:         Color(red: 0.863, green: 0.149, blue: 0.149),  // #DC2626
            success:             Color(red: 0.125, green: 0.510, blue: 0.157),  // #207128
            warning:             Color(red: 0.902, green: 0.424, blue: 0.000),  // #E66C00
            info:                Color(red: 0.059, green: 0.388, blue: 0.745),  // #0F63BE
            respectsColorScheme: false
        )
    }

    // ── Dark ───────────────────────────────────────────────────────────────
    // Brightened red kept for dark mode legibility rather than shifting to neutral.
    // background ≈ #1C1C1C   card ≈ #292929

    static var garnetDark: DFColorTokens {
        // Slightly brightened / lightened red for legibility on dark surfaces
        let red = Color(red: 0.910, green: 0.125, blue: 0.243)  // #E8203E
        return DFColorTokens(
            primary:             red,
            secondary:           Color(white: 0.608),                            // #9B9B9B
            accent:              red,
            background:          Color(white: 0.110),                            // #1C1C1C
            surface:             Color(white: 0.161),                            // #292929
            surfaceElevated:     Color(white: 0.220),                            // #383838
            textPrimary:         Color(white: 0.961),                            // #F5F5F5
            textSecondary:       Color(white: 0.608),                            // #9B9B9B
            textDisabled:        Color(white: 0.361),                            // #5C5C5C
            border:              Color.white.opacity(0.12),
            interactiveFill:     red,
            interactiveHover:    red.opacity(0.86),
            interactivePressed:  red.opacity(0.72),
            interactiveDisabled: Color(white: 0.200),
            destructive:         Color(red: 1.000, green: 0.271, blue: 0.227),  // #FF453A iOS dark red
            success:             Color(red: 0.196, green: 0.843, blue: 0.294),  // #32D74B iOS dark green
            warning:             Color(red: 1.000, green: 0.624, blue: 0.039),  // #FF9F0A iOS dark amber
            info:                Color(red: 0.039, green: 0.518, blue: 1.000),  // #0A84FF iOS dark blue
            respectsColorScheme: false
        )
    }
}

// MARK: - Radius
// 8pt base; sm/md/lg follow the same calc() steps as the source design tokens

private extension DFRadiusTokens {
    static let garnetRadius = DFRadiusTokens(
        none: 0,
        sm:   4,
        md:   6,
        lg:   8,
        full: 9999
    )
}

// MARK: - Shadows
// Clean, light drop shadows appropriate for a gallery / editorial surface

private extension DFShadowTokens {
    static let garnetShadows = DFShadowTokens(
        none: .none,
        sm:   DFShadow(color: .black.opacity(0.08), radius: 2,  x: 0, y: 1),
        md:   DFShadow(color: .black.opacity(0.12), radius: 6,  x: 0, y: 3),
        lg:   DFShadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 6)
    )
}
