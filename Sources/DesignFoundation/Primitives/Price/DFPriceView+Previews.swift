import SwiftUI

#if DEBUG

#Preview("Plain and discounted") {
    VStack(alignment: .leading, spacing: 12) {
        DFPriceView(amount: 49.99)
        DFPriceView(amount: 34.99, compareAtAmount: 49.99)
    }
    .padding()
}

#Preview("All styles") {
    VStack(alignment: .leading, spacing: 12) {
        DFPriceView(amount: 34.99, compareAtAmount: 49.99).dfPriceViewStyle(.standard)
        DFPriceView(amount: 34.99, compareAtAmount: 49.99).dfPriceViewStyle(.compact)
    }
    .padding()
}

#Preview("Dark mode") {
    DFPriceView(amount: 34.99, compareAtAmount: 49.99)
        .padding()
        .preferredColorScheme(.dark)
}

#endif
