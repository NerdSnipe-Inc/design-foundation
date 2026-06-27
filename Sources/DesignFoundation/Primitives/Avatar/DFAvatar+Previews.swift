import SwiftUI

#if DEBUG

#Preview("Initials + presence") {
    HStack(spacing: 16) {
        DFAvatar("JD")
        DFAvatar("JD", presence: .online)
        DFAvatar("JD", presence: .away)
        DFAvatar("JD", presence: .busy)
    }
    .padding()
}

#Preview("All styles") {
    HStack(spacing: 16) {
        DFAvatar("AB").dfAvatarStyle(.circle)
        DFAvatar("AB").dfAvatarStyle(.rounded)
        DFAvatar("AB").dfAvatarStyle(.ring)
    }
    .padding()
}

#Preview("Sizes") {
    HStack(alignment: .center, spacing: 12) {
        DFAvatar("AB", size: 24)
        DFAvatar("AB", size: 32)
        DFAvatar("AB", size: 40)
        DFAvatar("AB", size: 56)
        DFAvatar("AB", size: 72)
    }
    .padding()
}

#Preview("Dark mode") {
    HStack(spacing: 16) {
        DFAvatar("JD")
        DFAvatar("JD", presence: .online)
    }
    .padding()
    .preferredColorScheme(.dark)
}

#endif
