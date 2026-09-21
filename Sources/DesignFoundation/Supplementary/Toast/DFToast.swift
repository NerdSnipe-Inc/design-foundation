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
            configuration: popupConfiguration(current: current, shown: shown)
        ) {
            if let shown {
                style.makeBody(configuration: DFToastStyleConfiguration(
                    message: shown,
                    theme: theme,
                    dismiss: { [weak queue] in queue?.dismiss(id: shown.id) }
                ))
            }
        }
        .dfPopupStyle(DFBarePopupStyle())
        .onChange(of: current?.id, initial: true) {
            if let current {
                lastMessage = current
                announce(current)
            }
        }
    }

    private func popupConfiguration(current: DFToastMessage?, shown: DFToastMessage?) -> DFPopupConfiguration {
        let position = shown?.position ?? .top
        let autoDismiss = current?.duration
        switch style.layout {
        case .floating:
            return DFPopupConfiguration.floater(position: position, autoDismissAfter: autoDismiss).tapToDismiss()
        case .flush:
            return DFPopupConfiguration.toast(position: position, autoDismissAfter: autoDismiss)
        }
    }

    /// Toasts appear without moving VoiceOver focus, so announce them.
    private func announce(_ message: DFToastMessage) {
        let text = [message.title, message.text].compactMap { $0 }.joined(separator: ". ")
        AccessibilityNotification.Announcement(text).post()
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
    let style: AnyDFToastStyle?

    func body(content: Content) -> some View {
        content.overlay {
            if let style {
                DFToastLayer(queue: queue).environment(\.dfToastStyle, style)
            } else {
                DFToastLayer(queue: queue)
            }
        }
    }
}

// MARK: - View extension

@MainActor
public extension View {
    /// Shows queued toasts one at a time at each message's `position` (top by default).
    func dfToast(queue: DFToastQueue = .shared) -> some View {
        modifier(DFToastModifier(queue: queue, style: nil))
    }

    /// Shows queued toasts in `style`.
    ///
    /// Prefer this over `.dfToastStyle(_:)` when you style the toast layer itself. Toasts are
    /// drawn in an overlay owned by `.dfToast()`, so they read the environment from *outside*
    /// this modifier: `content.dfToastStyle(.tinted).dfToast()` does NOT restyle them, while
    /// `content.dfToast(style: .tinted)` and `content.dfToast().dfToastStyle(.tinted)` do.
    func dfToast<S: DFToastStyle & Sendable>(queue: DFToastQueue = .shared, style: S) -> some View {
        modifier(DFToastModifier(queue: queue, style: AnyDFToastStyle(style)))
    }
}
