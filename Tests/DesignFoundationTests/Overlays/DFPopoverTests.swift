import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFPopoverStyleConfiguration")
struct DFPopoverStyleConfigurationTests {
    @Test("holds content and theme")
    func holdsValues() {
        let theme = DFTheme.default
        let config = DFPopoverStyleConfiguration(
            content: AnyView(EmptyView()),
            theme: theme
        )
        #expect(config.theme.spacing.sm == theme.spacing.sm)
    }
}

@Suite("DFPopover Environment")
struct DFPopoverEnvironmentTests {
    @Test("dfPopoverStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfPopoverStyle
    }
}

@Suite("DFPopover Styles")
struct DFPopoverStyleTests {
    @Test("arrow style is Sendable")
    func arrowSendable() {
        let _: any DFPopoverStyle & Sendable = DFArrowPopoverStyle()
    }

    @Test("compact style is Sendable")
    func compactSendable() {
        let _: any DFPopoverStyle & Sendable = DFCompactPopoverStyle()
    }
}

@Suite("DFGlassPopoverStyle")
struct DFGlassPopoverStyleTests {
    @Test("glass style is instantiatable")
    func glassInstantiates() {
        if #available(iOS 26, macOS 26, *) {
            let _ = DFGlassPopoverStyle()
        }
    }
}
