import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFImageGallery")
struct DFImageGalleryTests {
    @Test("dfImageGallery modifier compiles and can be applied to any view")
    @MainActor
    func modifierApplies() {
        let isPresented = Binding<Bool>(get: { false }, set: { _ in })
        let view = Text("Content")
            .dfImageGallery(isPresented: isPresented, images: [Image(systemName: "photo")])
        #expect(view is any View)
    }
}
