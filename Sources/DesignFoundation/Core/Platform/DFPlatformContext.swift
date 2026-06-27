import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Resolved platform facts used by component styles to select the correct rendering path.
/// Injected into the SwiftUI environment alongside DFTheme.
/// Resolved once at injection time — not re-computed per render.
public struct DFPlatformContext: Sendable {
    #if canImport(UIKit)
    public let idiom: UIUserInterfaceIdiom
    #else
    public let idiom: Int // Fallback for platforms without UIKit
    #endif
    public let horizontalSizeClass: UserInterfaceSizeClass
    public let isLiquidGlassAvailable: Bool

    #if canImport(UIKit)
    public init(
        idiom: UIUserInterfaceIdiom,
        horizontalSizeClass: UserInterfaceSizeClass,
        isLiquidGlassAvailable: Bool
    ) {
        self.idiom = idiom
        self.horizontalSizeClass = horizontalSizeClass
        self.isLiquidGlassAvailable = isLiquidGlassAvailable
    }
    #else
    public init(
        idiom: Int,
        horizontalSizeClass: UserInterfaceSizeClass,
        isLiquidGlassAvailable: Bool
    ) {
        self.idiom = idiom
        self.horizontalSizeClass = horizontalSizeClass
        self.isLiquidGlassAvailable = isLiquidGlassAvailable
    }
    #endif

    /// Returns a DFPlatformContext resolved for the current process environment.
    ///
    /// **Note:** `horizontalSizeClass` is hardcoded to `.regular` in this static context,
    /// as a static property cannot read SwiftUI environment values. For accurate, dynamic
    /// size class resolution within view hierarchies, use the `.dfTheme()` view modifier,
    /// which reads `horizontalSizeClass` from the environment and injects the correct
    /// DFPlatformContext.
    @MainActor
    public static var current: DFPlatformContext {
        #if os(iOS) || os(visionOS)
        let idiom = UIDevice.current.userInterfaceIdiom
        #elseif os(macOS)
        #if canImport(UIKit)
        let idiom = UIUserInterfaceIdiom.mac
        #else
        // Fallback for pure macOS without UIKit
        let idiom = 5 as Int // mac idiom value
        #endif
        #else
        #if canImport(UIKit)
        let idiom = UIUserInterfaceIdiom.unspecified
        #else
        let idiom = 0 as Int // unspecified fallback
        #endif
        #endif

        let isGlass: Bool
        if #available(iOS 26, macOS 26, *) {
            isGlass = true
        } else {
            isGlass = false
        }

        return DFPlatformContext(
            idiom: idiom,
            horizontalSizeClass: .regular,
            isLiquidGlassAvailable: isGlass
        )
    }
}

// MARK: - Environment

private struct DFPlatformContextKey: EnvironmentKey {
    // Use a non-@MainActor static property for EnvironmentKey conformance
    static let defaultValue: DFPlatformContext = {
        #if os(iOS) || os(visionOS)
        let idiom = UIDevice.current.userInterfaceIdiom
        #elseif os(macOS)
        #if canImport(UIKit)
        let idiom = UIUserInterfaceIdiom.mac
        #else
        let idiom = 5 as Int
        #endif
        #else
        #if canImport(UIKit)
        let idiom = UIUserInterfaceIdiom.unspecified
        #else
        let idiom = 0 as Int
        #endif
        #endif

        return DFPlatformContext(
            idiom: idiom,
            horizontalSizeClass: .regular,
            isLiquidGlassAvailable: {
                if #available(iOS 26, macOS 26, *) {
                    return true
                } else {
                    return false
                }
            }()
        )
    }()
}

public extension EnvironmentValues {
    var dfPlatformContext: DFPlatformContext {
        get { self[DFPlatformContextKey.self] }
        set { self[DFPlatformContextKey.self] = newValue }
    }
}
