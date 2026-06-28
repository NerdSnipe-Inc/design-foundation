import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFSheetStyleConfiguration")
struct DFSheetStyleConfigurationTests {
    @Test("holds content and theme")
    func holdsValues() {
        let theme = DFTheme.default
        let config = DFSheetStyleConfiguration(
            content: AnyView(EmptyView()),
            theme: theme
        )
        #expect(config.theme.spacing.md == theme.spacing.md)
    }
}

@Suite("DFSheet Environment")
struct DFSheetEnvironmentTests {
    @Test("dfSheetStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfSheetStyle
    }
}

@Suite("DFSheet Styles")
struct DFSheetStyleTests {
    @Test("standard style is Sendable")
    func standardSendable() {
        let _: any DFSheetStyle & Sendable = DFStandardSheetStyle()
    }

    @Test("compact style is Sendable")
    func compactSendable() {
        let _: any DFSheetStyle & Sendable = DFCompactSheetStyle()
    }
}

@Suite("DFGlassSheetStyle")
struct DFGlassSheetStyleTests {
    @Test("glass style is instantiatable")
    func glassInstantiates() {
        if #available(iOS 26, macOS 26, *) {
            let _ = DFGlassSheetStyle()
        }
    }
}
