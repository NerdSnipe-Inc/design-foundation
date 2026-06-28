import SwiftUI

private struct DFPopoverModifier<PopoverContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let attachmentAnchor: PopoverAttachmentAnchor
    let arrowEdge: Edge
    @ViewBuilder let popoverContent: () -> PopoverContent

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfPopoverStyle) private var style

    func body(content: Content) -> some View {
        content.popover(
            isPresented: $isPresented,
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge
        ) {
            style.makeBody(configuration: DFPopoverStyleConfiguration(
                content: AnyView(popoverContent()),
                theme: theme
            ))
        }
    }
}

public extension View {
    func dfPopover<Content: View>(
        isPresented: Binding<Bool>,
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
        arrowEdge: Edge = .top,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(DFPopoverModifier(
            isPresented: isPresented,
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge,
            popoverContent: content
        ))
    }
}
