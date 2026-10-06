import SwiftUI

private let previewSteps: [DFStep] = [
    DFStep(id: "cart", title: "Cart", subtitle: "3 items", systemImage: "cart"),
    DFStep(id: "address", title: "Address", subtitle: "Where to ship", systemImage: "house"),
    DFStep(id: "shipping", title: "Shipping", subtitle: "Choose a speed", systemImage: "shippingbox"),
    DFStep(id: "payment", title: "Payment", subtitle: "Card or wallet", systemImage: "creditcard"),
]

#Preview("DFStepIndicator — Horizontal styles") {
    VStack(spacing: 40) {
        DFStepIndicator(steps: previewSteps, currentIndex: 2)
        DFStepIndicator(steps: previewSteps, currentIndex: 2)
            .dfStepIndicatorStyle(.minimal)
        DFStepIndicator(steps: previewSteps, currentIndex: 2)
            .dfStepIndicatorStyle(.numbered)
    }
    .padding()
}

#Preview("DFStepIndicator — Compact (narrow)") {
    DFStepIndicator(steps: previewSteps, currentIndex: 1)
        .frame(width: 220)
        .padding()
}

#Preview("DFStepIndicator — Vertical") {
    DFStepIndicator(steps: previewSteps, currentIndex: 1, axis: .vertical)
        .padding()
}

#Preview("DFStepIndicator — Error and finished") {
    VStack(spacing: 40) {
        DFStepIndicator(
            steps: [
                DFStep(title: "Details"),
                DFStep(title: "Payment", hasError: true),
                DFStep(title: "Review"),
            ],
            currentIndex: 1
        )
        DFStepIndicator(steps: previewSteps, currentIndex: 4)
    }
    .padding()
}
