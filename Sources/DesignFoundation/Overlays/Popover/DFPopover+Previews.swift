import SwiftUI

#Preview("DFPopover — Arrow") {
    struct Demo: View {
        @State private var shown = false
        var body: some View {
            Button("Show Popover") { shown = true }
                .dfPopover(isPresented: $shown, arrowEdge: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Popover Title").font(.headline)
                        Text("Additional details here.").font(.subheadline)
                    }
                }
        }
    }
    return Demo().padding()
}

#Preview("DFPopover — Compact") {
    struct Demo: View {
        @State private var shown = false
        var body: some View {
            Button("Info") { shown = true }
                .dfPopover(isPresented: $shown) {
                    Text("Short info").font(.caption)
                }
                .dfPopoverStyle(.compact)
        }
    }
    return Demo().padding()
}
