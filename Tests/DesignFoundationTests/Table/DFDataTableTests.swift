import Testing
import SwiftUI
@testable import DesignFoundation

private struct Person: Identifiable, Sendable {
    let id: Int
    let name: String
    let age: Int
}

private func personColumns() -> [DFDataTableColumn<Person>] {
    [
        DFDataTableColumn(id: "name", title: "Name") { $0.name },
        DFDataTableColumn(id: "age", title: "Age") { "\($0.age)" },
    ]
}

@Suite("DFDataTableColumn")
struct DFDataTableColumnTests {
    @Test("aliases DFTableColumn API")
    func columnAlias() {
        let col = DFDataTableColumn<Person>(id: "name", title: "Name") { $0.name }
        #expect(col.id == "name")
        #expect(col.title == "Name")
        #expect(col.sortable == true)
        let person = Person(id: 1, name: "Alice", age: 30)
        #expect(col.value(person) == "Alice")
    }
}

@Suite("DFDataTable sort")
struct DFDataTableSortTests {
    @Test("returns original order when no sort column is active")
    func unsorted() {
        let people = [
            Person(id: 1, name: "Bob", age: 25),
            Person(id: 2, name: "Alice", age: 30),
        ]
        let result = DFDataTableSupport.sortedRows(
            people,
            columns: personColumns(),
            sortColumnID: nil,
            sortAscending: true
        )
        #expect(result.map(\.id) == [1, 2])
    }

    @Test("sorts ascending by column value")
    func ascending() {
        let people = [
            Person(id: 1, name: "Bob", age: 25),
            Person(id: 2, name: "Alice", age: 30),
            Person(id: 3, name: "Carol", age: 20),
        ]
        let result = DFDataTableSupport.sortedRows(
            people,
            columns: personColumns(),
            sortColumnID: "name",
            sortAscending: true
        )
        #expect(result.map(\.name) == ["Alice", "Bob", "Carol"])
    }

    @Test("sorts descending by column value")
    func descending() {
        let people = [
            Person(id: 1, name: "Bob", age: 25),
            Person(id: 2, name: "Alice", age: 30),
        ]
        let result = DFDataTableSupport.sortedRows(
            people,
            columns: personColumns(),
            sortColumnID: "age",
            sortAscending: false
        )
        #expect(result.map(\.age) == [30, 25])
    }
}

@Suite("DFDataTable selection")
struct DFDataTableSelectionTests {
    @Test("single mode selects one row and deselects on second tap")
    func singleSelection() {
        var selection: Set<Int> = []
        selection = DFDataTableSupport.toggledSelection(1, in: selection, mode: .single)
        #expect(selection == [1])
        selection = DFDataTableSupport.toggledSelection(1, in: selection, mode: .single)
        #expect(selection.isEmpty)
        selection = DFDataTableSupport.toggledSelection(2, in: selection, mode: .single)
        #expect(selection == [2])
    }

    @Test("multiple mode toggles membership")
    func multipleSelection() {
        var selection: Set<Int> = []
        selection = DFDataTableSupport.toggledSelection(1, in: selection, mode: .multiple)
        selection = DFDataTableSupport.toggledSelection(2, in: selection, mode: .multiple)
        #expect(selection == [1, 2])
        selection = DFDataTableSupport.toggledSelection(1, in: selection, mode: .multiple)
        #expect(selection == [2])
    }

    @Test("none mode leaves selection unchanged")
    func noneSelection() {
        let selection: Set<Int> = [1]
        let result = DFDataTableSupport.toggledSelection(2, in: selection, mode: .none)
        #expect(result == [1])
    }

    @Test("compiles with selection binding and modes")
    @MainActor
    func selectionBindingCompiles() {
        let people = [Person(id: 1, name: "Alice", age: 30)]
        let columns = [DFDataTableColumn<Person>(id: "name", title: "Name") { $0.name }]
        var selected: Set<Int> = []
        let _ = DFDataTable(
            data: people,
            columns: columns,
            selection: Binding(get: { selected }, set: { selected = $0 }),
            selectionMode: .single
        )
        let _ = DFDataTable(
            data: people,
            columns: columns,
            selection: Binding(get: { selected }, set: { selected = $0 }),
            selectionMode: .multiple
        )
    }
}

@Suite("DFDataTable filter")
struct DFDataTableFilterTests {
    private let people = [
        Person(id: 1, name: "Alice", age: 30),
        Person(id: 2, name: "Bob", age: 25),
        Person(id: 3, name: "Carol", age: 35),
    ]

    @Test("returns all rows when filter query is empty")
    func emptyFilter() {
        let result = DFDataTableSupport.filteredRows(
            people,
            columns: personColumns(),
            filterQuery: ""
        )
        #expect(result.map(\.id) == [1, 2, 3])
    }

    @Test("returns all rows when filter query is whitespace only")
    func whitespaceFilter() {
        let result = DFDataTableSupport.filteredRows(
            people,
            columns: personColumns(),
            filterQuery: "   "
        )
        #expect(result.map(\.id) == [1, 2, 3])
    }

    @Test("matches any column value case-insensitively")
    func caseInsensitiveMatch() {
        let result = DFDataTableSupport.filteredRows(
            people,
            columns: personColumns(),
            filterQuery: "ALICE"
        )
        #expect(result.map(\.id) == [1])
    }

    @Test("matches substring across concatenated column text")
    func crossColumnMatch() {
        let result = DFDataTableSupport.filteredRows(
            people,
            columns: personColumns(),
            filterQuery: "bob 25"
        )
        #expect(result.map(\.id) == [2])
    }

    @Test("returns empty when nothing matches")
    func noMatch() {
        let result = DFDataTableSupport.filteredRows(
            people,
            columns: personColumns(),
            filterQuery: "zztop"
        )
        #expect(result.isEmpty)
    }

    @Test("rowSearchText joins column values with spaces")
    func rowSearchText() {
        let person = Person(id: 1, name: "Alice", age: 30)
        let text = DFDataTableSupport.rowSearchText(person, columns: personColumns())
        #expect(text == "Alice 30")
    }

    @Test("compiles with filterQuery binding")
    @MainActor
    func filterQueryCompiles() {
        let people = [Person(id: 1, name: "Alice", age: 30)]
        let columns = personColumns()
        let query = "ali"
        let _ = DFDataTable(data: people, columns: columns, filterQuery: query)
    }
}

@Suite("DFDataTable keyboard navigation")
struct DFDataTableKeyboardNavigationTests {
    private let people = [
        Person(id: 1, name: "Alice", age: 30),
        Person(id: 2, name: "Bob", age: 25),
        Person(id: 3, name: "Carol", age: 35),
    ]

    @Test("moves single selection down through rows")
    func moveDownSingle() {
        var selection: Set<Int> = [1]
        selection = DFDataTableSupport.keyboardMovedSelection(
            direction: 1,
            rows: people,
            current: selection,
            mode: .single
        )
        #expect(selection == [2])
    }

    @Test("moves single selection up through rows")
    func moveUpSingle() {
        var selection: Set<Int> = [2]
        selection = DFDataTableSupport.keyboardMovedSelection(
            direction: -1,
            rows: people,
            current: selection,
            mode: .single
        )
        #expect(selection == [1])
    }

    @Test("selects first row when moving down from empty selection")
    func moveDownFromEmpty() {
        let selection = DFDataTableSupport.keyboardMovedSelection(
            direction: 1,
            rows: people,
            current: [],
            mode: .single
        )
        #expect(selection == [1])
    }

    @Test("clamps at last row when moving down")
    func clampAtEnd() {
        let selection = DFDataTableSupport.keyboardMovedSelection(
            direction: 1,
            rows: people,
            current: [3],
            mode: .single
        )
        #expect(selection == [3])
    }

    @Test("multiple mode replaces selection on arrow move")
    func moveMultiple() {
        var selection: Set<Int> = [1, 3]
        selection = DFDataTableSupport.keyboardMovedSelection(
            direction: 1,
            rows: people,
            current: selection,
            mode: .multiple
        )
        #expect(selection == [2])
    }

    @Test("none mode leaves selection unchanged")
    func noneModeUnchanged() {
        let selection = DFDataTableSupport.keyboardMovedSelection(
            direction: 1,
            rows: people,
            current: [1],
            mode: .none
        )
        #expect(selection == [1])
    }

    @Test("compiles with onRowActivate callback")
    @MainActor
    func onRowActivateCompiles() {
        let people = [Person(id: 1, name: "Alice", age: 30)]
        let columns = personColumns()
        let _ = DFDataTable(data: people, columns: columns, onRowActivate: { _ in })
    }
}

@Suite("DFDataTable empty state")
struct DFDataTableEmptyStateTests {
    @Test("detects empty data")
    func showsEmptyState() {
        #expect(DFDataTableSupport.showsEmptyState(data: [Person]()) == true)
        #expect(DFDataTableSupport.showsEmptyState(data: [Person(id: 1, name: "A", age: 1)]) == false)
    }

    @Test("compiles with custom empty content")
    @MainActor
    func emptyContentBuilder() {
        let columns = [DFDataTableColumn<Person>(id: "name", title: "Name") { $0.name }]
        let _ = DFDataTable(data: [Person](), columns: columns, emptyContent: {
            Text("No people yet")
        })
    }

    @Test("compiles with onSort callback")
    @MainActor
    func withOnSort() {
        let people = [Person(id: 1, name: "Alice", age: 30)]
        let columns = [DFDataTableColumn<Person>(id: "name", title: "Name") { $0.name }]
        let _ = DFDataTable(data: people, columns: columns, onSort: { _, _ in })
    }
}
