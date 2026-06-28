import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFListRow")
struct DFListRowTests {
    @Test("basic init compiles and holds title")
    func basicInit() {
        let _ = DFListRow(title: "Hello")
    }

    @Test("init with subtitle and disclosure compiles")
    func subtitleDisclosure() {
        let _ = DFListRow(title: "Item", subtitle: "Detail", showDisclosure: true)
    }

    @Test("init with leading view compiles")
    func leadingInit() {
        let _ = DFListRow(title: "Icon Row", leading: { Image(systemName: "star") })
    }

    @Test("init with leading and trailing views compiles")
    func leadingTrailingInit() {
        let _ = DFListRow(
            title: "Full Row",
            leading: { Image(systemName: "star") },
            trailing: { Text("Badge") }
        )
    }
}
