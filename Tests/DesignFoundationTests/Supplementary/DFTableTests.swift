import Testing
import SwiftUI
@testable import DesignFoundation

private struct Person: Identifiable, Sendable {
    let id: Int
    let name: String
    let age: Int
}

@Suite("DFTableColumn")
struct DFTableColumnTests {
    @Test("stores id, title, sortable flag, and value closure")
    func initialization() {
        let col = DFTableColumn<Person>(id: "name", title: "Name") { $0.name }
        #expect(col.id == "name")
        #expect(col.title == "Name")
        #expect(col.sortable == true)
        let person = Person(id: 1, name: "Alice", age: 30)
        #expect(col.value(person) == "Alice")
    }

    @Test("sortable defaults to true; can be set false")
    func sortableDefault() {
        let col = DFTableColumn<Person>(id: "age", title: "Age", sortable: false) { "\($0.age)" }
        #expect(col.sortable == false)
    }
}

@Suite("DFTable")
struct DFTableTests {
    @Test("compiles with data and columns")
    func basicInit() {
        let people = [Person(id: 1, name: "Alice", age: 30)]
        let cols = [DFTableColumn<Person>(id: "name", title: "Name") { $0.name }]
        let _ = DFTable(data: people, columns: cols)
    }

    @Test("compiles with onSort callback")
    func withOnSort() {
        let people = [Person(id: 1, name: "Alice", age: 30)]
        let cols = [DFTableColumn<Person>(id: "name", title: "Name") { $0.name }]
        let _ = DFTable(data: people, columns: cols, onSort: { _, _ in })
    }
}
