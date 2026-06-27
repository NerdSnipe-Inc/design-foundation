import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFAvatarSource")
struct DFAvatarSourceTests {
    @Test("initials source holds string")
    func initialsSourceHoldsString() {
        let source = DFAvatarSource.initials("AB")
        if case .initials(let text) = source {
            #expect(text == "AB")
        } else {
            Issue.record("Expected .initials case")
        }
    }

    @Test("image source is representable")
    func imageSourceRepresentable() {
        let source = DFAvatarSource.image(Image(systemName: "person.fill"))
        if case .image = source { } else {
            Issue.record("Expected .image case")
        }
    }
}

@Suite("DFAvatarPresence")
struct DFAvatarPresenceTests {
    @Test("four presence states exist")
    func fourPresenceStates() {
        let all = DFAvatarPresence.allCases
        #expect(all.count == 4)
    }
}

@Suite("DFAvatarStyleConfiguration")
struct DFAvatarStyleConfigurationTests {
    @Test("configuration holds source, size, and presence")
    func configurationHoldsValues() {
        let config = DFAvatarStyleConfiguration(
            source: .initials("JD"),
            size: 40,
            presence: .online,
            theme: .default
        )
        #expect(config.size == 40)
        #expect(config.presence == .online)
    }
}

@Suite("DFAvatar Environment")
struct DFAvatarEnvironmentTests {
    @Test("dfAvatarStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfAvatarStyle
    }
}
