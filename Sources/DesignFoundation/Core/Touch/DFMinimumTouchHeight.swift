import SwiftUI

extension View {
    /// iOS only: keeps a control at least Apple's 44pt minimum touch target tall, and makes the whole
    /// box (not only the text inside it) respond to touches. Apply it BEFORE a `.background`, so the
    /// background grows with the control. A no-op on macOS and visionOS, where it must not change anything.
    @ViewBuilder
    nonisolated func dfMinimumTouchHeight() -> some View {
        #if os(iOS)
        self.frame(minHeight: 44).contentShape(Rectangle())
        #else
        self
        #endif
    }
}
