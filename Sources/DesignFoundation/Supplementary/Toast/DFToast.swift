import SwiftUI

// MARK: - Modifier

private struct DFToastModifier: ViewModifier {
    @ObservedObject var queue: DFToastQueue

    @Environment(\.dfTheme) private var theme
    @Environment(\.dfToastStyle) private var style

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let message = queue.messages.first {
                    style.makeBody(configuration: DFToastStyleConfiguration(
                        message: message,
                        theme: theme
                    ))
                    .padding(.top, theme.spacing.lg)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task(id: message.id) {
                        try? await Task.sleep(for: .seconds(message.duration))
                        if !Task.isCancelled {
                            queue.dismiss(id: message.id)
                        }
                    }
                }
            }
            .animation(theme.animation.fast, value: queue.messages.first?.id)
    }
}

// MARK: - View extension

@MainActor
public extension View {
    func dfToast(queue: DFToastQueue = .shared) -> some View {
        modifier(DFToastModifier(queue: queue))
    }
}
