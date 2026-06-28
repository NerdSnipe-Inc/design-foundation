import SwiftUI

#Preview("DFProgressBar — Variants") {
    VStack(spacing: 32) {
        DFProgressBar(variant: .linear, value: 0.65, label: "Uploading…")
        DFProgressBar(variant: .linear, value: 0.3)
        HStack(spacing: 24) {
            DFProgressBar(variant: .circular, value: 0.75, label: "75%")
            DFProgressBar(variant: .indeterminate, label: "Loading")
        }
    }
    .padding()
}
