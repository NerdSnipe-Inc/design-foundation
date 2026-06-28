import SwiftUI

// MARK: - Private modifier

private struct DFNavigationBarModifier<Leading: View, Trailing: View>: ViewModifier {
    let title: String
    let displayMode: DFNavigationBarDisplayMode
    let leading: Leading
    let trailing: Trailing

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfNavigationBarStyle) private var style

    func body(content: Content) -> some View {
        let configured = AnyView(
            content
                .navigationTitle(title)
                #if os(iOS)
                .navigationBarTitleDisplayMode(displayMode.swiftUIDisplayMode)
                #endif
                .toolbar {
                    #if os(iOS) || os(visionOS)
                    ToolbarItem(placement: .navigationBarLeading) { leading }
                    ToolbarItem(placement: .navigationBarTrailing) { trailing }
                    #else
                    ToolbarItem(placement: .navigation) { leading }
                    ToolbarItem(placement: .primaryAction) { trailing }
                    #endif
                }
        )
        style.makeBody(configuration: DFNavigationBarStyleConfiguration(
            content: configured,
            theme: theme
        ))
    }
}

// MARK: - Display mode → SwiftUI conversion

#if os(iOS)
extension DFNavigationBarDisplayMode {
    var swiftUIDisplayMode: NavigationBarItem.TitleDisplayMode {
        switch self {
        case .automatic: return .automatic
        case .large:     return .large
        case .inline:    return .inline
        }
    }
}
#endif

// MARK: - Public API

public extension View {
    /// Applies a DF-styled navigation bar with the given title. No extra toolbar items.
    func dfNavigationBar(
        title: String,
        displayMode: DFNavigationBarDisplayMode = .automatic
    ) -> some View {
        modifier(DFNavigationBarModifier(
            title: title,
            displayMode: displayMode,
            leading: EmptyView(),
            trailing: EmptyView()
        ))
    }

    /// Applies a DF-styled navigation bar with a trailing toolbar item.
    func dfNavigationBar<Trailing: View>(
        title: String,
        displayMode: DFNavigationBarDisplayMode = .automatic,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        modifier(DFNavigationBarModifier(
            title: title,
            displayMode: displayMode,
            leading: EmptyView(),
            trailing: trailing()
        ))
    }

    /// Applies a DF-styled navigation bar with leading and trailing toolbar items.
    func dfNavigationBar<Leading: View, Trailing: View>(
        title: String,
        displayMode: DFNavigationBarDisplayMode = .automatic,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        modifier(DFNavigationBarModifier(
            title: title,
            displayMode: displayMode,
            leading: leading(),
            trailing: trailing()
        ))
    }
}
