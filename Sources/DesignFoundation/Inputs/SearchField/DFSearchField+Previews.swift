#if DEBUG
import SwiftUI

#Preview("Outlined — States") {
    VStack(spacing: 20) {
        DFSearchField(text: .constant(""))
        DFSearchField(text: .constant("design tokens"))
        DFSearchField(text: .constant("cancel shown"), showsCancelButton: true)
        DFSearchField(text: .constant("")).disabled(true)
    }
    .padding()
    .dfSearchFieldStyle(.outlined)
}

#Preview("Filled — States") {
    VStack(spacing: 20) {
        DFSearchField(text: .constant(""))
        DFSearchField(text: .constant("design tokens"), showsCancelButton: true)
        DFSearchField(text: .constant("")).disabled(true)
    }
    .padding()
    .dfSearchFieldStyle(.filled)
}

private struct DFSearchFieldInteractivePreview: View {
    @State private var query = ""
    @State private var focused = false

    var body: some View {
        VStack(spacing: 16) {
            DFSearchField(
                text: $query,
                isFocused: $focused,
                showsCancelButton: focused,
                onSubmit: { }
            )
            DFText("Focused: \(focused ? "yes" : "no")")
        }
        .padding()
    }
}

#Preview("Interactive") {
    DFSearchFieldInteractivePreview()
}

#Preview("Dark theme") {
    DFSearchField(text: .constant("aurora"), showsCancelButton: true)
        .padding()
        .dfThemePreset(.aurora)
        .preferredColorScheme(.dark)
}
#endif
