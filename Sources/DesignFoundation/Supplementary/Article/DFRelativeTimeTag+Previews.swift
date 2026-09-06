import SwiftUI

#Preview("DFRelativeTimeTag") {
    VStack(alignment: .leading, spacing: 8) {
        DFRelativeTimeTag(date: Date().addingTimeInterval(-3 * 60 * 60))
        DFRelativeTimeTag(date: Date().addingTimeInterval(-60 * 60 * 24 * 2))
        DFRelativeTimeTag(date: Date())
    }
    .padding()
}
