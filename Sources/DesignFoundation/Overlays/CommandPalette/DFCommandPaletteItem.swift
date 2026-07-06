import Foundation

// MARK: - Item

/// A single selectable entry in a command palette.
///
/// `DFCommandPaletteItem` is a plain, `Sendable` value type — it carries no behavior.
/// Selection is reported once, at the palette level, via the `onSelect` closure passed to
/// `.dfCommandPalette(isPresented:items:onSelect:)`, rather than embedding a per-item action
/// closure here. This keeps the item type trivially `Sendable`/`Equatable`/`Hashable`-friendly
/// (useful for tests and for callers who want to build/diff/filter arrays of items), and mirrors
/// how `DFList` takes a caller-supplied `rowContent`/action rather than baking behavior into the
/// data model.
public struct DFCommandPaletteItem: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let icon: String?

    public init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String? = nil,
        icon: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }
}

// MARK: - Filtering

/// Pure, testable filtering logic for the command palette.
///
/// Kept as a standalone enum (rather than buried in the view body) so the matching behavior can
/// be unit tested without instantiating SwiftUI views.
public enum DFCommandPaletteFilter {
    /// Case-insensitive substring match against `title` and, if present, `subtitle`.
    /// An empty (or whitespace-only) query returns all items, preserving input order.
    public static func filter(items: [DFCommandPaletteItem], query: String) -> [DFCommandPaletteItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items }

        let needle = trimmed.lowercased()
        return items.filter { item in
            if item.title.lowercased().contains(needle) {
                return true
            }
            if let subtitle = item.subtitle, subtitle.lowercased().contains(needle) {
                return true
            }
            return false
        }
    }
}
