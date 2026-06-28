import SwiftUI

#Preview("DFSheet — Standard") {
    struct Demo: View {
        @State private var shown = false
        var body: some View {
            Button("Show Sheet") { shown = true }
                .dfSheet(isPresented: $shown) {
                    Text("Sheet Content")
                        .padding()
                }
        }
    }
    return Demo()
}

#Preview("DFSheet — Compact") {
    struct Demo: View {
        @State private var shown = false
        var body: some View {
            Button("Show Compact") { shown = true }
                .dfSheet(isPresented: $shown) {
                    Text("Compact Sheet")
                        .padding()
                }
                .dfSheetStyle(.compact)
        }
    }
    return Demo()
}
