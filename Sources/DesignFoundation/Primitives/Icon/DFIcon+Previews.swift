import SwiftUI

#if DEBUG

#Preview("All built-in styles") {
    HStack(spacing: 24) {
        DFIcon("star.fill").dfIconStyle(.standard)
        DFIcon("star.fill").dfIconStyle(.tinted)
        DFIcon("star.fill").dfIconStyle(.secondary)
    }
    .padding()
}

#Preview("Sizes") {
    HStack(alignment: .center, spacing: 16) {
        DFIcon("heart.fill", size: 16)
        DFIcon("heart.fill", size: 24)
        DFIcon("heart.fill", size: 32)
        DFIcon("heart.fill", size: 48)
    }
    .padding()
}

#Preview("Disabled") {
    HStack(spacing: 24) {
        DFIcon("star.fill")
        DFIcon("star.fill").disabled(true)
    }
    .padding()
}

#endif
