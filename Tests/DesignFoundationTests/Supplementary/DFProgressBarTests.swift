import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFProgressBarVariant")
struct DFProgressBarVariantTests {
    @Test("variants are Equatable")
    func equatable() {
        #expect(DFProgressBarVariant.linear == .linear)
        #expect(DFProgressBarVariant.circular == .circular)
        #expect(DFProgressBarVariant.indeterminate == .indeterminate)
        #expect(DFProgressBarVariant.linear != .circular)
    }
}

@Suite("DFProgressBarStyleConfiguration")
struct DFProgressBarStyleConfigurationTests {
    @Test("holds all values correctly")
    func holdsValues() {
        let config = DFProgressBarStyleConfiguration(
            variant: .circular,
            value: 0.75,
            label: "Loading",
            theme: .default
        )
        #expect(config.variant == .circular)
        #expect(config.value == 0.75)
        #expect(config.label == "Loading")
    }
}

@Suite("DFProgressBar Environment")
struct DFProgressBarEnvironmentTests {
    @Test("dfProgressBarStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfProgressBarStyle
    }
}

@Suite("DFProgressBar Styles")
struct DFProgressBarStyleTests {
    @Test("default style is Sendable")
    func defaultSendable() {
        let _: any DFProgressBarStyle & Sendable = DFDefaultProgressBarStyle()
    }

    @Test("AnyDFProgressBarStyle wraps and invokes makeBody")
    func typeErasure() {
        let style = AnyDFProgressBarStyle(DFDefaultProgressBarStyle())
        let config = DFProgressBarStyleConfiguration(variant: .linear, value: 0.5, label: nil, theme: .default)
        let _ = style.makeBody(configuration: config)
    }
}
