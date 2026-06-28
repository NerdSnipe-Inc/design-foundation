import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFSidebarItem")
struct DFSidebarItemTests {
    @Test("initializes with required fields and defaults")
    func initialization() {
        let item = DFSidebarItem(id: "home", icon: "house", label: "Home")
        #expect(item.id == "home")
        #expect(item.icon == "house")
        #expect(item.label == "Home")
        #expect(item.isEnabled == true)
    }

    @Test("icon is optional")
    func iconOptional() {
        let item = DFSidebarItem(id: "plain", label: "Plain Item")
        #expect(item.icon == nil)
    }
}

@Suite("DFSidebarSection")
struct DFSidebarSectionTests {
    @Test("initializes with title and items")
    func initialization() {
        let items = [DFSidebarItem(id: "a", label: "A")]
        let section = DFSidebarSection(id: "s1", title: "Section 1", items: items)
        #expect(section.title == "Section 1")
        #expect(section.items.count == 1)
        #expect(section.isCollapsible == false)
    }

    @Test("collapsible flag stored correctly")
    func collapsible() {
        let section = DFSidebarSection(id: "s1", items: [], isCollapsible: true)
        #expect(section.isCollapsible == true)
    }

    @Test("nil title for untitled section")
    func untitledSection() {
        let section = DFSidebarSection(id: "s1", items: [])
        #expect(section.title == nil)
    }
}

@Suite("DFSidebarItemStyleConfiguration")
struct DFSidebarItemStyleConfigurationTests {
    @Test("holds all values correctly")
    func holdsValues() {
        let item = DFSidebarItem(id: "home", label: "Home")
        let config = DFSidebarItemStyleConfiguration(
            item: item,
            isSelected: true,
            isEnabled: true,
            theme: .default
        )
        #expect(config.isSelected == true)
        #expect(config.isEnabled == true)
        #expect(config.item.id == "home")
    }
}

@Suite("DFSidebar Environment")
struct DFSidebarEnvironmentTests {
    @Test("dfSidebarStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfSidebarStyle
    }
}

@Suite("DFSidebar Styles")
struct DFSidebarStyleTests {
    @Test("standard style is Sendable")
    func standardSendable() {
        let _: any DFSidebarStyle & Sendable = DFStandardSidebarStyle()
    }

    @Test("plain style is Sendable")
    func plainSendable() {
        let _: any DFSidebarStyle & Sendable = DFPlainSidebarStyle()
    }

    @Test("AnyDFSidebarStyle wraps and invokes makeItemBody")
    func typeErasure() {
        let style = AnyDFSidebarStyle(DFStandardSidebarStyle())
        let item = DFSidebarItem(id: "a", label: "A")
        let config = DFSidebarItemStyleConfiguration(
            item: item,
            isSelected: false,
            isEnabled: true,
            theme: .default
        )
        let _ = style.makeItemBody(configuration: config)
    }
}

@Suite("DFGlassSidebarStyle")
struct DFGlassSidebarStyleTests {
    @Test("glass style is instantiatable")
    func glassInstantiates() {
        if #available(iOS 26, macOS 26, *) {
            let _ = DFGlassSidebarStyle()
        }
    }
}
