import SwiftUI

#if DEBUG

#Preview("All variants — filled") {
    HStack(spacing: 16) {
        DFBadge(count: 3)
        DFBadge(count: 99)
        DFBadge(count: 150)  // shows "99+"
        DFBadge(.dot)
        DFBadge(text: "New")
    }
    .padding()
}

#Preview("All styles") {
    VStack(spacing: 12) {
        HStack(spacing: 12) {
            DFBadge(count: 5).dfBadgeStyle(.filled)
            DFBadge(count: 5).dfBadgeStyle(.tinted)
            DFBadge(count: 5).dfBadgeStyle(.outlined)
        }
        HStack(spacing: 12) {
            DFBadge(.dot).dfBadgeStyle(.filled)
            DFBadge(.dot).dfBadgeStyle(.tinted)
            DFBadge(.dot).dfBadgeStyle(.outlined)
        }
    }
    .padding()
}

#Preview("Dark mode") {
    HStack(spacing: 16) {
        DFBadge(count: 5)
        DFBadge(text: "New")
    }
    .padding()
    .preferredColorScheme(.dark)
}

#endif
