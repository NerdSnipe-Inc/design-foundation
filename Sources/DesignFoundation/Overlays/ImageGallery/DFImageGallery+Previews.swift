import SwiftUI

private struct DFImageGalleryPreview: View {
    @State private var isPresented = false

    var body: some View {
        DFButton("Open Gallery") { isPresented = true }
            .dfImageGallery(
                isPresented: $isPresented,
                images: [
                    Image(systemName: "photo"),
                    Image(systemName: "photo.fill"),
                    Image(systemName: "photo.on.rectangle")
                ]
            )
    }
}

#Preview("DFImageGallery") {
    DFImageGalleryPreview()
}
