import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFAuthorView")
struct DFAuthorViewTests {
    @Test("initials initializer stores name and nil subtitle by default")
    func initialsInitializerDefaults() {
        let view = DFAuthorView(initials: "JL", name: "Jordan Lee")
        #expect(view.name == "Jordan Lee")
        #expect(view.subtitle == nil)
    }

    @Test("initials initializer stores an explicit subtitle")
    func initialsInitializerWithSubtitle() {
        let view = DFAuthorView(initials: "JL", name: "Jordan Lee", subtitle: "Staff Writer")
        #expect(view.subtitle == "Staff Writer")
    }

    @Test("image initializer stores name")
    func imageInitializerStoresName() {
        let view = DFAuthorView(image: Image(systemName: "person.fill"), name: "Jordan Lee")
        #expect(view.name == "Jordan Lee")
    }
}
