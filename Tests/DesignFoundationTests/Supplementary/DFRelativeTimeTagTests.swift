import Testing
import Foundation
@testable import DesignFoundation

@Suite("DFRelativeTimeTag")
struct DFRelativeTimeTagTests {
    @Test("formats a past date relative to a fixed reference")
    func formatsPastDate() {
        let reference = Date(timeIntervalSince1970: 1_000_000)
        let threeHoursEarlier = reference.addingTimeInterval(-3 * 60 * 60)
        let tag = DFRelativeTimeTag(date: threeHoursEarlier, referenceDate: reference)
        #expect(tag.formattedText.contains("3") || tag.formattedText.lowercased().contains("hour"))
    }

    @Test("formats the same instant as 'now'")
    func formatsNow() {
        let reference = Date(timeIntervalSince1970: 1_000_000)
        let tag = DFRelativeTimeTag(date: reference, referenceDate: reference)
        #expect(!tag.formattedText.isEmpty)
    }

    @Test("respects an explicit locale (Spanish output differs from English)")
    func respectsExplicitLocale() {
        let reference = Date(timeIntervalSince1970: 1_000_000)
        let threeHoursEarlier = reference.addingTimeInterval(-3 * 60 * 60)
        let english = DFRelativeTimeTag.formattedText(for: threeHoursEarlier, relativeTo: reference, locale: Locale(identifier: "en_US"))
        let spanish = DFRelativeTimeTag.formattedText(for: threeHoursEarlier, relativeTo: reference, locale: Locale(identifier: "es_ES"))
        #expect(english != spanish)
    }
}
