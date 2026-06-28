#if DEBUG
import SwiftUI

#Preview("Standard Style") {
    VStack(spacing: 24) {
        DFSlider("Volume", value: .constant(0.6))
        DFSlider("Brightness", value: .constant(0.3))
        DFSlider("Disabled", value: .constant(0.5)).disabled(true)
    }
    .padding()
    .dfSliderStyle(.standard)
}

#Preview("Labeled Style") {
    VStack(spacing: 24) {
        DFSlider("Font Size", value: .constant(16), in: 10...32, step: 2)
        DFSlider("Opacity", value: .constant(0.75), in: 0...1)
        DFSlider("Steps", value: .constant(50), in: 0...100, step: 10)
    }
    .padding()
    .dfSliderStyle(.labeled)
}
#endif
