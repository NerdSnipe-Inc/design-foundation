import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFPopupPosition")
struct DFPopupPositionTests {
    @Test("has nine positions")
    func nine() {
        #expect(DFPopupPosition.allCases.count == 9)
    }

    @Test("exit edge follows the nearest screen edge")
    func exitEdges() {
        #expect(DFPopupPosition.topLeading.exitEdge == .top)
        #expect(DFPopupPosition.top.exitEdge == .top)
        #expect(DFPopupPosition.topTrailing.exitEdge == .top)
        #expect(DFPopupPosition.leading.exitEdge == .leading)
        #expect(DFPopupPosition.trailing.exitEdge == .trailing)
        #expect(DFPopupPosition.bottomLeading.exitEdge == .bottom)
        #expect(DFPopupPosition.bottom.exitEdge == .bottom)
        #expect(DFPopupPosition.bottomTrailing.exitEdge == .bottom)
        #expect(DFPopupPosition.center.exitEdge == .bottom)
    }

    @Test("alignment matches position")
    func alignments() {
        #expect(DFPopupPosition.topLeading.alignment == .topLeading)
        #expect(DFPopupPosition.center.alignment == .center)
        #expect(DFPopupPosition.bottomTrailing.alignment == .bottomTrailing)
    }
}

@Suite("DFPopupConfiguration")
struct DFPopupConfigurationTests {
    @Test("centered default dims and dismisses on outside tap")
    func centered() {
        let c = DFPopupConfiguration.centered
        #expect(c.kind == .center)
        #expect(c.position == .center)
        #expect(c.dimsBackground)
        #expect(c.dismissOnOutsideTap)
        #expect(c.autoDismissAfter == nil)
    }

    @Test("toast preset is flush, undimmed and pass-through")
    func toast() {
        let c = DFPopupConfiguration.toast(position: .bottom)
        #expect(c.kind == .toast)
        #expect(c.position == .bottom)
        #expect(!c.dimsBackground)
        #expect(!c.dismissOnOutsideTap)
        #expect(c.dismissOnTap)
        #expect(c.autoDismissAfter == 3)
    }

    @Test("floater preset persists until dismissed")
    func floater() {
        let c = DFPopupConfiguration.floater()
        #expect(c.kind == .floater)
        #expect(c.autoDismissAfter == nil)
        #expect(c.dismissOnDrag)
    }
}

@Suite("DFPopupDrag")
struct DFPopupDragTests {
    @Test("drag is constrained toward the exit edge only")
    func constrained() {
        #expect(DFPopupDrag.constrained(CGSize(width: 30, height: -40), toward: .top) == CGSize(width: 0, height: -40))
        #expect(DFPopupDrag.constrained(CGSize(width: 30, height: 40), toward: .top) == .zero)
        #expect(DFPopupDrag.constrained(CGSize(width: 30, height: 40), toward: .bottom) == CGSize(width: 0, height: 40))
        #expect(DFPopupDrag.constrained(CGSize(width: -30, height: 40), toward: .leading) == CGSize(width: -30, height: 0))
        #expect(DFPopupDrag.constrained(CGSize(width: 30, height: 40), toward: .trailing) == CGSize(width: 30, height: 0))
    }

    @Test("dismisses past the distance threshold")
    func distance() {
        #expect(DFPopupDrag.shouldDismiss(translation: CGSize(width: 0, height: -61), predictedEnd: .zero, toward: .top))
        #expect(!DFPopupDrag.shouldDismiss(translation: CGSize(width: 0, height: -20), predictedEnd: .zero, toward: .top))
    }

    @Test("dismisses on a fast flick even with short travel")
    func flick() {
        #expect(DFPopupDrag.shouldDismiss(
            translation: CGSize(width: 0, height: 20),
            predictedEnd: CGSize(width: 0, height: 400),
            toward: .bottom
        ))
    }

    @Test("dragging away from the exit edge never dismisses")
    func wrongWay() {
        #expect(!DFPopupDrag.shouldDismiss(
            translation: CGSize(width: 0, height: 300),
            predictedEnd: CGSize(width: 0, height: 900),
            toward: .top
        ))
    }
}

@Suite("DFPopupStyle")
struct DFPopupStyleTests {
    @Test("configuration holds values")
    func holds() {
        let c = DFPopupStyleConfiguration(content: AnyView(EmptyView()), kind: .toast, position: .top, theme: .default)
        #expect(c.kind == .toast)
        #expect(c.position == .top)
    }

    @Test("environment key has a default")
    func env() {
        var env = EnvironmentValues()
        _ = env.dfPopupStyle
        env.dfPopupStyle = AnyDFPopupStyle(DFStandardPopupStyle())
    }

    @Test("popup tokens default to nil so the theme is inherited")
    func tokens() {
        let t = DFTheme.default.components.popup
        #expect(t.cornerRadius == nil && t.padding == nil && t.maxWidth == nil && t.backdropOpacity == nil)
    }
}

@Suite("DFToast position")
@MainActor
struct DFToastPositionTests {
    @Test("messages default to the top")
    func defaultTop() {
        #expect(DFToastMessage(text: "Hi").position == .top)
    }

    @Test("queue forwards position")
    func queuePosition() {
        let q = DFToastQueue()
        q.show(text: "Hi", position: .bottomTrailing)
        #expect(q.messages.first?.position == .bottomTrailing)
    }
}
