import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFNavigationBarDisplayMode")
struct DFNavigationBarDisplayModeTests {
    @Test("all cases are Sendable")
    func casesAreSendable() {
        let _: DFNavigationBarDisplayMode = .automatic
        let _: DFNavigationBarDisplayMode = .large
        let _: DFNavigationBarDisplayMode = .inline
    }
}

@Suite("DFNavigationBarStyleConfiguration")
struct DFNavigationBarStyleConfigurationTests {
    @Test("holds content and theme")
    func holdsValues() {
        let config = DFNavigationBarStyleConfiguration(
            content: AnyView(EmptyView()),
            theme: .default
        )
        let _ = config.content
        #expect(config.theme.radius.lg == DFTheme.default.radius.lg)
    }
}

@Suite("DFNavigationBar Environment")
struct DFNavigationBarEnvironmentTests {
    @Test("dfNavigationBarStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfNavigationBarStyle
    }
}

@Suite("DFNavigationBar Styles")
struct DFNavigationBarStyleTests {
    @Test("standard style is Sendable")
    func standardSendable() {
        let _: any DFNavigationBarStyle & Sendable = DFStandardNavigationBarStyle()
    }

    @Test("transparent style is Sendable")
    func transparentSendable() {
        let _: any DFNavigationBarStyle & Sendable = DFTransparentNavigationBarStyle()
    }

    @Test("AnyDFNavigationBarStyle wraps and invokes makeBody")
    func typeErasure() {
        let style = AnyDFNavigationBarStyle(DFStandardNavigationBarStyle())
        let config = DFNavigationBarStyleConfiguration(
            content: AnyView(EmptyView()),
            theme: .default
        )
        let _ = style.makeBody(configuration: config)
    }
}

@Suite("DFGlassNavigationBarStyle")
struct DFGlassNavigationBarStyleTests {
    @Test("glass style is instantiatable")
    func glassInstantiates() {
        if #available(iOS 26, macOS 26, *) {
            let _ = DFGlassNavigationBarStyle()
        }
    }
}
