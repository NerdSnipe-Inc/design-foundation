import SwiftUI

#if DEBUG

#Preview("Read-only — full and partial values") {
    VStack(alignment: .leading, spacing: 12) {
        DFRatingView(value: 5)
        DFRatingView(value: 3.5)
        DFRatingView(value: 0)
    }
    .padding()
}

#Preview("All styles") {
    VStack(alignment: .leading, spacing: 12) {
        DFRatingView(value: 4.5).dfRatingViewStyle(.stars)
        DFRatingView(value: 4.8).dfRatingViewStyle(.numeric)
    }
    .padding()
}

#Preview("Interactive") {
    struct Wrapper: View {
        @State private var value: Double = 3

        var body: some View {
            DFRatingView(value: value, mode: .interactive(onChange: { value = $0 }))
        }
    }
    return Wrapper().padding()
}

#Preview("Dark mode") {
    DFRatingView(value: 4.5)
        .padding()
        .preferredColorScheme(.dark)
}

#endif
