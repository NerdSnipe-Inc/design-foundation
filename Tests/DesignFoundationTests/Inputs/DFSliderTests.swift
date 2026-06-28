import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFSliderStyleConfiguration")
struct DFSliderStyleConfigurationTests {
    @Test("configuration is Sendable")
    func configurationIsSendable() {
        func requiresSendable<T: Sendable>(_: T) {}
        let config = DFSliderStyleConfiguration(
            label: "Volume",
            value: .constant(0.5),
            range: 0...1,
            step: nil,
            isDisabled: false,
            theme: .default
        )
        requiresSendable(config)
        #expect(config.label == "Volume")
        #expect(config.value.wrappedValue == 0.5)
        #expect(config.range == 0...1)
        #expect(config.step == nil)
    }

    @Test("configuration with step")
    func configurationWithStep() {
        let config = DFSliderStyleConfiguration(
            label: "Steps",
            value: .constant(50.0),
            range: 0...100,
            step: 10.0,
            isDisabled: false,
            theme: .default
        )
        #expect(config.step == 10.0)
        #expect(config.range == 0...100)
    }

    @Test("configuration with nil label")
    func configurationNilLabel() {
        let config = DFSliderStyleConfiguration(
            label: nil,
            value: .constant(0.0),
            range: 0...1,
            step: nil,
            isDisabled: false,
            theme: .default
        )
        #expect(config.label == nil)
    }
}

@Suite("DFSlider Environment")
struct DFSliderEnvironmentTests {
    @Test("dfSliderStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfSliderStyle
    }
}

@Suite("DFSlider Built-in Styles")
struct DFSliderBuiltinStyleTests {
    @Test("standard style instantiates")
    func standardInstantiates() {
        let _ = DFStandardSliderStyle()
    }

    @Test("labeled style instantiates")
    func labeledInstantiates() {
        let _ = DFLabeledSliderStyle()
    }
}
