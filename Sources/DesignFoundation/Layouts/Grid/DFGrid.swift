import SwiftUI

/// Column layout mode for `DFGrid`.
public enum DFGridColumns: Sendable {
    /// A fixed number of equal-width columns.
    case fixed(Int)
    /// As many columns as fit, each at least `minWidth` wide (SwiftUI's `.adaptive` grid item).
    case adaptive(minWidth: CGFloat)
}

/// A themed wrapper around `LazyVGrid` — spacing/columns read from `DFTheme` unless overridden.
public struct DFGrid<Content: View>: View {
    private let columns: DFGridColumns
    private let spacing: CGFloat?
    private let content: Content

    @Environment(\.dfTheme) private var theme

    public init(
        columns: DFGridColumns = .fixed(2),
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.columns = columns
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        let gap = spacing ?? theme.components.grid.spacing ?? theme.spacing.sm
        LazyVGrid(columns: gridItems(gap: gap), spacing: gap) {
            content
        }
    }

    private func gridItems(gap: CGFloat) -> [GridItem] {
        switch columns {
        case .fixed(let count):
            return Array(repeating: GridItem(.flexible(), spacing: gap), count: max(1, count))
        case .adaptive(let minWidth):
            return [GridItem(.adaptive(minimum: minWidth), spacing: gap)]
        }
    }
}
