import SwiftUI

#Preview("DFArticleRow") {
    VStack(alignment: .leading, spacing: 24) {
        DFArticleRow(
            title: "SwiftUI in 2026: What Changed",
            authorName: "Jordan Lee",
            authorInitials: "JL",
            date: Date().addingTimeInterval(-3 * 60 * 60),
            tags: ["Swift", "iOS 26"]
        )
        DFArticleRow(
            title: "A Quiet Release",
            authorName: "Amara Khan",
            authorInitials: "AK",
            date: Date().addingTimeInterval(-60 * 60 * 24 * 2)
        )
    }
    .padding()
}
