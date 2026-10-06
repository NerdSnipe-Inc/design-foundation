import SwiftUI

// MARK: - Role

/// Semantic role of a menu item. Only `.destructive` exists today; it tints the row with
/// `theme.colors.destructive`, announces "Destructive action" to VoiceOver, and maps to
/// `ButtonRole.destructive` in native context menus.
public enum DFMenuItemRole: Sendable, Equatable {
    case destructive

    var buttonRole: ButtonRole {
        switch self {
        case .destructive: .destructive
        }
    }
}

// MARK: - Item

/// One entry in a `DFMenu` or `.dfContextMenu`.
///
/// Like `DFAlertAction`, the item carries its own `@MainActor @Sendable` action closure, which keeps
/// the type `Sendable` without being `Equatable` (closures are not comparable).
public struct DFMenuItem: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let systemImage: String?
    public let role: DFMenuItemRole?
    /// Renders a trailing checkmark (and a "Selected" VoiceOver value) when `true`.
    public let isSelected: Bool
    public let isDisabled: Bool
    public let action: (@MainActor @Sendable () -> Void)?

    public init(
        id: String = UUID().uuidString,
        title: String,
        systemImage: String? = nil,
        role: DFMenuItemRole? = nil,
        isSelected: Bool = false,
        isDisabled: Bool = false,
        action: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.action = action
    }
}

// MARK: - Section

/// A group of items, optionally headed by a title. Sections are separated by a divider.
public struct DFMenuSection: Identifiable, Sendable {
    public let id: String
    public let title: String?
    public let items: [DFMenuItem]

    public init(
        id: String = UUID().uuidString,
        title: String? = nil,
        items: [DFMenuItem]
    ) {
        self.id = id
        self.title = title
        self.items = items
    }
}

// MARK: - Logic

/// Pure, testable menu logic (filtering, selection, disabled handling, accessibility text).
///
/// Kept separate from the views, like `DFCommandPaletteFilter`, so behavior can be unit tested
/// without instantiating SwiftUI.
public enum DFMenuLogic {
    /// Drops sections that contain no items, preserving order.
    public static func visibleSections(_ sections: [DFMenuSection]) -> [DFMenuSection] {
        sections.filter { !$0.items.isEmpty }
    }

    /// Case-insensitive substring match on item title. An empty or whitespace-only query returns
    /// the input unchanged. Sections left with no matching items are removed.
    public static func filter(sections: [DFMenuSection], query: String) -> [DFMenuSection] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return sections }
        let needle = trimmed.lowercased()
        var result: [DFMenuSection] = []
        for section in sections {
            let matching = section.items.filter { $0.title.lowercased().contains(needle) }
            if !matching.isEmpty {
                result.append(DFMenuSection(id: section.id, title: section.title, items: matching))
            }
        }
        return result
    }

    /// Every item across all sections, in display order.
    public static func allItems(in sections: [DFMenuSection]) -> [DFMenuItem] {
        sections.flatMap { $0.items }
    }

    /// Items that can currently be activated (not disabled), in display order.
    public static func enabledItems(in sections: [DFMenuSection]) -> [DFMenuItem] {
        allItems(in: sections).filter { isActionable($0) }
    }

    /// Items currently marked selected, in display order.
    public static func selectedItems(in sections: [DFMenuSection]) -> [DFMenuItem] {
        allItems(in: sections).filter { $0.isSelected }
    }

    /// The first item with the given id, if any.
    public static func item(withID id: String, in sections: [DFMenuSection]) -> DFMenuItem? {
        allItems(in: sections).first { $0.id == id }
    }

    /// `true` unless the item is disabled.
    public static func isActionable(_ item: DFMenuItem) -> Bool {
        !item.isDisabled
    }

    /// Runs the item's action unless it is disabled. Returns whether the item was activated.
    @MainActor
    @discardableResult
    public static func activate(_ item: DFMenuItem) -> Bool {
        guard isActionable(item) else { return false }
        item.action?()
        return true
    }

    /// VoiceOver value for the item: "Selected" when checked, otherwise empty.
    public static func accessibilityValue(for item: DFMenuItem) -> String {
        item.isSelected ? "Selected" : ""
    }

    /// VoiceOver hint for the item: "Destructive action" for the destructive role, otherwise empty.
    public static func accessibilityHint(for item: DFMenuItem) -> String {
        item.role == .destructive ? "Destructive action" : ""
    }
}
