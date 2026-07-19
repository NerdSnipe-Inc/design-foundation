import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFEntityMedia")
struct DFEntityMediaTests {
    @Test("systemImage and avatarInitials cases are representable")
    func casesRepresentable() {
        let systemImage = DFEntityMedia.systemImage("star.fill")
        if case .systemImage(let name) = systemImage {
            #expect(name == "star.fill")
        } else {
            Issue.record("Expected .systemImage")
        }

        let avatar = DFEntityMedia.avatarInitials("JL")
        if case .avatarInitials(let initials) = avatar {
            #expect(initials == "JL")
        } else {
            Issue.record("Expected .avatarInitials")
        }
    }
}

@Suite("DFEntityTrailing")
struct DFEntityTrailingTests {
    @Test("text, badge, and chevron cases are representable")
    func casesRepresentable() {
        let text = DFEntityTrailing.text("2h ago")
        if case .text(let value) = text {
            #expect(value == "2h ago")
        } else {
            Issue.record("Expected .text")
        }

        let badge = DFEntityTrailing.badge("New")
        if case .badge(let value) = badge {
            #expect(value == "New")
        } else {
            Issue.record("Expected .badge")
        }

        if case .chevron = DFEntityTrailing.chevron {
            // passes
        } else {
            Issue.record("Expected .chevron")
        }
    }
}

@Suite("DFEntityRowTokens")
struct DFEntityRowTokensTests {
    @Test("default tokens are all nil (inherit from theme)")
    func defaultTokensAreNil() {
        #expect(DFEntityRowTokens.default.mediaSize == nil)
    }
}

@Suite("DFEntityCardTokens")
struct DFEntityCardTokensTests {
    @Test("default tokens are all nil (inherit from theme)")
    func defaultTokensAreNil() {
        #expect(DFEntityCardTokens.default.mediaHeight == nil)
    }
}
