import SwiftUI

/// Material tokens for Liquid Glass rendering.
///
/// This type itself is universally available: `Material` (`.regularMaterial`,
/// `.thickMaterial`, etc.) has existed since iOS 15 / macOS 12, well before the
/// `@available(iOS 26, macOS 26, *)` gate that applied here previously. Gating the
/// *token namespace* on iOS 26 was unnecessarily conservative — it made `DFTheme`
/// (which is used unconditionally on iOS 18+, with no other availability gating on
/// any of its token properties) unable to cleanly hold a `materials: DFMaterialTokens`
/// stored property. The gate has been removed so `DFMaterialTokens` behaves like
/// every other token namespace (`DFColorTokens`, `DFSpacingTokens`, etc.): always
/// constructible and always present on `DFTheme`.
///
/// The actual Liquid Glass *visual effect* is still gated correctly — every one of
/// the 16 `DFGlass*Style` structs across the package already carries its own
/// `@available(iOS 26, macOS 26, *)` attribute, so glass rendering itself remains
/// iOS 26+ / macOS 26+ only. Below that OS floor, components simply don't read
/// these tokens (they use their non-glass style, which reads `DFColorTokens`
/// instead) — this type existing pre-26 has no user-visible effect.
public struct DFMaterialTokens: Sendable {
    /// Material used for standard surface-level containers (Card, Sheet background).
    public var surfaceMaterial: Material
    /// Material used for elevated containers (Modal, Popover).
    public var elevatedMaterial: Material
    /// When true, components use glass materials where available.
    /// Set to false to opt out of Liquid Glass entirely and use color tokens instead.
    public var preferLiquidGlass: Bool

    public init(
        surfaceMaterial: Material = .regularMaterial,
        elevatedMaterial: Material = .thickMaterial,
        preferLiquidGlass: Bool = true
    ) {
        self.surfaceMaterial = surfaceMaterial
        self.elevatedMaterial = elevatedMaterial
        self.preferLiquidGlass = preferLiquidGlass
    }

    public static let `default` = DFMaterialTokens()
}
