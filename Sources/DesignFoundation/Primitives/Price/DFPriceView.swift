import SwiftUI

public struct DFPriceView: View {
    private let amount: Decimal
    private let currencyCode: String
    private let compareAtAmount: Decimal?

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfPriceViewStyle) private var style

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
            theme: theme
        )
        style.makeBody(configuration: config)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        let formatted = DFPriceView.formattedAmount(amount, currencyCode: currencyCode)
        if let compareAtAmount {
            let compareFormatted = DFPriceView.formattedAmount(compareAtAmount, currencyCode: currencyCode)
            return "\(formatted), was \(compareFormatted)"
        }
        return formatted
    }

    nonisolated static func formattedAmount(_ amount: Decimal, currencyCode: String) -> String {
        amount.formatted(.currency(code: currencyCode))
    }
}
