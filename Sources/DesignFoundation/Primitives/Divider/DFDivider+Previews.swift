import SwiftUI

#if DEBUG

#Preview("Horizontal variants") {
    VStack(spacing: 16) {
        DFDivider()
        DFDivider(label: "OR")
        DFDivider().dfDividerStyle(.thick)
        DFDivider().dfDividerStyle(.subtle)
    }
    .padding()
}

#Preview("Vertical") {
    HStack(spacing: 16) {
        Text("Left")
        DFDivider(orientation: .vertical).frame(height: 40)
        Text("Right")
    }
    .padding()
}

#endif
