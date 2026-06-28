import SwiftUI

#Preview("DFToast — Queue") {
    @Previewable @StateObject var queue = DFToastQueue()

    VStack(spacing: 16) {
        Button("Show toast") {
            queue.show(text: "File saved", icon: "checkmark.circle.fill")
        }
        Button("Show error toast") {
            queue.show(text: "Something went wrong", icon: "exclamationmark.triangle.fill")
        }
        Button("Show plain toast") {
            queue.show(text: "Item deleted")
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .dfToast(queue: queue)
}
