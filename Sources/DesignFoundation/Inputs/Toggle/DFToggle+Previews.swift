#if DEBUG
import SwiftUI

#Preview("Switch Style") {
    VStack(spacing: 20) {
        DFToggle("Enable notifications", isOn: .constant(true))
        DFToggle("Dark mode", isOn: .constant(false))
        DFToggle("Disabled on", isOn: .constant(true)).disabled(true)
        DFToggle("Disabled off", isOn: .constant(false)).disabled(true)
    }
    .padding()
    .dfToggleStyle(.switch)
}

#Preview("Checkbox Style") {
    VStack(alignment: .leading, spacing: 16) {
        DFToggle("Accept terms", isOn: .constant(true))
        DFToggle("Subscribe to newsletter", isOn: .constant(false))
        DFToggle("Disabled checked", isOn: .constant(true)).disabled(true)
    }
    .padding()
    .dfToggleStyle(.checkbox)
}
#endif
