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
