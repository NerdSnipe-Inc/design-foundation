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

// ---- Append below DFListRowTests ----

private struct SampleItem: Identifiable {
    let id: Int
    let name: String
}

@Suite("DFList")
struct DFListTests {
    @Test("compiles with basic data")
    func basicInit() {
        let items = [SampleItem(id: 1, name: "A"), SampleItem(id: 2, name: "B")]
        let _ = DFList(items) { item in
            Text(item.name)
        }
    }

    @Test("compiles with onDelete callback")
    func withDelete() {
        let items = [SampleItem(id: 1, name: "A")]
        let _ = DFList(items, onDelete: { _ in }) { item in
            Text(item.name)
        }
    }

    @Test("compiles with selection binding")
    func withSelection() {
        var selection: Set<Int>? = []
        let items = [SampleItem(id: 1, name: "A")]
        let _ = DFList(items, selection: Binding(get: { selection }, set: { selection = $0 })) { item in
            Text(item.name)
        }
    }
}
