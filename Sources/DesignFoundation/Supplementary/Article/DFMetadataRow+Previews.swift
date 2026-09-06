import SwiftUI

#Preview("DFMetadataRow") {
    DFMetadataRow(items: [
        DFMetadataItem(systemImage: "clock", label: "5 min read"),
        DFMetadataItem(systemImage: "eye", label: "1.2k views")
    ])
    .padding()
}
