import SwiftUI

#if DEBUG

#Preview("Bordered (default)") {
    struct Wrapper: View {
        @State private var quantity = 1
        var body: some View {
            DFQuantityStepper(value: $quantity)
        }
    }
    return Wrapper().padding()
}

#Preview("Compact") {
    struct Wrapper: View {
        @State private var quantity = 3
        var body: some View {
            DFQuantityStepper(value: $quantity, range: 0...10)
                .dfQuantityStepperStyle(.compact)
        }
    }
    return Wrapper().padding()
}

#Preview("Disabled") {
    struct Wrapper: View {
        @State private var quantity = 2
        var body: some View {
            DFQuantityStepper(value: $quantity)
                .disabled(true)
        }
    }
    return Wrapper().padding()
}

#Preview("Dark mode") {
    struct Wrapper: View {
        @State private var quantity = 1
        var body: some View {
            DFQuantityStepper(value: $quantity)
        }
    }
    return Wrapper()
        .padding()
        .preferredColorScheme(.dark)
}

#endif
