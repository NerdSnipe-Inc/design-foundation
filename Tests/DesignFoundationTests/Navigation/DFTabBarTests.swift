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

    @Test("no badge or dot has no accessibility value")
    func noBadgeAccessibilityValue() {
        let item = DFTabItem(id: "home", icon: "house", label: "Home")
        #expect(item.badgeAccessibilityValue == nil)
    }

    @Test("badge count of 1 is singular")
    func singularBadgeAccessibilityValue() {
        let item = DFTabItem(id: "inbox", icon: "tray", label: "Inbox", badgeCount: 1)
        #expect(item.badgeAccessibilityValue == "1 notification")
    }

    @Test("badge count greater than 1 is plural")
    func pluralBadgeAccessibilityValue() {
        let item = DFTabItem(id: "inbox", icon: "tray", label: "Inbox", badgeCount: 5)
        #expect(item.badgeAccessibilityValue == "5 notifications")
    }

    @Test("a zero badge count has no accessibility value")
    func zeroBadgeAccessibilityValue() {
        let item = DFTabItem(id: "inbox", icon: "tray", label: "Inbox", badgeCount: 0)
        #expect(item.badgeAccessibilityValue == nil)
    }

    @Test("showDot without a count is announced as new activity")
    func dotAccessibilityValue() {
        let item = DFTabItem(id: "updates", icon: "bell", label: "Updates", showDot: true)
        #expect(item.badgeAccessibilityValue == "new activity")
    }

    @Test("a badge count takes precedence over showDot")
    func countTakesPrecedenceOverDot() {
        let item = DFTabItem(id: "inbox", icon: "tray", label: "Inbox", badgeCount: 2, showDot: true)
        #expect(item.badgeAccessibilityValue == "2 notifications")
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
