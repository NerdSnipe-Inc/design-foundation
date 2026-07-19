import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFBannerStyleConfiguration")
struct DFBannerStyleConfigurationTests {
    @Test("holds icon, message, and severity")
    func holdsCoreValues() {
        let config = DFBannerStyleConfiguration(
            icon: "info.circle.fill",
            message: "New version available.",
            severity: .info,
            actionTitle: nil,
            onAction: nil,
            isDismissible: false,
            onDismiss: nil,
            theme: .default
        )
        #expect(config.icon == "info.circle.fill")
        #expect(config.message == "New version available.")
        if case .info = config.severity {
            // passes
        } else {
            Issue.record("Expected .info severity")
        }
        #expect(!config.isDismissible)
    }

    @Test("action and dismiss callbacks fire")
    @MainActor
    func callbacksFire() {
        var actionFired = false
        var dismissFired = false
        let config = DFBannerStyleConfiguration(
            icon: nil,
            message: "Update ready",
            severity: .info,
            actionTitle: "Update",
            onAction: { actionFired = true },
            isDismissible: true,
            onDismiss: { dismissFired = true },
            theme: .default
        )
        config.onAction?()
        config.onDismiss?()
        #expect(actionFired)
        #expect(dismissFired)
    }
}

@Suite("DFBanner Environment")
struct DFBannerEnvironmentTests {
    @Test("dfBannerStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfBannerStyle
    }
}

@Suite("DFBannerTokens")
struct DFBannerTokensTests {
    @Test("default tokens are nil (inherit from theme)")
    func defaultTokensAreNil() {
        #expect(DFBannerTokens.default.cornerRadius == nil)
        #expect(DFBannerTokens.default.padding == nil)
    }
}
