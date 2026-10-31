import SwiftUI

public struct DFRelativeTimeTag: View {
    private let date: Date
    private let referenceDate: Date

    @Environment(\.dfTheme) private var theme
    @Environment(\.locale) private var locale

    public init(date: Date, referenceDate: Date = .now) {
        self.date = date
        self.referenceDate = referenceDate
    }

    /// The formatted relative-time string (e.g. "3 hours ago"), exposed for testing
    /// without requiring a SwiftUI render pass.
    public var formattedText: String {
        DFRelativeTimeTag.formattedText(for: date, relativeTo: referenceDate, locale: locale)
    }

    /// `locale` defaults to `.autoupdatingCurrent` so this stays usable without a SwiftUI
    /// environment (e.g. in tests); the view itself passes its `@Environment(\.locale)`.
    nonisolated static func formattedText(for date: Date, relativeTo referenceDate: Date, locale: Locale = .autoupdatingCurrent) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = locale
        return formatter.localizedString(for: date, relativeTo: referenceDate)
    }

    public var body: some View {
        Text(formattedText)
            .font(theme.typography.caption.font)
            .foregroundStyle(theme.colors.textSecondary)
            .accessibilityLabel(formattedText)
    }
}
