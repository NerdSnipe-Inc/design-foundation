import SwiftUI

#Preview("DFAuthorView") {
    VStack(alignment: .leading, spacing: 16) {
        DFAuthorView(initials: "JL", name: "Jordan Lee", subtitle: "Staff Writer")
        DFAuthorView(initials: "AK", name: "Amara Khan")
    }
    .padding()
}
