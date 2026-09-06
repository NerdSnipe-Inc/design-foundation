import Testing
import Foundation
import SwiftUI
@testable import DesignFoundation

@Suite("DFArticleRow")
struct DFArticleRowTests {
    @Test("initials initializer defaults to no tags")
    func initialsInitializerDefaultTags() {
        let row = DFArticleRow(
            title: "SwiftUI in 2026",
            authorName: "Jordan Lee",
            authorInitials: "JL",
            date: .now
        )
        #expect(row.title == "SwiftUI in 2026")
        #expect(row.tags.isEmpty)
    }

    @Test("stores explicit tags in order")
    func storesTags() {
        let row = DFArticleRow(
            title: "SwiftUI in 2026",
            authorName: "Jordan Lee",
            authorInitials: "JL",
            date: .now,
            tags: ["Swift", "iOS 26"]
        )
        #expect(row.tags == ["Swift", "iOS 26"])
    }

    @Test("image initializer stores the title")
    func imageInitializerStoresTitle() {
        let row = DFArticleRow(
            title: "SwiftUI in 2026",
            authorName: "Jordan Lee",
            authorImage: Image(systemName: "person.fill"),
            date: .now
        )
        #expect(row.title == "SwiftUI in 2026")
    }
}
