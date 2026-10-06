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
            .modifier(DFDuoPlatformModifier())
            .environment(\.dfTheme, theme)
            .environment(\.dfPlatformContext, context)
    }
}

/// Fills in the platform facts that only exist on the iPhone Duo SDK (Xcode 27.1+). Applied inside the scope that
/// `.dfTheme` populates, so it sees the context the theme modifier just built. A no-op everywhere else.
private struct DFDuoPlatformModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if compiler(>=6.4) && canImport(SwiftUI, _version: 8.1) && !targetEnvironment(macCatalyst)
        if #available(iOS 27.1, macOS 27.1, visionOS 27.1, *) {
            content.modifier(DFToolbarVerticalEdgeInjector())
        } else {
            content
        }
        #else
        content
        #endif
    }
}

#if compiler(>=6.4) && canImport(SwiftUI, _version: 8.1) && !targetEnvironment(macCatalyst)
/// Copies SwiftUI's `toolbarVerticalEdge` into `DFPlatformContext` for everything below it.
@available(iOS 27.1, macOS 27.1, visionOS 27.1, *)
private struct DFToolbarVerticalEdgeInjector: ViewModifier {
    @Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge
    @Environment(\.dfPlatformContext) private var context

    func body(content: Content) -> some View {
        content.environment(\.dfPlatformContext, DFPlatformContext(
            idiom: context.idiom,
            horizontalSizeClass: context.horizontalSizeClass,
            isLiquidGlassAvailable: context.isLiquidGlassAvailable,
            toolbarVerticalEdge: toolbarVerticalEdge
        ))
    }
}
#endif
