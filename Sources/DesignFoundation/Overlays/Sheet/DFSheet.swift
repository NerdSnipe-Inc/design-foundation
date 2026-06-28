import SwiftUI

public extension View {
    func dfSheet<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            DFSheetModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                sheetContent: content
            )
        )
    }
}

private struct DFSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    @ViewBuilder let sheetContent: () -> SheetContent

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfSheetStyle) private var style

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented, onDismiss: onDismiss) {
            // ARCHITECTURE: Presentation modifiers only work on concrete View types
            // returned directly from the sheet() closure. They cannot be applied:
            // - To AnyView
            // - To generic View constraints
            // - Through ViewModifier.body
            // - Inside style protocols
            //
            // SOLUTION: Apply styling through the DFSheetStyle protocol,
            // and leave presentation configuration to the user or style environment.
            // Styles should only transform content, not apply presentation modifiers.

            let config = DFSheetStyleConfiguration(
                content: AnyView(sheetContent()),
                theme: theme
            )

            style.makeBody(configuration: config)
        }
    }
}
