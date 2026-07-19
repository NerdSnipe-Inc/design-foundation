import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFPriceStyleConfiguration")
struct DFPriceStyleConfigurationTests {
    @Test("holds amount, currency, and optional compare-at amount")
    func holdsCoreValues() {
        let config = DFPriceStyleConfiguration(
            amount: 34.99,
            currencyCode: "USD",
            compareAtAmount: 49.99,
            theme: .default
        )
        #expect(config.amount == 34.99)
        #expect(config.currencyCode == "USD")
        #expect(config.compareAtAmount == 49.99)
    }

    @Test("compareAtAmount defaults to nil")
    func compareAtAmountOptional() {
        let config = DFPriceStyleConfiguration(amount: 10, currencyCode: "USD", compareAtAmount: nil, theme: .default)
        #expect(config.compareAtAmount == nil)
    }
}

@Suite("DFPriceView formatting")
struct DFPriceViewFormattingTests {
    @Test("formattedAmount produces a non-empty currency string")
    func formattedAmountNonEmpty() {
        let formatted = DFPriceView.formattedAmount(34.99, currencyCode: "USD")
        #expect(!formatted.isEmpty)
    }
}

@Suite("DFPriceView Environment")
struct DFPriceViewEnvironmentTests {
    @Test("dfPriceViewStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfPriceViewStyle
    }
}

@Suite("DFPriceTokens")
struct DFPriceTokensTests {
    @Test("default tokens are all nil (inherit from theme)")
    func defaultTokensAreNil() {
        #expect(DFPriceTokens.default.spacing == nil)
    }
}
