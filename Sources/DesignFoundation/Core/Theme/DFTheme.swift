import SwiftUI

public struct DFTheme: Sendable {

    public var colors: DFColorTokens
    public var typography: DFTypographyTokens
    public var spacing: DFSpacingTokens
    public var radius: DFRadiusTokens
    public var shadows: DFShadowTokens
    public var animation: DFAnimationTokens
    public var components: DFComponentTokens

    public init(
        colors: DFColorTokens = .default,
        typography: DFTypographyTokens = .default,
        spacing: DFSpacingTokens = .default,
        radius: DFRadiusTokens = .default,
        shadows: DFShadowTokens = .default,
        animation: DFAnimationTokens = .default,
        components: DFComponentTokens = .default
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radius = radius
        self.shadows = shadows
        self.animation = animation
        self.components = components
    }

    // MARK: Presets

    public static let `default` = DFTheme()
}
