import SwiftUI

public struct DFPriceView: View {
    private let amount: Decimal
    private let currencyCode: String
    private let compareAtAmount: Decimal?

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfPriceViewStyle) private var style
    @Environment(\.locale) private var locale

    public init(amount: Decimal, currencyCode: String = "USD", compareAtAmount: Decimal? = nil) {
        self.amount = amount
        self.currencyCode = currencyCode
        self.compareAtAmount = compareAtAmount
    }

    public var body: some View {
        let config = DFPriceStyleConfiguration(
            amount: amount,
            currencyCode: currencyCode,
            compareAtAmount: compareAtAmount,
            theme: theme,
            locale: locale
        )
        style.makeBody(configuration: config)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        let formatted = DFPriceView.formattedAmount(amount, currencyCode: currencyCode, locale: locale)
        if let compareAtAmount {
            let compareFormatted = DFPriceView.formattedAmount(compareAtAmount, currencyCode: currencyCode, locale: locale)
            return "\(formatted), was \(compareFormatted)"
        }
        return formatted
    }

    /// `locale` defaults to `.autoupdatingCurrent` so existing call sites that don't pass one keep
    /// working; pass the view's `@Environment(\.locale)` to respect a locale override up the tree
    /// (SwiftUI previews, per-view `.environment(\.locale, ...)`, or a future app-level override).
    nonisolated static func formattedAmount(_ amount: Decimal, currencyCode: String, locale: Locale = .autoupdatingCurrent) -> String {
        amount.formatted(.currency(code: currencyCode).locale(locale))
    }
}
