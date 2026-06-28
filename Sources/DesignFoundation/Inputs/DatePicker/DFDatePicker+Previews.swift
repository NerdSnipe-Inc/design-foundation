#if DEBUG
import SwiftUI

#Preview("Compact Style") {
    VStack(spacing: 24) {
        DFDatePicker("Birthdate", selection: .constant(.now))
        DFDatePicker("Appointment", selection: .constant(.now), displayedComponents: [.date, .hourAndMinute])
        DFDatePicker("Disabled", selection: .constant(.now)).disabled(true)
    }
    .padding()
    .dfDatePickerStyle(.compact)
}

#Preview("Graphical Style") {
    DFDatePicker("Pick a date", selection: .constant(.now))
        .padding()
        .dfDatePickerStyle(.graphical)
}

#Preview("Wheel Style") {
    DFDatePicker("Pick a date", selection: .constant(.now), displayedComponents: [.date, .hourAndMinute])
        .padding()
        .dfDatePickerStyle(.wheel)
}
#endif
