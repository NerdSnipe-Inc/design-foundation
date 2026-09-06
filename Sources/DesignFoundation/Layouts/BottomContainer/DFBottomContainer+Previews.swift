import SwiftUI

#Preview("DFBottomContainer") {
    ScrollView {
        VStack {
            ForEach(0..<10) { i in
                Text("Row \(i)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
    }
    .dfBottomBar {
        DFButton("Continue") { }
    }
}
