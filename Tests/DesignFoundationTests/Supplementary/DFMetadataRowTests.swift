import Testing
@testable import DesignFoundation

@Suite("DFMetadataItem")
struct DFMetadataItemTests {
    @Test("two items with different ids are not equal even with same label")
    func distinctIds() {
        let a = DFMetadataItem(systemImage: "clock", label: "5 min read")
        let b = DFMetadataItem(systemImage: "clock", label: "5 min read")
        #expect(a.id != b.id)
    }

    @Test("explicit id is preserved")
    func explicitId() {
        let item = DFMetadataItem(id: "read-time", systemImage: "clock", label: "5 min read")
        #expect(item.id == "read-time")
        #expect(item.label == "5 min read")
        #expect(item.systemImage == "clock")
    }
}

@Suite("DFMetadataRow")
struct DFMetadataRowTests {
    @Test("holds the items it was given, in order")
    func preservesOrder() {
        let items = [
            DFMetadataItem(id: "1", systemImage: "clock", label: "5 min read"),
            DFMetadataItem(id: "2", systemImage: "eye", label: "1.2k views")
        ]
        let row = DFMetadataRow(items: items)
        #expect(row.items.map(\.id) == ["1", "2"])
    }
}
