import SwiftUI

public struct DFRelativeTimeTag: View {
    private let date: Date
    private let referenceDate: Date

    @Environment(\.dfTheme) private var theme

    public init(date: Date, referenceDate: Date = .now) {
        self.date = date
        self.referenceDate = referenceDate
    }

    /// The formatted relative-time string (e.g. "3 hours ago"), exposed for testing
    /// without requiring a SwiftUI render pass.
    public var formattedText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: referenceDate)
    }

    public var body: some View {
        Text(formattedText)
            .font(theme.typography.caption.font)
            .foregroundStyle(theme.colors.textSecondary)
            .accessibilityLabel(formattedText)
    }
}
