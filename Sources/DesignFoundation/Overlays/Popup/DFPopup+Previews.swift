#if DEBUG
import SwiftUI

#Preview("DFPopup — Center") {
    @Previewable @State var show = true

    VStack {
        DFButton("Show") { show = true }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .dfPopup(isPresented: $show) {
        VStack(spacing: 12) {
            DFText("Delete item?", scale: .headline)
            DFText("This cannot be undone.", scale: .caption)
            DFButton("Close") { show = false }
        }
    }
    .dfTheme(.default)
}

#Preview("DFPopup — Toast & Floater") {
    @Previewable @State var toast = true
    @Previewable @State var floater = true

    Color.clear
        .dfPopup(isPresented: $toast, configuration: .toast(position: .top, autoDismissAfter: nil)) {
            DFText("Toast pinned to the top edge", scale: .body)
        }
        .dfPopup(isPresented: $floater, configuration: .floater(position: .bottomTrailing)) {
            DFText("Floater — drag to dismiss", scale: .body)
        }
        .dfTheme(.default)
}
#endif
