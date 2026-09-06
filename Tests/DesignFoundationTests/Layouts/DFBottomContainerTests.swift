import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFBottomContainer")
struct DFBottomContainerTests {
    @Test("dfBottomBar modifier compiles and can be applied to any view")
    @MainActor
    func modifierApplies() {
        let view = Text("Content")
            .dfBottomBar {
                Text("Bottom bar")
            }
        #expect(view is any View)
    }
}
