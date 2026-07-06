import SwiftUI

// MARK: - Public API

public extension View {
    /// Presents a Cmd-K-style command palette overlay: a themed search field plus a
    /// text-filtered results list, floating over the current content.
    ///
    /// Unlike `.dfSheet`/`.dfPopover`, this modifier does not take a generic `content:` closure —
    /// the palette's internal content (search field + filtered list) is fixed, not
    /// consumer-supplied. Callers only provide the `items` to search over and an `onSelect`
    /// callback.
    ///
    /// - Parameters:
    ///   - isPresented: Controls presentation. Selecting an item, tapping outside the panel,
    ///     or pressing Escape all set this to `false`.
    ///   - items: The full, unfiltered list of items to search over.
    ///   - placeholder: Placeholder text shown in the search field.
    ///   - onSelect: Called with the selected item immediately before the palette dismisses.
    func dfCommandPalette(
        isPresented: Binding<Bool>,
        items: [DFCommandPaletteItem],
        placeholder: String = "Search…",
        onSelect: @escaping (DFCommandPaletteItem) -> Void
    ) -> some View {
        modifier(
            DFCommandPaletteModifier(
                isPresented: isPresented,
                items: items,
                placeholder: placeholder,
                onSelect: onSelect
            )
        )
    }
}

// MARK: - Modifier

private struct DFCommandPaletteModifier: ViewModifier {
    @Binding var isPresented: Bool
    let items: [DFCommandPaletteItem]
    let placeholder: String
    let onSelect: (DFCommandPaletteItem) -> Void

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfCommandPaletteStyle) private var style

    func body(content: Content) -> some View {
        content.overlay {
            if isPresented {
                DFCommandPaletteOverlay(
                    isPresented: $isPresented,
                    items: items,
                    placeholder: placeholder,
                    onSelect: onSelect,
                    theme: theme,
                    style: style
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(theme.animation.default, value: isPresented)
    }
}

// MARK: - Overlay (backdrop + panel)

private struct DFCommandPaletteOverlay: View {
    @Binding var isPresented: Bool
    let items: [DFCommandPaletteItem]
    let placeholder: String
    let onSelect: (DFCommandPaletteItem) -> Void
    let theme: DFTheme
    let style: AnyDFCommandPaletteStyle

    @State private var query: String = ""
    @State private var highlightedIndex: Int = 0
    @FocusState private var isSearchFocused: Bool

    private var filteredItems: [DFCommandPaletteItem] {
        DFCommandPaletteFilter.filter(items: items, query: query)
    }

    var body: some View {
        ZStack {
            // Backdrop — tapping it dismisses the palette.
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            style.makeBody(configuration: DFCommandPaletteStyleConfiguration(
                content: AnyView(panel),
                theme: theme
            ))
            .padding(theme.spacing.xl)
            // Swallow taps inside the panel so they don't reach the backdrop above.
            .onTapGesture {}
        }
        .onKeyPress(.escape) {
            dismiss()
            return .handled
        }
        .onKeyPress(.downArrow) {
            moveHighlight(by: 1)
            return .handled
        }
        .onKeyPress(.upArrow) {
            moveHighlight(by: -1)
            return .handled
        }
        .onKeyPress(.return) {
            activateHighlighted()
            return .handled
        }
        .onAppear {
            query = ""
            highlightedIndex = 0
            isSearchFocused = true
        }
    }

    private var panel: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            searchField
                .padding(.horizontal, theme.spacing.md)
                .padding(.top, theme.spacing.md)

            DFDivider()

            resultsList
                .padding(.horizontal, theme.spacing.sm)
                .padding(.bottom, theme.spacing.sm)
        }
        .frame(minWidth: 360, idealWidth: 480, maxWidth: 560)
        .frame(minHeight: 120, idealHeight: 360, maxHeight: 420)
    }

    private var searchField: some View {
        DFTextField("", text: $query, placeholder: placeholder, leading: {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.colors.textSecondary)
        })
        .focused($isSearchFocused)
        .onChange(of: query) {
            highlightedIndex = 0
        }
    }

    @ViewBuilder
    private var resultsList: some View {
        if filteredItems.isEmpty {
            DFEmptyState(
                icon: "magnifyingglass",
                title: "No results",
                message: "Try a different search term."
            )
            .padding(.vertical, theme.spacing.lg)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                            row(for: item, isHighlighted: index == highlightedIndex)
                                .id(item.id)
                                .onTapGesture {
                                    highlightedIndex = index
                                    select(item)
                                }
                        }
                    }
                }
                .onChange(of: highlightedIndex) { _, newValue in
                    guard filteredItems.indices.contains(newValue) else { return }
                    withAnimation {
                        proxy.scrollTo(filteredItems[newValue].id, anchor: .center)
                    }
                }
            }
        }
    }

    private func row(for item: DFCommandPaletteItem, isHighlighted: Bool) -> some View {
        DFListRow(title: item.title, subtitle: item.subtitle, leading: {
            if let icon = item.icon {
                Image(systemName: icon)
                    .foregroundStyle(theme.colors.textSecondary)
            } else {
                EmptyView()
            }
        })
        .padding(.horizontal, theme.spacing.sm)
        .background(isHighlighted ? theme.colors.interactiveFill.opacity(0.12) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.sm))
        .contentShape(Rectangle())
    }

    // MARK: - Actions

    private func moveHighlight(by delta: Int) {
        guard !filteredItems.isEmpty else { return }
        let newIndex = highlightedIndex + delta
        highlightedIndex = min(max(newIndex, 0), filteredItems.count - 1)
    }

    private func activateHighlighted() {
        guard filteredItems.indices.contains(highlightedIndex) else { return }
        select(filteredItems[highlightedIndex])
    }

    private func select(_ item: DFCommandPaletteItem) {
        onSelect(item)
        isPresented = false
    }

    private func dismiss() {
        isPresented = false
    }
}
