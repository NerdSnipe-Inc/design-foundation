import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFToastMessage")
struct DFToastMessageTests {
    @Test("stores text and icon")
    func storesValues() {
        let msg = DFToastMessage(text: "Hello", icon: "star.fill")
        #expect(msg.text == "Hello")
        #expect(msg.icon == "star.fill")
    }

    @Test("default duration is 3 seconds")
    func defaultDuration() {
        let msg = DFToastMessage(text: "Test")
        #expect(msg.duration == 3.0)
        #expect(msg.icon == nil)
    }
}

@Suite("DFToastStyleConfiguration")
struct DFToastStyleConfigurationTests {
    @Test("holds message and theme")
    func holdsValues() {
        let msg = DFToastMessage(text: "Hi")
        let config = DFToastStyleConfiguration(message: msg, theme: .default)
        #expect(config.message.text == "Hi")
    }
}

@Suite("DFToast Environment")
struct DFToastEnvironmentTests {
    @Test("dfToastStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfToastStyle
    }
}

@Suite("DFToast Styles")
struct DFToastStyleTests {
    @Test("default style is Sendable")
    func defaultSendable() {
        let _: any DFToastStyle & Sendable = DFDefaultToastStyle()
    }

    @Test("AnyDFToastStyle wraps and invokes makeBody")
    func typeErasure() {
        let style = AnyDFToastStyle(DFDefaultToastStyle())
        let config = DFToastStyleConfiguration(message: DFToastMessage(text: "Test"), theme: .default)
        let _ = style.makeBody(configuration: config)
    }
}

@Suite("DFToastQueue")
@MainActor
struct DFToastQueueTests {
    @Test("show appends message")
    func showAppends() {
        let queue = DFToastQueue()
        queue.show(DFToastMessage(text: "A"))
        #expect(queue.messages.count == 1)
        #expect(queue.messages[0].text == "A")
    }

    @Test("dismiss removes message by id")
    func dismissRemoves() {
        let queue = DFToastQueue()
        let msg = DFToastMessage(text: "B")
        queue.show(msg)
        queue.dismiss(id: msg.id)
        #expect(queue.messages.isEmpty)
    }
}
