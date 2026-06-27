import SwiftUI

#if DEBUG

#Preview("Filled — all states") {
    VStack(spacing: 16) {
        DFButton("Continue") {}
        DFButton("Continue") {}.disabled(true)
        DFButton("Delete", role: .destructive) {}
    }
    .padding()
}

#Preview("All built-in styles") {
    VStack(spacing: 12) {
        DFButton("Filled") {}.dfButtonStyle(.filled)
        DFButton("Outlined") {}.dfButtonStyle(.outlined)
        DFButton("Ghost") {}.dfButtonStyle(.ghost)
        DFButton("Tinted") {}.dfButtonStyle(.tinted)
    }
    .padding()
}

#Preview("Dark mode") {
    VStack(spacing: 12) {
        DFButton("Continue") {}
        DFButton("Outlined") {}.dfButtonStyle(.outlined)
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Custom theme") {
    DFButton("Buy Now") {}
        .dfTheme(DFTheme(colors: DFColorTokens(primary: .purple)))
        .padding()
}

#endif
