import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTabItem")
struct DFTabItemTests {
    @Test("initializes with required fields and correct defaults")
    func initialization() {
        let item = DFTabItem(id: "home", icon: "house", label: "Home")
        #expect(item.id == "home")
        #expect(item.icon == "house")
        #expect(item.label == "Home")
        #expect(item.badgeCount == nil)
        #expect(item.showDot == false)
    }

    @Test("badge count stored correctly")
    func badgeCount() {
        let item = DFTabItem(id: "inbox", icon: "tray", label: "Inbox", badgeCount: 5)
        #expect(item.badgeCount == 5)
    }
}

@Suite("DFTabBarStyleConfiguration")
struct DFTabBarStyleConfigurationTests {
    @Test("holds items, selectedID and theme")
    func holdsValues() {
        let items = [DFTabItem(id: "home", icon: "house", label: "Home")]
        let config = DFTabBarStyleConfiguration(
            items: items,
            selectedID: "home",
            onSelect: { _ in },
            theme: .default
        )
        #expect(config.items.count == 1)
        #expect(config.selectedID == "home")
    }
}

@Suite("DFTabBar Environment")
struct DFTabBarEnvironmentTests {
    @Test("dfTabBarStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfTabBarStyle
    }
}

@Suite("DFTabBar Styles")
struct DFTabBarStyleTests {
    @Test("standard style is Sendable")
    func standardSendable() {
        let _: any DFTabBarStyle & Sendable = DFStandardTabBarStyle()
    }

    @Test("minimal style is Sendable")
    func minimalSendable() {
        let _: any DFTabBarStyle & Sendable = DFMinimalTabBarStyle()
    }

    @Test("AnyDFTabBarStyle wraps and invokes makeBody")
    @MainActor func typeErasure() {
        let style = AnyDFTabBarStyle(DFStandardTabBarStyle())
        let items = [DFTabItem(id: "a", icon: "house", label: "Home")]
        let config = DFTabBarStyleConfiguration(
            items: items,
            selectedID: "a",
            onSelect: { _ in },
            theme: .default
        )
        let _ = style.makeBody(configuration: config)
    }
}

@Suite("DFGlassTabBarStyle")
struct DFGlassTabBarStyleTests {
    @Test("glass style is instantiatable")
    func glassInstantiates() {
        if #available(iOS 26, macOS 26, *) {
            let _ = DFGlassTabBarStyle()
        }
    }
}
