import SwiftUI

@MainActor
public final class DFToastQueue: ObservableObject {
    public static let shared = DFToastQueue()

    @Published public var messages: [DFToastMessage] = []

    public init() {}

    public func show(_ message: DFToastMessage) {
        messages.append(message)
    }

    public func show(text: String, icon: String? = nil, duration: TimeInterval = 3.0) {
        show(DFToastMessage(text: text, icon: icon, duration: duration))
    }

    public func dismiss(id: UUID) {
        messages.removeAll { $0.id == id }
    }
}
