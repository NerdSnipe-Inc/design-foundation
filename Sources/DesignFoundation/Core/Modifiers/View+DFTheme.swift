import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public extension View {
    /// Injects a DFTheme and a resolved DFPlatformContext into the SwiftUI environment.
    /// Cascades to all child views. Can be overridden for any sub-tree.
    ///
    /// Usage:
    /// ```swift
    /// ContentView()
    ///     .dfTheme(.default)
    ///
    /// // Custom theme
    /// ContentView()
    ///     .dfTheme(DFTheme(colors: DFColorTokens(primary: .purple)))
    /// ```
    func dfTheme(_ theme: DFTheme) -> some View {
        modifier(DFThemeModifier(theme: theme))
    }
}

private struct DFThemeModifier: ViewModifier {
    let theme: DFTheme

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    func body(content: Content) -> some View {
        let sizeClass = horizontalSizeClass ?? .regular
        let isGlass: Bool
        if #available(iOS 26, macOS 26, *) {
            isGlass = true
        } else {
            isGlass = false
        }

        #if os(iOS) || os(visionOS)
        let idiom = UIDevice.current.userInterfaceIdiom
        #elseif os(macOS)
        #if canImport(UIKit)
        let idiom = UIUserInterfaceIdiom.mac
        #else
        let idiom = 5 as Int // mac idiom value
        #endif
        #else
        #if canImport(UIKit)
        let idiom = UIUserInterfaceIdiom.unspecified
        #else
        let idiom = 0 as Int // unspecified fallback
        #endif
        #endif

        let context = DFPlatformContext(
            idiom: idiom,
            horizontalSizeClass: sizeClass,
            isLiquidGlassAvailable: isGlass
        )

        return content
            .environment(\.dfTheme, theme)
            .environment(\.dfPlatformContext, context)
    }
}
