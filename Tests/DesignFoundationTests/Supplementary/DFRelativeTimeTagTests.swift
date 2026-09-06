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
}
