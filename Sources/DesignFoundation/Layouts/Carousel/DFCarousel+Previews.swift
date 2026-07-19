import SwiftUI

#if DEBUG

#Preview("Carousel of cards") {
    DFCarousel {
        ForEach(0..<6, id: \.self) { index in
            DFEntityCard(media: .systemImage("photo"), title: "Slide \(index)")
                .frame(width: 140)
        }
    }
    .padding()
}

#Preview("Dark mode") {
    DFCarousel {
        ForEach(0..<4, id: \.self) { index in
            DFEntityCard(media: .systemImage("photo"), title: "Slide \(index)")
                .frame(width: 140)
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}

#endif
