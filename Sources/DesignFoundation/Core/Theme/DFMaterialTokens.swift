import SwiftUI

/// Material tokens for iOS 26+ / macOS 26+ Liquid Glass rendering.
/// On earlier OS versions this type is never read — components fall back
/// to DFColorTokens.surface / DFColorTokens.surfaceElevated.
@available(iOS 26, macOS 26, *)
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
