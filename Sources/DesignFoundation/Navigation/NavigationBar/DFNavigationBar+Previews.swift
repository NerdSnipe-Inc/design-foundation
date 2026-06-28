import SwiftUI

#Preview("DFNavigationBar — Standard") {
    NavigationStack {
        List(1...20, id: \.self) { i in
            Text("Item \(i)")
        }
        .dfNavigationBar(title: "Standard Bar") {
            Button("Done") {}
        }
        .dfTheme(.default)
    }
}

#Preview("DFNavigationBar — Transparent + Inline") {
    NavigationStack {
        List(1...20, id: \.self) { i in
            Text("Item \(i)")
        }
        .dfNavigationBar(title: "Transparent", displayMode: .inline) {
            Button { } label: { Image(systemName: "ellipsis") }
        }
        .dfNavigationBarStyle(.transparent)
        .dfTheme(.default)
    }
}

#Preview("DFNavigationBar — Glass (iOS 26+)") {
    if #available(iOS 26, macOS 26, *) {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                List(1...20, id: \.self) { i in
                    Text("Item \(i)")
                }
            }
            .dfNavigationBar(title: "Glass Bar") {
                Button("Done") {}
            }
            .dfNavigationBarStyle(.glass)
            .dfTheme(.default)
        }
    } else {
        Text("Requires iOS 26+")
    }
}
