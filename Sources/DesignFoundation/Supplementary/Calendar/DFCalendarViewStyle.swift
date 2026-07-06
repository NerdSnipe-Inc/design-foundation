import SwiftUI

// MARK: - Configuration

/// Not Sendable: holds AnyView-erased per-day content and UI closures (main-thread only).
public struct DFCalendarViewStyleConfiguration {
    public let displayedMonth: Date
    public let monthTitle: String
    /// Weeks in the currently displayed month; each week has 7 slots, `nil` marks a padding cell.
    public let weeks: [[Date?]]
    /// Weekday header symbols, already rotated to `calendar.firstWeekday`.
    public let weekdaySymbols: [String]
    public let selection: Date
    public let today: Date
    public let calendar: Calendar
    public let locale: Locale
    public let minimumDate: Date?
    public let maximumDate: Date?
    public let dayContent: @MainActor (Date) -> AnyView
    public let onSelect: @MainActor (Date) -> Void
    public let onPreviousMonth: @MainActor () -> Void
    public let onNextMonth: @MainActor () -> Void
    public let theme: DFTheme

    public init(
        displayedMonth: Date,
        monthTitle: String,
        weeks: [[Date?]],
        weekdaySymbols: [String],
        selection: Date,
        today: Date,
        calendar: Calendar,
        locale: Locale,
        minimumDate: Date?,
        maximumDate: Date?,
        dayContent: @escaping @MainActor (Date) -> AnyView,
        onSelect: @escaping @MainActor (Date) -> Void,
        onPreviousMonth: @escaping @MainActor () -> Void,
        onNextMonth: @escaping @MainActor () -> Void,
        theme: DFTheme
    ) {
        self.displayedMonth = displayedMonth
        self.monthTitle = monthTitle
        self.weeks = weeks
        self.weekdaySymbols = weekdaySymbols
        self.selection = selection
        self.today = today
        self.calendar = calendar
        self.locale = locale
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.dayContent = dayContent
        self.onSelect = onSelect
        self.onPreviousMonth = onPreviousMonth
        self.onNextMonth = onNextMonth
        self.theme = theme
    }

    func isSelected(_ date: Date) -> Bool {
        DFCalendarSupport.isSameDay(date, selection, calendar: calendar)
    }

    func isToday(_ date: Date) -> Bool {
        DFCalendarSupport.isSameDay(date, today, calendar: calendar)
    }

    func isDisabled(_ date: Date) -> Bool {
        DFCalendarSupport.isDisabled(date, minimum: minimumDate, maximum: maximumDate, calendar: calendar)
    }

    func accessibilityLabel(for date: Date) -> String {
        DFCalendarSupport.accessibilityDayLabel(for: date, calendar: calendar, locale: locale)
    }
}

// MARK: - Protocol

public protocol DFCalendarViewStyle {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(configuration: DFCalendarViewStyleConfiguration) -> Body
}

// MARK: - Type Erasure

public struct AnyDFCalendarViewStyle: DFCalendarViewStyle, @unchecked Sendable {
    private let _makeBody: @MainActor (DFCalendarViewStyleConfiguration) -> AnyView

    public init<S: DFCalendarViewStyle & Sendable>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor
    public func makeBody(configuration: DFCalendarViewStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment

private struct DFCalendarViewStyleKey: EnvironmentKey {
    static let defaultValue = AnyDFCalendarViewStyle(DFStandardCalendarViewStyle())
}

public extension EnvironmentValues {
    var dfCalendarViewStyle: AnyDFCalendarViewStyle {
        get { self[DFCalendarViewStyleKey.self] }
        set { self[DFCalendarViewStyleKey.self] = newValue }
    }
}

public extension View {
    func dfCalendarViewStyle<S: DFCalendarViewStyle & Sendable>(_ style: S) -> some View {
        environment(\.dfCalendarViewStyle, AnyDFCalendarViewStyle(style))
    }
}

// MARK: - Convenience static vars

public extension DFCalendarViewStyle where Self == DFStandardCalendarViewStyle {
    static var standard: DFStandardCalendarViewStyle { DFStandardCalendarViewStyle() }
}

// NOTE: A `.glass` style (iOS/macOS 26+, mirroring `DFGlassCardStyle`) is a natural follow-up
// for this component. Deferred from v1 to avoid guessing at `@available` interactions with the
// month-navigation header controls without a chance to verify against a real glass-styled
// navigation surface — see `DFCardStyle.swift`'s `DFGlassCardStyle` for the pattern to replicate.

// MARK: - Built-in: Standard

public struct DFStandardCalendarViewStyle: DFCalendarViewStyle, Sendable {
    public init() {}

    @MainActor
    public func makeBody(configuration: DFCalendarViewStyleConfiguration) -> some View {
        let theme = configuration.theme

        VStack(spacing: theme.spacing.md) {
            header(configuration: configuration, theme: theme)
            weekdayHeader(configuration: configuration, theme: theme)
            VStack(spacing: theme.spacing.xs) {
                ForEach(Array(configuration.weeks.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(Array(week.enumerated()), id: \.offset) { _, date in
                            dayCell(date: date, configuration: configuration, theme: theme)
                        }
                    }
                }
            }
        }
        .padding(theme.spacing.lg)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }

    @ViewBuilder
    @MainActor
    private func header(configuration: DFCalendarViewStyleConfiguration, theme: DFTheme) -> some View {
        let onPreviousMonth = configuration.onPreviousMonth
        let onNextMonth = configuration.onNextMonth
        let monthTitle = configuration.monthTitle

        HStack {
            Button(action: onPreviousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(theme.colors.textPrimary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Previous month")

            Spacer()

            Text(monthTitle)
                .font(theme.typography.headline.font)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Button(action: onNextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(theme.colors.textPrimary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Next month")
        }
    }

    @ViewBuilder
    @MainActor
    private func weekdayHeader(configuration: DFCalendarViewStyleConfiguration, theme: DFTheme) -> some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(Array(configuration.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
            }
        }
    }

    @ViewBuilder
    @MainActor
    private func dayCell(
        date: Date?,
        configuration: DFCalendarViewStyleConfiguration,
        theme: DFTheme
    ) -> some View {
        if let date {
            let isSelected = configuration.isSelected(date)
            let isToday = configuration.isToday(date)
            let isDisabled = configuration.isDisabled(date)
            let day = configuration.calendar.component(.day, from: date)
            let onSelect = configuration.onSelect
            let dayContentView = configuration.dayContent(date)
            let accessibilityLabel = configuration.accessibilityLabel(for: date)

            Button {
                onSelect(date)
            } label: {
                VStack(spacing: theme.spacing.xs / 2) {
                    Text("\(day)")
                        .font(theme.typography.body.font)
                        .foregroundStyle(
                            isSelected ? theme.colors.background : theme.colors.textPrimary
                        )
                    dayContentView
                }
                .frame(maxWidth: .infinity, minHeight: theme.spacing.xxl)
                .padding(.vertical, theme.spacing.xs)
                .background(
                    Circle()
                        .fill(isSelected ? theme.colors.primary : Color.clear)
                        .padding(theme.spacing.xs / 2)
                )
                .overlay(
                    Circle()
                        .stroke(theme.colors.primary, lineWidth: (isToday && !isSelected) ? 1.5 : 0)
                        .padding(theme.spacing.xs / 2)
                )
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.35 : 1.0)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            .accessibilityHint(isToday ? "Today" : "")
        } else {
            Color.clear
                .frame(maxWidth: .infinity, minHeight: theme.spacing.xxl)
                .accessibilityHidden(true)
        }
    }
}
