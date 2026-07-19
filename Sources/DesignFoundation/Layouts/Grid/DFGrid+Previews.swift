import SwiftUI

#if DEBUG

#Preview("Fixed columns") {
    ScrollView {
        DFGrid(columns: .fixed(2)) {
            ForEach(0..<6, id: \.self) { index in
                DFEntityCard(media: .systemImage("shippingbox.fill"), title: "Item \(index)", subtitle: "$\(index * 10).99")
            }
        }
        .padding()
    }
}

#Preview("Adaptive columns") {
    ScrollView {
        DFGrid(columns: .adaptive(minWidth: 120)) {
            ForEach(0..<8, id: \.self) { index in
                DFEntityCard(media: .systemImage("photo"), title: "Photo \(index)")
            }
        }
        .padding()
    }
}

#endif
