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

#Preview("Glass (iOS 26+)") {
    if #available(iOS 26, macOS 26, *) {
        VStack(spacing: 12) {
            DFButton("Glass Button") {}.dfButtonStyle(.glass)
            DFButton("Glass Disabled") {}.dfButtonStyle(.glass).disabled(true)
        }
        .padding()
        .background(Color.blue.gradient)
    } else {
        Text("Requires iOS 26+")
    }
}

#endif
