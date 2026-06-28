import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFCardStyleConfiguration")
struct DFCardStyleConfigurationTests {
    @Test("holds all values correctly")
    func holdsValues() {
        let theme = DFTheme.default
        let config = DFCardStyleConfiguration(
            content: AnyView(EmptyView()),
            isPressed: true,
            isDisabled: false,
            isInteractive: true,
            theme: theme
        )
        #expect(config.isPressed == true)
        #expect(config.isDisabled == false)
        #expect(config.isInteractive == true)
        #expect(config.theme.radius.lg == theme.radius.lg)
    }
}

@Suite("DFCard Environment")
struct DFCardEnvironmentTests {
    @Test("dfCardStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfCardStyle
    }
}

@Suite("DFCard Styles")
struct DFCardStyleTests {
    @Test("elevated style is Sendable")
    func elevatedSendable() {
        let _: any DFCardStyle & Sendable = DFElevatedCardStyle()
    }

    @Test("outlined style is Sendable")
    func outlinedSendable() {
        let _: any DFCardStyle & Sendable = DFOutlinedCardStyle()
    }

    @Test("filled style is Sendable")
    func filledSendable() {
        let _: any DFCardStyle & Sendable = DFFilledCardStyle()
    }

    @Test("AnyDFCardStyle wraps and invokes makeBody")
    func typeErasure() {
        let style = AnyDFCardStyle(DFElevatedCardStyle())
        let config = DFCardStyleConfiguration(
            content: AnyView(EmptyView()),
            isPressed: false,
            isDisabled: false,
            isInteractive: false,
            theme: .default
        )
        let _ = style.makeBody(configuration: config)
    }
}

@Suite("DFGlassCardStyle")
struct DFGlassCardStyleTests {
    @Test("glass style is instantiatable")
    func glassInstantiates() {
        if #available(iOS 26, macOS 26, *) {
            let _ = DFGlassCardStyle()
        }
    }
}
