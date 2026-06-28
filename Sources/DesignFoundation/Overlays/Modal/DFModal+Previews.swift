import SwiftUI

#Preview("DFModal — Dialog") {
    struct Demo: View {
        @State private var shown = false
        var body: some View {
            Button("Show Dialog") { shown = true }
                .dfModal(isPresented: $shown) {
                    VStack {
                        Text("Modal Content").font(.headline)
                        Button("Dismiss") { shown = false }
                    }
                    .padding()
                }
        }
    }
    return Demo()
}

#Preview("DFModal — Fullscreen") {
    struct Demo: View {
        @State private var shown = false
        var body: some View {
            Button("Show Fullscreen") { shown = true }
                .dfFullscreenModal(isPresented: $shown) {
                    VStack {
                        Text("Fullscreen Content").font(.headline)
                        Button("Dismiss") { shown = false }
                    }
                }
        }
    }
    return Demo()
}
