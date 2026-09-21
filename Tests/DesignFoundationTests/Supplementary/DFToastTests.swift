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

@Suite("DFToastMessage additive fields")
struct DFToastMessageAdditiveTests {
    @Test("existing initializer calls keep working and default the new fields")
    func defaults() {
        let m = DFToastMessage(text: "Hi", icon: "star", duration: 2, severity: .success, position: .bottom)
        #expect(m.title == nil)
        #expect(m.actionTitle == nil)
        #expect(m.action == nil)
        #expect(!m.hasAction)
    }

    @Test("title and action are stored")
    func stored() {
        let m = DFToastMessage(text: "Moved", title: "Deleted", actionTitle: "Undo", action: {})
        #expect(m.title == "Deleted")
        #expect(m.actionTitle == "Undo")
        #expect(m.hasAction)
    }

    @Test("an action title without a closure is not an action")
    func incomplete() {
        #expect(!DFToastMessage(text: "x", actionTitle: "Undo").hasAction)
    }
}

@Suite("DFToastStyle built-ins")
@MainActor
struct DFToastBuiltInStyleTests {
    private func render<S: DFToastStyle & Sendable>(_ style: S) {
        let msg = DFToastMessage(text: "Saved", icon: "checkmark", severity: .success, title: "Done", actionTitle: "Undo", action: {})
        _ = AnyDFToastStyle(style).makeBody(configuration: DFToastStyleConfiguration(message: msg, theme: .default))
    }

    @Test("every static member exists and renders")
    func statics() {
        render(.default); render(.tinted); render(.filled); render(.inverse)
        render(.frosted); render(.banner); render(.compact)
        if #available(iOS 26, macOS 26, *) { render(.glass) }
    }

    @Test("layouts: only banner is flush")
    func layouts() {
        #expect(DFDefaultToastStyle().layout == .floating)
        #expect(DFCompactToastStyle().layout == .floating)
        #expect(DFBannerToastStyle().layout == .flush)
        #expect(AnyDFToastStyle(DFBannerToastStyle()).layout == .flush)
        #expect(AnyDFToastStyle(DFTintedToastStyle()).layout == .floating)
    }

    @Test("styles are distinct types")
    func distinct() {
        let types: [Any.Type] = [
            DFDefaultToastStyle.self, DFTintedToastStyle.self, DFFilledToastStyle.self, DFInverseToastStyle.self,
            DFFrostedToastStyle.self, DFBannerToastStyle.self, DFCompactToastStyle.self,
        ]
        #expect(Set(types.map { ObjectIdentifier($0) }).count == types.count)
    }
}

@Suite("DFToast action behavior")
@MainActor
struct DFToastActionTests {
    @Test("performAction runs the action then dismisses")
    func order() {
        var log: [String] = []
        let msg = DFToastMessage(text: "x", actionTitle: "Undo", action: { log.append("action") })
        let cfg = DFToastStyleConfiguration(message: msg, theme: .default, dismiss: { log.append("dismiss") })
        cfg.performAction()
        #expect(log == ["action", "dismiss"])
    }

    @Test("performAction without an action still dismisses; default dismiss is a no-op")
    func noAction() {
        var dismissed = false
        DFToastStyleConfiguration(message: DFToastMessage(text: "x"), theme: .default, dismiss: { dismissed = true }).performAction()
        #expect(dismissed)
        DFToastStyleConfiguration(message: DFToastMessage(text: "x"), theme: .default).performAction()
    }

    @Test("queue convenience forwards title and action")
    func queue() {
        let q = DFToastQueue()
        q.show(text: "Moved", title: "Deleted", actionTitle: "Undo", action: {})
        #expect(q.messages.first?.title == "Deleted")
        #expect(q.messages.first?.hasAction == true)
    }
}

@Suite("dfToast(style:)")
@MainActor
struct DFToastStyleModifierTests {
    @Test("style parameter compiles for every built-in toast style")
    func styleOverload() {
        let queue = DFToastQueue()
        _ = Color.clear.dfToast(queue: queue, style: .default)
        _ = Color.clear.dfToast(queue: queue, style: .tinted)
        _ = Color.clear.dfToast(queue: queue, style: .filled)
        _ = Color.clear.dfToast(queue: queue, style: .inverse)
        _ = Color.clear.dfToast(queue: queue, style: .frosted)
        _ = Color.clear.dfToast(queue: queue, style: .banner)
        _ = Color.clear.dfToast(queue: queue, style: .compact)
    }
}
