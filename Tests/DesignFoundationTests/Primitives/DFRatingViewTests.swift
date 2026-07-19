import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFRatingMode")
struct DFRatingModeTests {
    @Test("readOnly mode is representable")
    func readOnlyRepresentable() {
        let mode = DFRatingMode.readOnly
        if case .readOnly = mode {
            // passes
        } else {
            Issue.record("Expected .readOnly mode")
        }
    }

    @Test("interactive mode holds a callback")
    @MainActor
    func interactiveModeHoldsCallback() {
        var received: Double?
        let mode = DFRatingMode.interactive(onChange: { received = $0 })
        if case .interactive(let onChange) = mode {
            onChange(4)
            #expect(received == 4)
        } else {
            Issue.record("Expected .interactive mode")
        }
    }
}

@Suite("DFRatingStyleConfiguration")
struct DFRatingStyleConfigurationTests {
    @Test("holds value, maxValue, and half-star flag")
    func holdsCoreValues() {
        let config = DFRatingStyleConfiguration(
            value: 3.5,
            maxValue: 5,
            allowsHalfStars: true,
            mode: .readOnly,
            theme: .default
        )
        #expect(config.value == 3.5)
        #expect(config.maxValue == 5)
        #expect(config.allowsHalfStars)
    }

    @Test("isInteractive reflects mode")
    func isInteractiveReflectsMode() {
        let readOnly = DFRatingStyleConfiguration(value: 3, maxValue: 5, allowsHalfStars: true, mode: .readOnly, theme: .default)
        #expect(!readOnly.isInteractive)

        let interactive = DFRatingStyleConfiguration(value: 3, maxValue: 5, allowsHalfStars: true, mode: .interactive(onChange: { _ in }), theme: .default)
        #expect(interactive.isInteractive)
    }
}

@Suite("DFRatingView Environment")
struct DFRatingViewEnvironmentTests {
    @Test("dfRatingViewStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfRatingViewStyle
    }
}

@Suite("DFRatingTokens")
struct DFRatingTokensTests {
    @Test("default tokens are all nil (inherit from theme)")
    func defaultTokensAreNil() {
        let tokens = DFRatingTokens.default
        #expect(tokens.starSize == nil)
        #expect(tokens.spacing == nil)
    }
}
