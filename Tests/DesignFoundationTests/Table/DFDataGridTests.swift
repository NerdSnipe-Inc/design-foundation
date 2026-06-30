import Testing
import SwiftUI
@testable import DesignFoundation

private struct GridPerson: Identifiable, Sendable {
    let id: Int
    var name: String
    var email: String
}

private func personGridColumns(editableName: Bool = true) -> [DFDataGridColumn<GridPerson>] {
    [
        DFDataGridColumn(
            id: "name",
            title: "Name",
            editable: editableName,
            validators: [DFRequiredValidator(), DFMinLengthValidator(minLength: 2)]
        ) { $0.name },
        DFDataGridColumn(id: "email", title: "Email", editable: false) { $0.email },
        DFDataGridColumn(id: "hidden", title: "Hidden", defaultVisible: false) { _ in "x" },
    ]
}

@Suite("DFDataGridColumn")
struct DFDataGridColumnTests {
    @Test("maps to DFDataTableColumn for shared helpers")
    func tableColumnMapping() {
        let column = DFDataGridColumn<GridPerson>(id: "name", title: "Name") { $0.name }
        let table = column.tableColumn()
        #expect(table.id == "name")
        #expect(table.title == "Name")
        #expect(table.value(GridPerson(id: 1, name: "Ada", email: "a@x.com")) == "Ada")
    }

    @Test("carries edit and visibility metadata")
    func metadata() {
        let column = DFDataGridColumn<GridPerson>(
            id: "name",
            title: "Name",
            editable: true,
            defaultVisible: false,
            validators: [DFRequiredValidator()]
        ) { $0.name }
        #expect(column.editable == true)
        #expect(column.defaultVisible == false)
        #expect(column.validators.count == 1)
    }
}

@Suite("DFDataGrid column visibility")
struct DFDataGridVisibilityTests {
    @Test("filters columns by visibility map")
    func visibleColumns() {
        let columns = personGridColumns()
        let visible = DFDataGridSupport.visibleColumns(
            columns,
            visibility: ["name": true, "email": true, "hidden": false]
        )
        #expect(visible.map(\.id) == ["name", "email"])
    }

    @Test("defaults to column defaultVisible when key missing")
    func defaultVisibility() {
        let columns = personGridColumns()
        let visible = DFDataGridSupport.visibleColumns(columns, visibility: [:])
        #expect(visible.map(\.id) == ["name", "email"])
    }
}

@Suite("DFDataGrid paging")
struct DFDataGridPagingTests {
    private let people = (1...120).map {
        GridPerson(id: $0, name: "Person \($0)", email: "p\($0)@example.com")
    }

    @Test("renderAll returns full row set")
    func renderAll() {
        let result = DFDataGridSupport.pagedRows(people, strategy: .renderAll, pageIndex: 0)
        #expect(result.rows.count == 120)
        #expect(result.pageCount == 1)
    }

    @Test("paged strategy slices rows")
    func pagedSlice() {
        let result = DFDataGridSupport.pagedRows(
            people,
            strategy: .paged(pageSize: 50),
            pageIndex: 1
        )
        #expect(result.rows.count == 50)
        #expect(result.rows.first?.id == 51)
        #expect(result.pageIndex == 1)
        #expect(result.pageCount == 3)
    }

    @Test("paged strategy clamps page index")
    func clampPage() {
        let result = DFDataGridSupport.pagedRows(
            people,
            strategy: .paged(pageSize: 50),
            pageIndex: 99
        )
        #expect(result.pageIndex == 2)
        #expect(result.rows.count == 20)
    }

    @Test("page size minimum is 1")
    func minimumPageSize() {
        let small = (1...3).map { GridPerson(id: $0, name: "P\($0)", email: "e") }
        let result = DFDataGridSupport.pagedRows(
            small,
            strategy: .paged(pageSize: 0),
            pageIndex: 0
        )
        #expect(result.rows.count == 1)
        #expect(result.pageCount == 3)
    }
}

@Suite("DFDataGrid integration")
struct DFDataGridIntegrationTests {
    @Test("compiles with selection, filter, bulk toolbar, and commit handler")
    @MainActor
    func compilesFullConfiguration() {
        let people = [GridPerson(id: 1, name: "Ada", email: "ada@example.com")]
        var selected: Set<Int> = []
        let _ = DFDataGrid(
            data: people,
            columns: personGridColumns(),
            selection: Binding(get: { selected }, set: { selected = $0 }),
            filterQuery: "ada",
            largeDatasetStrategy: .paged(pageSize: 25),
            onCellCommit: { _, _, _ in },
            onPageChange: { _ in },
            emptyContent: { Text("Empty") },
            bulkToolbar: { ids in
                Text("\(ids.count) selected")
            }
        )
    }

    @Test("reuses DFDataTable sort and filter for grid columns")
    func sharedSortFilter() {
        let people = [
            GridPerson(id: 1, name: "Bob", email: "b@x.com"),
            GridPerson(id: 2, name: "Ada", email: "a@x.com"),
        ]
        let tableColumns = DFDataGridSupport.tableColumns(from: personGridColumns())
        let filtered = DFDataTableSupport.filteredRows(people, columns: tableColumns, filterQuery: "ada")
        #expect(filtered.map(\.id) == [2])
        let sorted = DFDataTableSupport.sortedRows(
            filtered,
            columns: tableColumns,
            sortColumnID: "name",
            sortAscending: true
        )
        #expect(sorted.map(\.name) == ["Ada"])
    }
}
