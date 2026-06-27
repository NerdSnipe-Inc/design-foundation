import SwiftUI

#if DEBUG

#Preview("All scales") {
    VStack(alignment: .leading, spacing: 8) {
        DFText("Display", scale: .display)
        DFText("Title", scale: .title)
        DFText("Headline", scale: .headline)
        DFText("Body", scale: .body)
        DFText("Caption", scale: .caption)
        DFText("Label", scale: .label)
    }
    .padding()
}

#Preview("All styles") {
    VStack(alignment: .leading, spacing: 8) {
        DFText("Standard text").dfTextViewStyle(.standard)
        DFText("Secondary text").dfTextViewStyle(.secondary)
        DFText("Muted text").dfTextViewStyle(.muted)
    }
    .padding()
}

#Preview("Dark mode") {
    VStack(alignment: .leading, spacing: 8) {
        DFText("Standard text")
        DFText("Secondary text").dfTextViewStyle(.secondary)
    }
    .padding()
    .preferredColorScheme(.dark)
}

#endif
