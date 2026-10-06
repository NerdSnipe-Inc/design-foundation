import Testing
import SwiftUI
@testable import DesignFoundation

private let menuSections: [DFMenuSection] = [
    DFMenuSection(id: "sort", title: "Sort by", items: [
        DFMenuItem(id: "name", title: "Name", isSelected: true),
        DFMenuItem(id: "date", title: "Date"),
        DFMenuItem(id: "size", title: "Size", isDisabled: true),
    ]),
    DFMenuSection(id: "empty", items: []),
    DFMenuSection(id: "danger", items: [
        DFMenuItem(id: "delete", title: "Delete forever", role: .destructive),
    ]),
]

@Suite("DFMenuLogic sections")
struct DFMenuLogicSectionTests {
    @Test("visibleSections drops empty sections")
    func dropsEmpty() {
        let ids = DFMenuLogic.visibleSections(menuSections).map(\.id)
        #expect(ids == ["sort", "danger"])
    }

    @Test("empty query returns sections unchanged")
    func emptyQuery() {
        #expect(DFMenuLogic.filter(sections: menuSections, query: "  ").count == menuSections.count)
    }

    @Test("filter is case-insensitive and drops sections with no matches")
    func filterMatches() {
        let result = DFMenuLogic.filter(sections: menuSections, query: "DEL")
        #expect(result.map(\.id) == ["danger"])
        #expect(result.first?.items.map(\.id) == ["delete"])
    }

    @Test("filter keeps section title and only matching items")
    func filterKeepsTitle() {
        let result = DFMenuLogic.filter(sections: menuSections, query: "da")
        #expect(result.count == 1)
        #expect(result.first?.title == "Sort by")
        #expect(result.first?.items.map(\.id) == ["date"])
    }
}

@Suite("DFMenuLogic items")
struct DFMenuLogicItemTests {
    @Test("allItems flattens in order")
    func flatten() {
        #expect(DFMenuLogic.allItems(in: menuSections).map(\.id) == ["name", "date", "size", "delete"])
    }

    @Test("enabledItems excludes disabled")
    func enabled() {
        #expect(DFMenuLogic.enabledItems(in: menuSections).map(\.id) == ["name", "date", "delete"])
    }

    @Test("selectedItems returns checked items")
    func selected() {
        #expect(DFMenuLogic.selectedItems(in: menuSections).map(\.id) == ["name"])
    }

    @Test("item(withID:) finds or returns nil")
    func lookup() {
        #expect(DFMenuLogic.item(withID: "date", in: menuSections)?.title == "Date")
        #expect(DFMenuLogic.item(withID: "nope", in: menuSections) == nil)
    }

    @Test("accessibility value and hint")
    func accessibility() {
        let selected = DFMenuItem(title: "A", isSelected: true)
        let destructive = DFMenuItem(title: "B", role: .destructive)
        let plain = DFMenuItem(title: "C")
        #expect(DFMenuLogic.accessibilityValue(for: selected) == "Selected")
        #expect(DFMenuLogic.accessibilityValue(for: plain) == "")
        #expect(DFMenuLogic.accessibilityHint(for: destructive) == "Destructive action")
        #expect(DFMenuLogic.accessibilityHint(for: plain) == "")
    }
}

@MainActor
@Suite("DFMenuLogic activation")
struct DFMenuLogicActivationTests {
    private final class Counter: @unchecked Sendable {
        var count = 0
    }

    @Test("activate runs the action and reports true")
    func runsAction() {
        let counter = Counter()
        let item = DFMenuItem(title: "Go") { counter.count += 1 }
        #expect(DFMenuLogic.activate(item))
        #expect(counter.count == 1)
    }

    @Test("activate skips disabled items")
    func skipsDisabled() {
        let counter = Counter()
        let item = DFMenuItem(title: "Go", isDisabled: true) { counter.count += 1 }
        #expect(!DFMenuLogic.activate(item))
        #expect(counter.count == 0)
    }

    @Test("activate with no action still reports true")
    func noAction() {
        #expect(DFMenuLogic.activate(DFMenuItem(title: "Noop")))
    }
}

@Suite("DFMenu styles")
struct DFMenuStyleTests {
    @Test("configuration holds content and theme")
    func configuration() {
        let theme = DFTheme.default
        let config = DFMenuStyleConfiguration(content: AnyView(EmptyView()), theme: theme)
        #expect(config.theme.spacing.sm == theme.spacing.sm)
    }

    @Test("environment key has a default")
    func environmentDefault() {
        let values = EnvironmentValues()
        let _ = values.dfMenuStyle
    }

    @Test("built-in styles are Sendable")
    func sendable() {
        let _: any DFMenuStyle & Sendable = DFStandardMenuStyle()
        let _: any DFMenuStyle & Sendable = DFCompactMenuStyle()
    }

    @Test("glass style is instantiatable")
    func glass() {
        if #available(iOS 26, macOS 26, *) {
            let _ = DFGlassMenuStyle()
        }
    }

    @Test("role maps to destructive button role")
    func role() {
        #expect(DFMenuItemRole.destructive.buttonRole == .destructive)
    }
}
