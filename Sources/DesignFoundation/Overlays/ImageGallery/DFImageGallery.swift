import SwiftUI

private struct DFImageGalleryView: View {
    let images: [Image]
    @State private var currentIndex: Int
    @Binding var isPresented: Bool

    init(images: [Image], currentIndex: Int, isPresented: Binding<Bool>) {
        self.images = images
        self._currentIndex = State(initialValue: currentIndex)
        self._isPresented = isPresented
    }

    @Environment(\.dfTheme) private var theme

    var body: some View {
        ZStack(alignment: .topTrailing) {
            theme.colors.background.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(images.indices, id: \.self) { index in
                    images[index]
                        .resizable()
                        .scaledToFit()
                        .tag(index)
                }
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .always))
            #endif

            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white, .black.opacity(0.4))
            }
            .padding()
            .accessibilityLabel("Close")
        }
    }
}

private struct DFImageGalleryModifier: ViewModifier {
    @Binding var isPresented: Bool
    let images: [Image]
    let initialIndex: Int

    func body(content: Content) -> some View {
        #if os(iOS) || os(visionOS)
        content.fullScreenCover(isPresented: $isPresented) {
            DFImageGalleryView(images: images, currentIndex: initialIndex, isPresented: $isPresented)
        }
        #else
        content.sheet(isPresented: $isPresented) {
            DFImageGalleryView(images: images, currentIndex: initialIndex, isPresented: $isPresented)
        }
        #endif
    }
}

public extension View {
    /// Presents a full-screen swipeable image viewer with a page indicator.
    func dfImageGallery(isPresented: Binding<Bool>, images: [Image], initialIndex: Int = 0) -> some View {
        modifier(DFImageGalleryModifier(isPresented: isPresented, images: images, initialIndex: initialIndex))
    }
}
