import SwiftUI

/// A custom tab bar container. Renders content for the selected tab above a themed tab bar strip.
///
/// Uses `safeAreaInset(edge: .bottom)` so the tab bar extends into the bottom safe area without
/// overlapping the content area.
///
/// Usage:
/// ```swift
/// @State var selection = "home"
/// let items = [
///     DFTabItem(id: "home", icon: "house", label: "Home"),
///     DFTabItem(id: "search", icon: "magnifyingglass", label: "Search"),
/// ]
/// DFTabBar(selection: $selection, items: items) { id in
///     switch id {
///     case "home": HomeView()
///     default: SearchView()
///     }
/// }
/// ```
public struct DFTabBar<Content: View>: View {
    @Binding private var selection: String
    private let items: [DFTabItem]
    private let content: (String) -> Content

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfTabBarStyle) private var style

    public init(
        selection: Binding<String>,
        items: [DFTabItem],
        @ViewBuilder content: @escaping (String) -> Content
    ) {
        self._selection = selection
        self.items = items
        self.content = content
    }

    public var body: some View {
        content(selection)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                style.makeBody(configuration: DFTabBarStyleConfiguration(
                    items: items,
                    selectedID: selection,
                    onSelect: { selection = $0 },
                    theme: theme
                ))
            }
    }
}
