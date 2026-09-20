import SwiftUI

// MARK: - Layer

/// Renders the head of the queue through the popup engine. The toast style already
/// draws its own surface, so the popup chrome is replaced with a bare pass-through.
private struct DFToastLayer: View {
    @ObservedObject var queue: DFToastQueue

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfToastStyle) private var style

    // Keeps the message alive through the exit transition after it leaves the queue.
    @State private var lastMessage: DFToastMessage?

    var body: some View {
        let current = queue.messages.first
        let shown = current ?? lastMessage

        DFPopupHost(
            isPresented: Binding(
                get: { queue.messages.first != nil },
                set: { if !$0, let id = queue.messages.first?.id { queue.dismiss(id: id) } }
            ),
            identity: current.map { AnyHashable($0.id) },
            configuration: .floater(
                position: shown?.position ?? .top,
                autoDismissAfter: current?.duration
            ).tapToDismiss()
        ) {
            if let shown {
                style.makeBody(configuration: DFToastStyleConfiguration(message: shown, theme: theme))
            }
        }
        .dfPopupStyle(DFBarePopupStyle())
        .onChange(of: current?.id, initial: true) {
            if let current { lastMessage = current }
        }
    }
}

private extension DFPopupConfiguration {
    func tapToDismiss() -> DFPopupConfiguration {
        var copy = self
        copy.dismissOnTap = true
        return copy
    }
}

/// Content only — no surface, so a style that draws its own chrome isn't double-wrapped.
private struct DFBarePopupStyle: DFPopupStyle, Sendable {
    func makeBody(configuration: DFPopupStyleConfiguration) -> some View {
        configuration.content
    }
}

// MARK: - Modifier

private struct DFToastModifier: ViewModifier {
    @ObservedObject var queue: DFToastQueue

    func body(content: Content) -> some View {
        content.overlay { DFToastLayer(queue: queue) }
    }
}

// MARK: - View extension

@MainActor
public extension View {
    /// Shows queued toasts one at a time at each message's `position` (top by default).
    func dfToast(queue: DFToastQueue = .shared) -> some View {
        modifier(DFToastModifier(queue: queue))
    }
}
