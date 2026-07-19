import SwiftUI

// MARK: - Configuration

public struct DFPriceStyleConfiguration: Sendable {
    public let amount: Decimal
    public let currencyCode: String
    public let compareAtAmount: Decimal?
    public let theme: DFTheme

    public init(amount: Decimal, currencyCode: String, compareAtAmount: Decimal?, theme: DFTheme) {
        self.amount = amount
        self.currencyCode = currencyCode
        self.compareAtAmount = compareAtAmount
        self.theme = theme
    }
}

// MARK: - Protocol

public protocol DFPriceViewStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: DFPriceStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFPriceViewStyle: DFPriceViewStyle, @unchecked Sendable {
    private let _makeBody: (DFPriceStyleConfiguration) -> AnyView

    public init<S: DFPriceViewStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: DFPriceStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFPriceViewStyleKey: EnvironmentKey {
    static let defaultValue = AnyDFPriceViewStyle(DFStandardPriceViewStyle())
}

public extension EnvironmentValues {
    var dfPriceViewStyle: AnyDFPriceViewStyle {
        get { self[DFPriceViewStyleKey.self] }
        set { self[DFPriceViewStyleKey.self] = newValue }
    }
}

public extension View {
    func dfPriceViewStyle<S: DFPriceViewStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfPriceViewStyle, AnyDFPriceViewStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFPriceViewStyle where Self == DFStandardPriceViewStyle {
    static var standard: DFStandardPriceViewStyle { DFStandardPriceViewStyle() }
}
public extension DFPriceViewStyle where Self == DFCompactPriceViewStyle {
    static var compact: DFCompactPriceViewStyle { DFCompactPriceViewStyle() }
}

// MARK: - Built-in: Standard (default)

public struct DFStandardPriceViewStyle: DFPriceViewStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPriceStyleConfiguration) -> some View {
        let theme = configuration.theme
        HStack(spacing: theme.components.price.spacing ?? theme.spacing.xs) {
            Text(DFPriceView.formattedAmount(configuration.amount, currencyCode: configuration.currencyCode))
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.textPrimary)

            if let compareAtAmount = configuration.compareAtAmount {
                Text(DFPriceView.formattedAmount(compareAtAmount, currencyCode: configuration.currencyCode))
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.textSecondary)
                    .strikethrough()
            }
        }
    }
}

// MARK: - Built-in: Compact

public struct DFCompactPriceViewStyle: DFPriceViewStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFPriceStyleConfiguration) -> some View {
        let theme = configuration.theme
        HStack(spacing: theme.components.price.spacing ?? theme.spacing.xs) {
            Text(DFPriceView.formattedAmount(configuration.amount, currencyCode: configuration.currencyCode))
                .font(theme.typography.caption.font)
                .foregroundStyle(theme.colors.textPrimary)

            if let compareAtAmount = configuration.compareAtAmount {
                Text(DFPriceView.formattedAmount(compareAtAmount, currencyCode: configuration.currencyCode))
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.textSecondary)
                    .strikethrough()
            }
        }
    }
}
