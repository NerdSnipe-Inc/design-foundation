import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFCommandPaletteFilter")
struct DFCommandPaletteFilterTests {
    private let items: [DFCommandPaletteItem] = [
        DFCommandPaletteItem(id: "1", title: "New Document", subtitle: "Create a blank document"),
        DFCommandPaletteItem(id: "2", title: "New Folder", subtitle: "Create a folder"),
        DFCommandPaletteItem(id: "3", title: "Open Settings", subtitle: "App preferences"),
        DFCommandPaletteItem(id: "4", title: "Sign Out", subtitle: nil),
    ]

    @Test("empty query returns all items in original order")
    func emptyQueryReturnsAll() {
        let result = DFCommandPaletteFilter.filter(items: items, query: "")
        #expect(result.map(\.id) == ["1", "2", "3", "4"])
    }

    @Test("whitespace-only query returns all items")
    func whitespaceQueryReturnsAll() {
        let result = DFCommandPaletteFilter.filter(items: items, query: "   ")
        #expect(result.count == items.count)
    }

    @Test("matches on title, case-insensitively")
    func matchesTitleCaseInsensitive() {
        let result = DFCommandPaletteFilter.filter(items: items, query: "new")
        #expect(result.map(\.id) == ["1", "2"])
    }

    @Test("matches on subtitle")
    func matchesSubtitle() {
        let result = DFCommandPaletteFilter.filter(items: items, query: "preferences")
        #expect(result.map(\.id) == ["3"])
    }

    @Test("item with nil subtitle is not matched by unrelated query")
    func nilSubtitleDoesNotCrash() {
        let result = DFCommandPaletteFilter.filter(items: items, query: "out")
        #expect(result.map(\.id) == ["4"])
    }

    @Test("no matches returns empty array")
    func noMatchesReturnsEmpty() {
        let result = DFCommandPaletteFilter.filter(items: items, query: "zzz-nonexistent")
        #expect(result.isEmpty)
    }

    @Test("substring match works mid-word")
    func substringMatchMidWord() {
        let result = DFCommandPaletteFilter.filter(items: items, query: "old")
        #expect(result.map(\.id) == ["2"])
    }
}

@Suite("DFCommandPaletteItem")
struct DFCommandPaletteItemTests {
    @Test("initializes with defaults")
    func initializesWithDefaults() {
        let item = DFCommandPaletteItem(title: "Test")
        #expect(item.title == "Test")
        #expect(item.subtitle == nil)
        #expect(item.icon == nil)
        #expect(!item.id.isEmpty)
    }

    @Test("initializes with explicit id, subtitle, and icon")
    func initializesWithAllFields() {
        let item = DFCommandPaletteItem(id: "abc", title: "Test", subtitle: "Sub", icon: "star")
        #expect(item.id == "abc")
        #expect(item.title == "Test")
        #expect(item.subtitle == "Sub")
        #expect(item.icon == "star")
    }
}

@Suite("DFCommandPaletteStyleConfiguration")
struct DFCommandPaletteStyleConfigurationTests {
    @Test("holds content and theme")
    func holdsValues() {
        let theme = DFTheme.default
        let config = DFCommandPaletteStyleConfiguration(
            content: AnyView(EmptyView()),
            theme: theme
        )
        #expect(config.theme.spacing.md == theme.spacing.md)
    }
}

@Suite("DFCommandPalette Environment")
struct DFCommandPaletteEnvironmentTests {
    @Test("dfCommandPaletteStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfCommandPaletteStyle
    }
}

@Suite("DFCommandPalette Styles")
struct DFCommandPaletteStyleTests {
    @Test("standard style is Sendable")
    func standardSendable() {
        let _: any DFCommandPaletteStyle & Sendable = DFStandardCommandPaletteStyle()
    }
}
