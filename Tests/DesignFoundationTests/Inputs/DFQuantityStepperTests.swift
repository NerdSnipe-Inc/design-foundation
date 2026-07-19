import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFQuantityStepperStyleConfiguration")
struct DFQuantityStepperStyleConfigurationTests {
    @Test("holds value and range")
    func holdsCoreValues() {
        let config = DFQuantityStepperStyleConfiguration(
            value: 3,
            range: 0...10,
            isDisabled: false,
            theme: .default,
            onIncrement: {},
            onDecrement: {}
        )
        #expect(config.value == 3)
        #expect(config.range == 0...10)
        #expect(!config.isDisabled)
    }

    @Test("canIncrement/canDecrement reflect range bounds")
    func canIncrementDecrementReflectBounds() {
        let atMin = DFQuantityStepperStyleConfiguration(value: 0, range: 0...10, isDisabled: false, theme: .default, onIncrement: {}, onDecrement: {})
        #expect(!atMin.canDecrement)
        #expect(atMin.canIncrement)

        let atMax = DFQuantityStepperStyleConfiguration(value: 10, range: 0...10, isDisabled: false, theme: .default, onIncrement: {}, onDecrement: {})
        #expect(atMax.canDecrement)
        #expect(!atMax.canIncrement)
    }

    @Test("onIncrement and onDecrement callbacks fire")
    @MainActor
    func callbacksFire() {
        var incremented = false
        var decremented = false
        let config = DFQuantityStepperStyleConfiguration(
            value: 5,
            range: 0...10,
            isDisabled: false,
            theme: .default,
            onIncrement: { incremented = true },
            onDecrement: { decremented = true }
        )
        config.onIncrement()
        config.onDecrement()
        #expect(incremented)
        #expect(decremented)
    }
}

@Suite("DFQuantityStepper Environment")
struct DFQuantityStepperEnvironmentTests {
    @Test("dfQuantityStepperStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfQuantityStepperStyle
    }
}

@Suite("DFQuantityStepperTokens")
struct DFQuantityStepperTokensTests {
    @Test("default tokens are nil (inherit from theme)")
    func defaultTokensAreNil() {
        #expect(DFQuantityStepperTokens.default.buttonSize == nil)
        #expect(DFQuantityStepperTokens.default.cornerRadius == nil)
    }
}
