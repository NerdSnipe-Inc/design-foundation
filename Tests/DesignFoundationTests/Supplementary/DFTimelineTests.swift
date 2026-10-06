import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFTimelineItem")
struct DFTimelineItemTests {
    @Test("id defaults to the title and optional fields default to nil")
    func defaults() {
        let item = DFTimelineItem(title: "Packed")
        #expect(item.id == "Packed")
        #expect(item.detail == nil)
        #expect(item.timestamp == nil)
        #expect(item.systemImage == nil)
        #expect(item.trailing == nil)
        #expect(item.state == .upcoming)
    }

    @Test("holds all values")
    func holdsValues() {
        let item = DFTimelineItem(
            id: "p", title: "Packed", detail: "Leaving today", timestamp: "9:41 AM",
            systemImage: "shippingbox", state: .current, trailing: .badge("New")
        )
        #expect(item.id == "p")
        #expect(item.detail == "Leaving today")
        #expect(item.timestamp == "9:41 AM")
        #expect(item.systemImage == "shippingbox")
        #expect(item.state == .current)
        if case .badge(let text)? = item.trailing {
            #expect(text == "New")
        } else {
            Issue.record("expected a badge trailing value")
        }
    }
}

@Suite("DFTimeline Styles")
struct DFTimelineStyleTests {
    @Test("built-in styles are Sendable")
    func sendable() {
        let _: any DFTimelineStyle & Sendable = DFStandardTimelineStyle()
        let _: any DFTimelineStyle & Sendable = DFCompactTimelineStyle()
    }

    @Test("static shorthands resolve")
    func shorthands() {
        let _: DFStandardTimelineStyle = .standard
        let _: DFCompactTimelineStyle = .compact
    }

    @Test("dfTimelineStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfTimelineStyle
    }

    @Test("both styles build a body, including with no items")
    @MainActor
    func buildsBodies() {
        let items = [
            DFTimelineItem(title: "A", detail: "d", timestamp: "t", systemImage: "star", state: .complete, trailing: .text("x")),
            DFTimelineItem(title: "B", state: .current, trailing: .chevron),
            DFTimelineItem(title: "C", state: .error),
            DFTimelineItem(title: "D"),
        ]
        for list in [items, []] {
            let config = DFTimelineStyleConfiguration(items: list, theme: .default)
            let _ = AnyDFTimelineStyle(DFStandardTimelineStyle()).makeBody(configuration: config)
            let _ = AnyDFTimelineStyle(DFCompactTimelineStyle()).makeBody(configuration: config)
        }
    }

    @Test("DFTimeline initializes")
    @MainActor
    func initializes() {
        let _ = DFTimeline(items: [DFTimelineItem(title: "A")])
    }
}

@Suite("DFTimelineTokens")
struct DFTimelineTokensTests {
    @Test("defaults are nil so styles inherit")
    func defaultsNil() {
        let tokens = DFComponentTokens.default.timeline
        #expect(tokens.markerSize == nil)
        #expect(tokens.connectorThickness == nil)
    }

    @Test("overrides are stored on the root")
    func overrides() {
        let tokens = DFComponentTokens(timeline: DFTimelineTokens(markerSize: 24, connectorThickness: 1))
        #expect(tokens.timeline.markerSize == 24)
        #expect(tokens.timeline.connectorThickness == 1)
    }
}
