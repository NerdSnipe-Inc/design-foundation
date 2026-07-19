import SwiftUI

// MARK: - Mode

public enum DFRatingMode: Sendable {
    case readOnly
    case interactive(onChange: @MainActor @Sendable (Double) -> Void)
}

// MARK: - Configuration

public struct DFRatingStyleConfiguration: Sendable {
    public let value: Double
    public let maxValue: Int
    public let allowsHalfStars: Bool
    public let mode: DFRatingMode
    public let theme: DFTheme

    public init(
        value: Double,
        maxValue: Int,
        allowsHalfStars: Bool,
        mode: DFRatingMode,
        theme: DFTheme
    ) {
        self.value = value
        self.maxValue = maxValue
        self.allowsHalfStars = allowsHalfStars
        self.mode = mode
        self.theme = theme
    }

    public var isInteractive: Bool {
        if case .interactive = mode { return true }
        return false
    }
}

// MARK: - Protocol

public protocol DFRatingViewStyle {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(configuration: DFRatingStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFRatingViewStyle: DFRatingViewStyle, @unchecked Sendable {
    private let _makeBody: @MainActor (DFRatingStyleConfiguration) -> AnyView

    public init<S: DFRatingViewStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    public func makeBody(configuration: DFRatingStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFRatingViewStyleKey: EnvironmentKey {
    static let defaultValue = AnyDFRatingViewStyle(DFStarsRatingStyle())
}

public extension EnvironmentValues {
    var dfRatingViewStyle: AnyDFRatingViewStyle {
        get { self[DFRatingViewStyleKey.self] }
        set { self[DFRatingViewStyleKey.self] = newValue }
    }
}

public extension View {
    func dfRatingViewStyle<S: DFRatingViewStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfRatingViewStyle, AnyDFRatingViewStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFRatingViewStyle where Self == DFStarsRatingStyle {
    static var stars: DFStarsRatingStyle { DFStarsRatingStyle() }
}
public extension DFRatingViewStyle where Self == DFNumericRatingStyle {
    static var numeric: DFNumericRatingStyle { DFNumericRatingStyle() }
}

// MARK: - Helper: fill fraction per star index

private func fillFraction(forStarAt index: Int, value: Double, allowsHalfStars: Bool) -> Double {
    let lower = Double(index)
    if value >= lower + 1 { return 1 }
    if value <= lower { return 0 }
    return allowsHalfStars ? 0.5 : 0
}

private func starSymbolName(fraction: Double) -> String {
    if fraction >= 1 { return "star.fill" }
    if fraction >= 0.5 { return "star.leadinghalf.filled" }
    return "star"
}

// MARK: - Built-in: Stars (default)

public struct DFStarsRatingStyle: DFRatingViewStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFRatingStyleConfiguration) -> some View {
        let theme = configuration.theme
        let starSize = theme.components.rating.starSize ?? 16
        let spacing = theme.components.rating.spacing ?? theme.spacing.xs

        HStack(spacing: spacing) {
            ForEach(0..<configuration.maxValue, id: \.self) { index in
                let fraction = fillFraction(
                    forStarAt: index,
                    value: configuration.value,
                    allowsHalfStars: configuration.allowsHalfStars
                )
                let star = Image(systemName: starSymbolName(fraction: fraction))
                    .font(.system(size: starSize))
                    .foregroundStyle(fraction > 0 ? theme.colors.warning : theme.colors.border)

                if case .interactive(let onChange) = configuration.mode {
                    Button {
                        onChange(Double(index + 1))
                    } label: {
                        star
                    }
                    .buttonStyle(.plain)
                } else {
                    star
                }
            }
        }
    }
}

// MARK: - Built-in: Numeric

public struct DFNumericRatingStyle: DFRatingViewStyle, Sendable {
    public init() {}

    public func makeBody(configuration: DFRatingStyleConfiguration) -> some View {
        let theme = configuration.theme
        let formatted = configuration.value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", configuration.value)
            : String(format: "%.1f", configuration.value)

        HStack(spacing: theme.components.rating.spacing ?? theme.spacing.xs) {
            Text(formatted)
                .font(theme.typography.label.font)
                .foregroundStyle(theme.colors.textPrimary)
            Image(systemName: "star.fill")
                .font(.system(size: (theme.components.rating.starSize ?? 16) * 0.75))
                .foregroundStyle(theme.colors.warning)
        }
    }
}
