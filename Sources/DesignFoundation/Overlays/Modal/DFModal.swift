import SwiftUI

// MARK: - Dialog modifier (uses .sheet)

private struct DFDialogModalModifier<ModalContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    @ViewBuilder let modalContent: () -> ModalContent

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfModalStyle) private var style

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented, onDismiss: onDismiss) {
            style.makeBody(configuration: DFModalStyleConfiguration(
                content: AnyView(modalContent()),
                theme: theme
            ))
        }
    }
}

// MARK: - Fullscreen modifier (uses .fullScreenCover on iOS/visionOS, .sheet on macOS)

private struct DFFullscreenModalModifier<ModalContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    @ViewBuilder let modalContent: () -> ModalContent

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfModalStyle) private var style

    func body(content: Content) -> some View {
        #if os(iOS) || os(visionOS)
        content.fullScreenCover(isPresented: $isPresented, onDismiss: onDismiss) {
            style.makeBody(configuration: DFModalStyleConfiguration(
                content: AnyView(modalContent()),
                theme: theme
            ))
        }
        #else
        content.sheet(isPresented: $isPresented, onDismiss: onDismiss) {
            style.makeBody(configuration: DFModalStyleConfiguration(
                content: AnyView(modalContent()),
                theme: theme
            ))
        }
        #endif
    }
}

// MARK: - Public API

public extension View {
    /// Presents content as a dialog (sheet presentation).
    func dfModal<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(DFDialogModalModifier(
            isPresented: isPresented,
            onDismiss: onDismiss,
            modalContent: content
        ))
    }

    /// Presents content fullscreen. On macOS, falls back to sheet presentation.
    func dfFullscreenModal<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(DFFullscreenModalModifier(
            isPresented: isPresented,
            onDismiss: onDismiss,
            modalContent: content
        ))
    }
}
