import SwiftUI

// MARK: - Date math support

/// Pure date-math helpers backing `DFCalendarView`. Kept free of SwiftUI/theme concerns so the
/// grid computation can be unit tested directly (see `DFCalendarViewTests`).
enum DFCalendarSupport {
    /// The first moment of the month containing `date`.
    static func startOfMonth(for date: Date, calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }

    /// The month grid for `month`, as an array of weeks. Each week has exactly 7 slots;
    /// `nil` marks a padding cell that falls outside `month` (leading or trailing).
    /// Respects `calendar.firstWeekday` — no hardcoded Sunday/Monday assumption.
    static func weeks(for month: Date, calendar: Calendar) -> [[Date?]] {
        let monthStart = startOfMonth(for: month, calendar: calendar)
        guard let range = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }
        let numberOfDays = range.count
        let firstWeekdayOfMonth = calendar.component(.weekday, from: monthStart)
        let leadingBlanks = (firstWeekdayOfMonth - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for dayOffset in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: monthStart) {
                days.append(date)
            }
        }
        while days.count % 7 != 0 {
            days.append(nil)
        }

        var weeks: [[Date?]] = []
        var index = 0
        while index < days.count {
            weeks.append(Array(days[index..<(index + 7)]))
            index += 7
        }
        return weeks
    }

    /// Very-short weekday symbols (e.g. "S", "M", "T"…) rotated to start at `calendar.firstWeekday`.
    static func weekdaySymbols(calendar: Calendar) -> [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        guard !symbols.isEmpty else { return symbols }
        let firstIndex = (calendar.firstWeekday - 1 + symbols.count) % symbols.count
        return Array(symbols[firstIndex...] + symbols[..<firstIndex])
    }

    static func isSameDay(_ lhs: Date, _ rhs: Date, calendar: Calendar) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    static func isToday(_ date: Date, calendar: Calendar, now: Date = Date()) -> Bool {
        calendar.isDate(date, inSameDayAs: now)
    }

    /// Whether `date` falls outside the optional `[minimum, maximum]` day bounds (inclusive).
    /// Bounds are compared at day granularity so callers may pass any time-of-day value.
    static func isDisabled(_ date: Date, minimum: Date?, maximum: Date?, calendar: Calendar) -> Bool {
        if let minimum, calendar.compare(date, to: minimum, toGranularity: .day) == .orderedAscending {
            return true
        }
        if let maximum, calendar.compare(date, to: maximum, toGranularity: .day) == .orderedDescending {
            return true
        }
        return false
    }

    static func monthTitle(for date: Date, calendar: Calendar, locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return formatter.string(from: date)
    }

    /// Full, spoken-friendly date description for accessibility labels (e.g. "Wednesday, July 1, 2026").
    static func accessibilityDayLabel(for date: Date, calendar: Calendar, locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - DFCalendarView

/// A themed month-grid calendar: weekday headers, a 7-column day grid, month navigation,
/// single-date selection, and an optional per-day content slot for badges/dots.
public struct DFCalendarView<DayContent: View>: View {
    @Binding private var selection: Date
    private let displayedMonthBinding: Binding<Date>?
    private let minimumDate: Date?
    private let maximumDate: Date?
    private let dayContent: (Date) -> DayContent

    @State private var internalDisplayedMonth: Date

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfCalendarViewStyle) private var style
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale

    /// - Parameters:
    ///   - selection: The currently selected date. Tapping an enabled day cell updates this.
    ///   - displayedMonth: Optional binding controlling which month is shown, so a consumer can
    ///     jump to an arbitrary month externally. When omitted, the view manages the displayed
    ///     month itself, initialized to `selection`'s month.
    ///   - minimumDate: Days before this date (day granularity) render disabled and non-interactive.
    ///   - maximumDate: Days after this date (day granularity) render disabled and non-interactive.
    ///   - dayContent: Per-day content slot (e.g. event dots/badges), rendered below each day number.
    public init(
        selection: Binding<Date>,
        displayedMonth: Binding<Date>? = nil,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        @ViewBuilder dayContent: @escaping (Date) -> DayContent = { _ in EmptyView() }
    ) {
        self._selection = selection
        self.displayedMonthBinding = displayedMonth
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.dayContent = dayContent
        self._internalDisplayedMonth = State(initialValue: displayedMonth?.wrappedValue ?? selection.wrappedValue)
    }

    private var displayedMonth: Date {
        displayedMonthBinding?.wrappedValue ?? internalDisplayedMonth
    }

    private func setDisplayedMonth(_ date: Date) {
        if let displayedMonthBinding {
            displayedMonthBinding.wrappedValue = date
        } else {
            internalDisplayedMonth = date
        }
    }

    public var body: some View {
        let month = displayedMonth
        let config = DFCalendarViewStyleConfiguration(
            displayedMonth: month,
            monthTitle: DFCalendarSupport.monthTitle(for: month, calendar: calendar, locale: locale),
            weeks: DFCalendarSupport.weeks(for: month, calendar: calendar),
            weekdaySymbols: DFCalendarSupport.weekdaySymbols(calendar: calendar),
            selection: selection,
            today: Date(),
            calendar: calendar,
            locale: locale,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            dayContent: { date in AnyView(dayContent(date)) },
            onSelect: { date in
                guard !DFCalendarSupport.isDisabled(date, minimum: minimumDate, maximum: maximumDate, calendar: calendar) else {
                    return
                }
                selection = date
            },
            onPreviousMonth: {
                if let previous = calendar.date(byAdding: .month, value: -1, to: month) {
                    setDisplayedMonth(previous)
                }
            },
            onNextMonth: {
                if let next = calendar.date(byAdding: .month, value: 1, to: month) {
                    setDisplayedMonth(next)
                }
            },
            theme: theme
        )
        style.makeBody(configuration: config)
    }
}
