import Foundation

/// Controls which platform form factor a component renders in.
/// Use `.automatic` (default) to let the component decide based on the current device.
public enum DFPlatformVariant: String, Sendable, CaseIterable {
    /// Component resolves its form factor at runtime based on device idiom and size class.
    case automatic
    /// Forces the compact/phone form factor regardless of device.
    case compact
    /// Forces the expanded/desktop form factor regardless of device.
    case expanded
    /// Forces the spatial/visionOS form factor.
    case immersive
}
