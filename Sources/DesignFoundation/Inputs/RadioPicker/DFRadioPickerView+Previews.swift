import SwiftUI

private struct DFRadioPickerViewPreview: View {
    @State private var selection = "sm"

    var body: some View {
        DFRadioPickerView(
            options: [
                DFRadioPickerOption(id: "sm", label: "Small"),
                DFRadioPickerOption(id: "md", label: "Medium"),
                DFRadioPickerOption(id: "lg", label: "Large")
            ],
            selection: $selection
        )
        .padding()
    }
}

#Preview("DFRadioPickerView") {
    DFRadioPickerViewPreview()
}
