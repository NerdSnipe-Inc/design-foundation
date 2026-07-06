import Testing
import SwiftUI
@testable import DesignFoundation

private func gregorianCalendar(firstWeekday: Int = 1) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.firstWeekday = firstWeekday
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}

private func date(_ year: Int, _ month: Int, _ day: Int, calendar: Calendar) -> Date {
    calendar.date(from: DateComponents(year: year, month: month, day: day))!
}

@Suite("DFCalendarViewStyleConfiguration")
struct DFCalendarViewStyleConfigurationTests {
    @Test("configuration holds its values")
    func configurationHoldsValues() {
        let calendar = gregorianCalendar()
        let selected = date(2026, 7, 4, calendar: calendar)
        let config = DFCalendarViewStyleConfiguration(
            displayedMonth: selected,
            monthTitle: "July 2026",
            weeks: [[selected]],
            weekdaySymbols: ["S", "M", "T", "W", "T", "F", "S"],
            selection: selected,
            today: selected,
            calendar: calendar,
            locale: Locale(identifier: "en_US"),
            minimumDate: nil,
            maximumDate: nil,
            dayContent: { _ in AnyView(EmptyView()) },
            onSelect: { _ in },
            onPreviousMonth: {},
            onNextMonth: {},
            theme: .default
        )
        #expect(config.monthTitle == "July 2026")
        #expect(config.weekdaySymbols.count == 7)
        #expect(config.isSelected(selected))
        #expect(config.isToday(selected))
    }
}

@Suite("DFCalendarView Environment")
struct DFCalendarViewEnvironmentTests {
    @Test("dfCalendarViewStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfCalendarViewStyle
    }
}

@Suite("DFCalendarSupport month grid math")
struct DFCalendarSupportGridTests {
    @Test("July 2026 starts mid-week (Wednesday) and spans 5 weeks")
    func july2026StartsMidWeek() {
        let calendar = gregorianCalendar()
        let july1 = date(2026, 7, 1, calendar: calendar)
        let weeks = DFCalendarSupport.weeks(for: july1, calendar: calendar)

        #expect(weeks.count == 5)
        // Sunday-first grid: Wed is the 4th slot (index 3) in week 1.
        #expect(weeks[0][0] == nil)
        #expect(weeks[0][1] == nil)
        #expect(weeks[0][2] == nil)
        #expect(weeks[0][3] == july1)
        // Last day of July (31st) falls in week 5.
        let july31 = date(2026, 7, 31, calendar: calendar)
        #expect(weeks[4].contains(july31))
        // Total non-nil days across the grid equals 31.
        let dayCount = weeks.flatMap { $0 }.compactMap { $0 }.count
        #expect(dayCount == 31)
    }

    @Test("February 2024 is a leap year with 29 days, starting Thursday")
    func february2024LeapYear() {
        let calendar = gregorianCalendar()
        let feb1 = date(2024, 2, 1, calendar: calendar)
        let weeks = DFCalendarSupport.weeks(for: feb1, calendar: calendar)

        let dayCount = weeks.flatMap { $0 }.compactMap { $0 }.count
        #expect(dayCount == 29)
        // Thursday is the 5th slot (index 4) in a Sunday-first week.
        #expect(weeks[0][4] == feb1)
        let feb29 = date(2024, 2, 29, calendar: calendar)
        #expect(weeks.flatMap { $0 }.contains(feb29))
    }

    @Test("February 2026 is a non-leap year with 28 days, starting Sunday, forming exactly 4 weeks")
    func february2026NonLeapYear() {
        let calendar = gregorianCalendar()
        let feb1 = date(2026, 2, 1, calendar: calendar)
        let weeks = DFCalendarSupport.weeks(for: feb1, calendar: calendar)

        #expect(weeks.count == 4)
        #expect(weeks[0][0] == feb1)
        let dayCount = weeks.flatMap { $0 }.compactMap { $0 }.count
        #expect(dayCount == 28)
    }

    @Test("weekday symbols rotate to respect firstWeekday")
    func weekdaySymbolsRotate() {
        let sundayFirst = gregorianCalendar(firstWeekday: 1)
        let mondayFirst = gregorianCalendar(firstWeekday: 2)

        let sundaySymbols = DFCalendarSupport.weekdaySymbols(calendar: sundayFirst)
        let mondaySymbols = DFCalendarSupport.weekdaySymbols(calendar: mondayFirst)

        #expect(sundaySymbols.count == 7)
        #expect(mondaySymbols.count == 7)
        #expect(sundaySymbols != mondaySymbols)
        // Rotating the Sunday-first list by one should match the Monday-first list.
        let rotated = Array(sundaySymbols[1...] + sundaySymbols[..<1])
        #expect(rotated == mondaySymbols)
    }
}

@Suite("DFCalendarSupport selection & disabled logic")
struct DFCalendarSupportStateTests {
    @Test("isSameDay ignores time-of-day differences")
    func isSameDayIgnoresTime() {
        let calendar = gregorianCalendar()
        let morning = date(2026, 7, 4, calendar: calendar)
        let evening = calendar.date(byAdding: .hour, value: 20, to: morning)!
        #expect(DFCalendarSupport.isSameDay(morning, evening, calendar: calendar))
    }

    @Test("isToday compares against the provided now value")
    func isTodayUsesProvidedNow() {
        let calendar = gregorianCalendar()
        let day = date(2026, 7, 4, calendar: calendar)
        #expect(DFCalendarSupport.isToday(day, calendar: calendar, now: day))
        let otherDay = date(2026, 7, 5, calendar: calendar)
        #expect(!DFCalendarSupport.isToday(day, calendar: calendar, now: otherDay))
    }

    @Test("days before minimumDate are disabled")
    func beforeMinimumIsDisabled() {
        let calendar = gregorianCalendar()
        let minimum = date(2026, 7, 10, calendar: calendar)
        let earlier = date(2026, 7, 5, calendar: calendar)
        #expect(DFCalendarSupport.isDisabled(earlier, minimum: minimum, maximum: nil, calendar: calendar))
    }

    @Test("days after maximumDate are disabled")
    func afterMaximumIsDisabled() {
        let calendar = gregorianCalendar()
        let maximum = date(2026, 7, 10, calendar: calendar)
        let later = date(2026, 7, 20, calendar: calendar)
        #expect(DFCalendarSupport.isDisabled(later, minimum: nil, maximum: maximum, calendar: calendar))
    }

    @Test("days within bounds are not disabled")
    func withinBoundsIsEnabled() {
        let calendar = gregorianCalendar()
        let minimum = date(2026, 7, 1, calendar: calendar)
        let maximum = date(2026, 7, 31, calendar: calendar)
        let middle = date(2026, 7, 15, calendar: calendar)
        #expect(!DFCalendarSupport.isDisabled(middle, minimum: minimum, maximum: maximum, calendar: calendar))
    }

    @Test("bounds are inclusive at day granularity regardless of time-of-day")
    func boundsAreInclusive() {
        let calendar = gregorianCalendar()
        let minimum = date(2026, 7, 10, calendar: calendar)
        let sameDayLater = calendar.date(byAdding: .hour, value: 5, to: minimum)!
        #expect(!DFCalendarSupport.isDisabled(sameDayLater, minimum: minimum, maximum: nil, calendar: calendar))
    }

    @Test("no bounds means nothing is disabled")
    func noBoundsMeansEnabled() {
        let calendar = gregorianCalendar()
        let anyDay = date(2026, 7, 15, calendar: calendar)
        #expect(!DFCalendarSupport.isDisabled(anyDay, minimum: nil, maximum: nil, calendar: calendar))
    }
}
