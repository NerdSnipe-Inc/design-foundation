import SwiftUI

#if DEBUG

#Preview("Order summary") {
    DFPriceSummaryView(lineItems: [
        DFPriceLineItem(label: "Subtotal", amount: 89.97),
        DFPriceLineItem(label: "Shipping", amount: 4.99),
        DFPriceLineItem(label: "Tax", amount: 7.60),
        DFPriceLineItem(label: "Total", amount: 102.56, emphasis: .total),
    ])
    .padding()
}

#Preview("Dark mode") {
    DFPriceSummaryView(lineItems: [
        DFPriceLineItem(label: "Subtotal", amount: 89.97),
        DFPriceLineItem(label: "Total", amount: 89.97, emphasis: .total),
    ])
    .padding()
    .preferredColorScheme(.dark)
}

#endif
