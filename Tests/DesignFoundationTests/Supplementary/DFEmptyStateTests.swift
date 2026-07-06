import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFEmptyStateStyleConfiguration")
struct DFEmptyStateStyleConfigurationTests {
    @Test("configuration holds all provided values")
    @MainActor
    func configurationHoldsValues() {
        var actionFired = false
        let config = DFEmptyStateStyleConfiguration(
            icon: "tray",
            title: "No items",
            message: "Nothing to show here",
            actionTitle: "Retry",
            onAction: { actionFired = true },
            theme: .default
        )

        #expect(config.icon == "tray")
        #expect(config.title == "No items")
        #expect(config.message == "Nothing to show here")
        #expect(config.actionTitle == "Retry")
        config.onAction?()
        #expect(actionFired == true)
    }

    @Test("message is optional — nil when omitted")
    func messageIsOptional() {
        let config = DFEmptyStateStyleConfiguration(
            icon: "tray",
            title: "No items",
            message: nil,
            actionTitle: nil,
            onAction: nil,
            theme: .default
        )
        #expect(config.message == nil)
    }

    @Test("actionTitle is optional — nil when omitted")
    func actionTitleIsOptional() {
        let config = DFEmptyStateStyleConfiguration(
            icon: "tray",
            title: "No items",
            message: nil,
            actionTitle: nil,
            onAction: nil,
            theme: .default
        )
        #expect(config.actionTitle == nil)
    }

    @Test("onAction is optional — nil when omitted, not a no-op closure")
    func onActionIsOptional() {
        let config = DFEmptyStateStyleConfiguration(
            icon: "tray",
            title: "No items",
            message: nil,
            actionTitle: nil,
            onAction: nil,
            theme: .default
        )
        #expect(config.onAction == nil)
    }
}

@Suite("DFEmptyState Environment")
struct DFEmptyStateEnvironmentTests {
    @Test("dfEmptyStateStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfEmptyStateStyle
    }
}
