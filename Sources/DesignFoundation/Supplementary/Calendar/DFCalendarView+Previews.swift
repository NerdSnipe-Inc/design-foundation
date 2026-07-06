import SwiftUI

#if DEBUG

#Preview("Standard") {
    struct Wrapper: View {
        @State private var selection = Date()

        var body: some View {
            DFCalendarView(selection: $selection)
                .padding()
        }
    }
    return Wrapper()
}

#Preview("With day content badges") {
    struct Wrapper: View {
        @State private var selection = Date()
        private let calendar = Calendar.current

        var body: some View {
            DFCalendarView(selection: $selection) { date in
                if calendar.component(.day, from: date).isMultiple(of: 5) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 4, height: 4)
                }
            }
            .padding()
        }
    }
    return Wrapper()
}

#Preview("With min/max bounds") {
    struct Wrapper: View {
        @State private var selection = Date()
        private let calendar = Calendar.current

        var body: some View {
            DFCalendarView(
                selection: $selection,
                minimumDate: calendar.date(byAdding: .day, value: -3, to: Date()),
                maximumDate: calendar.date(byAdding: .day, value: 10, to: Date())
            )
            .padding()
        }
    }
    return Wrapper()
}

#endif
