import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFModalStyleConfiguration")
struct DFModalStyleConfigurationTests {
    @Test("holds content and theme")
    func holdsValues() {
        let theme = DFTheme.default
        let config = DFModalStyleConfiguration(
            content: AnyView(EmptyView()),
            theme: theme
        )
        #expect(config.theme.colors.background == theme.colors.background)
    }
}

@Suite("DFModal Environment")
struct DFModalEnvironmentTests {
    @Test("dfModalStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfModalStyle
    }
}

@Suite("DFModal Styles")
struct DFModalStyleTests {
    @Test("standard style is Sendable")
    func standardSendable() {
        let _: any DFModalStyle & Sendable = DFStandardModalStyle()
    }

    @Test("AnyDFModalStyle wraps and invokes makeBody")
    func typeErasure() {
        let style = AnyDFModalStyle(DFStandardModalStyle())
        let config = DFModalStyleConfiguration(
            content: AnyView(EmptyView()),
            theme: .default
        )
        let _ = style.makeBody(configuration: config)
    }
}

@Suite("DFGlassModalStyle")
struct DFGlassModalStyleTests {
    @Test("glass style is instantiatable")
    func glassInstantiates() {
        if #available(iOS 26, macOS 26, *) {
            let _ = DFGlassModalStyle()
        }
    }
}
