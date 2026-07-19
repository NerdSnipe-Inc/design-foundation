import SwiftUI

// MARK: - Line Item

public enum DFPriceLineItemEmphasis: Sendable {
    case normal
    case total
}

public struct DFPriceLineItem: Sendable, Identifiable {
    public let id: String
    public let label: String
    public let amount: Decimal
    public let emphasis: DFPriceLineItemEmphasis

    public init(
        id: String = UUID().uuidString,
        label: String,
        amount: Decimal,
        emphasis: DFPriceLineItemEmphasis = .normal
    ) {
        self.id = id
        self.label = label
        self.amount = amount
        self.emphasis = emphasis
    }
}

// MARK: - View

public struct DFPriceSummaryView: View {
    private let lineItems: [DFPriceLineItem]
    private let currencyCode: String

    @Environment(\.dfTheme) private var theme

    public init(lineItems: [DFPriceLineItem], currencyCode: String = "USD") {
        self.lineItems = lineItems
        self.currencyCode = currencyCode
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.components.priceSummary.rowSpacing ?? theme.spacing.xs) {
            ForEach(lineItems, id: \.id) { item in
                row(for: item)
            }
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func row(for item: DFPriceLineItem) -> some View {
        let isTotal = item.emphasis == .total
        let rowSpacing = theme.components.priceSummary.rowSpacing ?? theme.spacing.xs

        if isTotal {
            DFDivider().padding(.vertical, rowSpacing)
        }
        HStack {
            Text(item.label)
                .font(isTotal ? theme.typography.headline.font : theme.typography.body.font)
                .foregroundStyle(isTotal ? theme.colors.textPrimary : theme.colors.textSecondary)
            Spacer()
            if isTotal {
                DFPriceView(amount: item.amount, currencyCode: currencyCode)
                    .dfPriceViewStyle(.standard)
            } else {
                DFPriceView(amount: item.amount, currencyCode: currencyCode)
                    .dfPriceViewStyle(.compact)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
