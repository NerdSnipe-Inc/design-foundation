import SwiftUI

// MARK: - isPresented modifier

private struct DFPopupModifier<PopupContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let configuration: DFPopupConfiguration
    let onDismiss: (() -> Void)?
    @ViewBuilder let popupContent: () -> PopupContent

    func body(content: Content) -> some View {
        content.overlay {
            DFPopupHost(
                isPresented: $isPresented,
                configuration: configuration,
                onDismiss: onDismiss,
                content: popupContent
            )
        }
    }
}

// MARK: - Item modifier

private struct DFPopupItemModifier<Item: Identifiable, PopupContent: View>: ViewModifier {
    @Binding var item: Item?
    let configuration: DFPopupConfiguration
    let onDismiss: (() -> Void)?
    @ViewBuilder let popupContent: (Item) -> PopupContent

    // Keeps content alive through the exit transition after `item` becomes nil.
    @State private var lastItem: Item?

    func body(content: Content) -> some View {
        content
            .overlay {
                DFPopupHost(
                    isPresented: Binding(
                        get: { item != nil },
                        set: { if !$0 { item = nil } }
                    ),
                    identity: item.map { AnyHashable($0.id) },
                    configuration: configuration,
                    onDismiss: onDismiss
                ) {
                    if let shown = item ?? lastItem {
                        popupContent(shown)
                    }
                }
            }
            .onChange(of: item?.id, initial: true) {
                if let item { lastItem = item }
            }
    }
}

// MARK: - Public API

public extension View {
    /// Presents `content` in a popup over this view.
    ///
    /// ```swift
    /// .dfPopup(isPresented: $show, configuration: .toast(position: .bottom)) {
    ///     Text("Saved")
    /// }
    /// ```
    func dfPopup<Content: View>(
        isPresented: Binding<Bool>,
        configuration: DFPopupConfiguration = .centered,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(DFPopupModifier(
            isPresented: isPresented,
            configuration: configuration,
            onDismiss: onDismiss,
            popupContent: content
        ))
    }

    /// Presents a popup for `item` while it is non-nil. Changing the item's `id`
    /// while presented restarts auto-dismiss.
    func dfPopup<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        configuration: DFPopupConfiguration = .centered,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        modifier(DFPopupItemModifier(
            item: item,
            configuration: configuration,
            onDismiss: onDismiss,
            popupContent: content
        ))
    }
}
