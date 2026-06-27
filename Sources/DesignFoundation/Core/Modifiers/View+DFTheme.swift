import SwiftUI

public extension View {
    /// Injects a DFTheme into the SwiftUI environment.
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
    @MainActor
    func dfTheme(_ theme: DFTheme) -> some View {
        environment(\.dfTheme, theme)
    }
}
