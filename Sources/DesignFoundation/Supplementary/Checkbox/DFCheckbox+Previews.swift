import SwiftUI

#Preview("DFCheckbox — States") {
    @Previewable @State var checked1 = true
    @Previewable @State var checked2 = false
    @Previewable @State var checked3 = true

    VStack(alignment: .leading, spacing: 16) {
        DFCheckbox(isChecked: $checked1, label: "Checked")
        DFCheckbox(isChecked: $checked2, label: "Unchecked")
        DFCheckbox(isChecked: $checked3, label: "Disabled checked")
            .disabled(true)
        DFCheckbox(isChecked: $checked2)
    }
    .padding()
}
