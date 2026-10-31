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

    @Test("locale defaults to autoupdatingCurrent")
    func localeDefaultsToAutoupdatingCurrent() {
        let config = DFPriceStyleConfiguration(amount: 10, currencyCode: "USD", compareAtAmount: nil, theme: .default)
        #expect(config.locale == .autoupdatingCurrent)
    }

    @Test("an explicit locale is stored as given")
    func explicitLocaleIsStored() {
        let config = DFPriceStyleConfiguration(
            amount: 10, currencyCode: "USD", compareAtAmount: nil, theme: .default, locale: Locale(identifier: "de_DE")
        )
        #expect(config.locale == Locale(identifier: "de_DE"))
    }
}

@Suite("DFPriceView formatting")
struct DFPriceViewFormattingTests {
    @Test("formattedAmount produces a non-empty currency string")
    func formattedAmountNonEmpty() {
        let formatted = DFPriceView.formattedAmount(34.99, currencyCode: "USD")
        #expect(!formatted.isEmpty)
    }

    @Test("formattedAmount respects an explicit locale (German uses a comma decimal separator)")
    func formattedAmountRespectsLocale() {
        let german = DFPriceView.formattedAmount(1234.5, currencyCode: "EUR", locale: Locale(identifier: "de_DE"))
        #expect(german.contains(","))
    }

    @Test("formattedAmount differs between distinct locales for the same amount")
    func formattedAmountDiffersAcrossLocales() {
        let us = DFPriceView.formattedAmount(1234.5, currencyCode: "USD", locale: Locale(identifier: "en_US"))
        let de = DFPriceView.formattedAmount(1234.5, currencyCode: "USD", locale: Locale(identifier: "de_DE"))
        #expect(us != de)
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
