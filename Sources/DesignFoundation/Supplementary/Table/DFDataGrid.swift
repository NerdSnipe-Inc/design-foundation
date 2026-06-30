import SwiftUI

private enum DFDataGridEditField {
    static let value = "value"
}

// MARK: - Column

/// Column descriptor for `DFDataGrid` — extends table columns with edit and visibility metadata.
public struct DFDataGridColumn<Row: Identifiable & Sendable>: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let sortable: Bool
    public let editable: Bool
    public let defaultVisible: Bool
    public let validators: [any DFFieldValidator]
    public let value: @Sendable (Row) -> String

    public init(
        id: String,
        title: String,
        sortable: Bool = true,
        editable: Bool = false,
        defaultVisible: Bool = true,
        validators: [any DFFieldValidator] = [],
        value: @escaping @Sendable (Row) -> String
    ) {
        self.id = id
        self.title = title
        self.sortable = sortable
        self.editable = editable
        self.defaultVisible = defaultVisible
        self.validators = validators
        self.value = value
    }

    /// Shared table column for sort/filter helpers.
    public func tableColumn() -> DFDataTableColumn<Row> {
        DFDataTableColumn(id: id, title: title, sortable: sortable, value: value)
    }
}

// MARK: - Large dataset strategy

/// How `DFDataGrid` materializes rows for large collections.
///
/// **Guidance (G4):**
/// - `.renderAll` uses `LazyVStack` inside a `ScrollView` — ideal up to a few hundred rows on device.
/// - `.paged` keeps only one page in memory and shows prev/next controls — use for thousands of in-memory rows
///   or when pairing with server-driven paging (`onPageChange` loads the next slice).
/// - For unbounded remote datasets, prefer `.paged` with a small `pageSize` and fetch pages in `onPageChange`
///   rather than loading the full array into SwiftUI state.
public enum DFDataGridLargeDatasetStrategy: Sendable, Equatable {
    case renderAll
    case paged(pageSize: Int = 50)
}

// MARK: - Support

enum DFDataGridSupport {
    static func visibleColumns<Row>(
        _ columns: [DFDataGridColumn<Row>],
        visibility: [String: Bool]
    ) -> [DFDataGridColumn<Row>] {
        columns.filter { column in
            visibility[column.id, default: column.defaultVisible]
        }
    }

    static func tableColumns<Row>(
        from columns: [DFDataGridColumn<Row>]
    ) -> [DFDataTableColumn<Row>] {
        columns.map { $0.tableColumn() }
    }

    static func pagedRows<Row>(
        _ rows: [Row],
        strategy: DFDataGridLargeDatasetStrategy,
        pageIndex: Int
    ) -> (rows: [Row], pageIndex: Int, pageCount: Int) {
        switch strategy {
        case .renderAll:
            return (rows, 0, 1)
        case .paged(let pageSize):
            let size = max(pageSize, 1)
            let pageCount = max(Int(ceil(Double(rows.count) / Double(size))), 1)
            let clampedPage = min(max(pageIndex, 0), pageCount - 1)
            let start = clampedPage * size
            let end = min(start + size, rows.count)
            return (Array(rows[start..<end]), clampedPage, pageCount)
        }
    }
}

// MARK: - Data grid

public struct DFDataGrid<
    Row: Identifiable & Sendable,
    EmptyContent: View,
    BulkToolbarContent: View
>: View {
    private let data: [Row]
    private let columns: [DFDataGridColumn<Row>]
    private let selection: Binding<Set<Row.ID>>?
    private let selectionMode: DFDataTableSelectionMode
    private let filterQuery: String
    private let largeDatasetStrategy: DFDataGridLargeDatasetStrategy
    private let showsColumnConfiguration: Bool
    private let onSort: (@Sendable (String, Bool) -> Void)?
    private let onRowActivate: (@MainActor (Row) -> Void)?
    private let macOSActivatesOnSingleClick: Bool
    private let onCellCommit: (@MainActor (Row.ID, String, String) -> Void)?
    private let onPageChange: (@Sendable (Int) -> Void)?
    private let emptyContent: () -> EmptyContent
    private let bulkToolbar: (Set<Row.ID>) -> BulkToolbarContent

    @Environment(\.dfTheme) private var theme
    @State private var sortColumnID: String?
    @State private var sortAscending = true
    @State private var columnVisibility: [String: Bool] = [:]
    @State private var pageIndex = 0
    @State private var editingCell: EditingCell?
    @State private var editForm = DFFormState()
    #if os(macOS)
    @FocusState private var isGridFocused: Bool
    @FocusState private var isEditFieldFocused: Bool
    #endif

    private struct EditingCell: Equatable {
        let rowID: Row.ID
        let columnID: String
    }

    public init(
        data: [Row],
        columns: [DFDataGridColumn<Row>],
        selection: Binding<Set<Row.ID>>? = nil,
        selectionMode: DFDataTableSelectionMode = .multiple,
        filterQuery: String = "",
        largeDatasetStrategy: DFDataGridLargeDatasetStrategy = .renderAll,
        showsColumnConfiguration: Bool = true,
        onSort: (@Sendable (String, Bool) -> Void)? = nil,
        onRowActivate: (@MainActor (Row) -> Void)? = nil,
        macOSActivatesOnSingleClick: Bool = false,
        onCellCommit: (@MainActor (Row.ID, String, String) -> Void)? = nil,
        onPageChange: (@Sendable (Int) -> Void)? = nil
    ) where EmptyContent == EmptyView, BulkToolbarContent == EmptyView {
        self.init(
            data: data,
            columns: columns,
            selection: selection,
            selectionMode: selectionMode,
            filterQuery: filterQuery,
            largeDatasetStrategy: largeDatasetStrategy,
            showsColumnConfiguration: showsColumnConfiguration,
            onSort: onSort,
            onRowActivate: onRowActivate,
            macOSActivatesOnSingleClick: macOSActivatesOnSingleClick,
            onCellCommit: onCellCommit,
            onPageChange: onPageChange,
            emptyContent: { EmptyView() },
            bulkToolbar: { _ in EmptyView() }
        )
    }

    public init(
        data: [Row],
        columns: [DFDataGridColumn<Row>],
        selection: Binding<Set<Row.ID>>? = nil,
        selectionMode: DFDataTableSelectionMode = .multiple,
        filterQuery: String = "",
        largeDatasetStrategy: DFDataGridLargeDatasetStrategy = .renderAll,
        showsColumnConfiguration: Bool = true,
        onSort: (@Sendable (String, Bool) -> Void)? = nil,
        onRowActivate: (@MainActor (Row) -> Void)? = nil,
        macOSActivatesOnSingleClick: Bool = false,
        onCellCommit: (@MainActor (Row.ID, String, String) -> Void)? = nil,
        onPageChange: (@Sendable (Int) -> Void)? = nil,
        @ViewBuilder emptyContent: @escaping () -> EmptyContent,
        @ViewBuilder bulkToolbar: @escaping (Set<Row.ID>) -> BulkToolbarContent
    ) {
        self.data = data
        self.columns = columns
        self.selection = selection
        self.selectionMode = selectionMode
        self.filterQuery = filterQuery
        self.largeDatasetStrategy = largeDatasetStrategy
        self.showsColumnConfiguration = showsColumnConfiguration
        self.onSort = onSort
        self.onRowActivate = onRowActivate
        self.macOSActivatesOnSingleClick = macOSActivatesOnSingleClick
        self.onCellCommit = onCellCommit
        self.onPageChange = onPageChange
        self.emptyContent = emptyContent
        self.bulkToolbar = bulkToolbar
    }

    public var body: some View {
        VStack(spacing: 0) {
            if showsSelectionToolbar {
                bulkToolbarRow
                Divider().overlay(theme.colors.border)
            }

            Group {
                if DFDataTableSupport.showsEmptyState(data: windowedRows.rows) && filteredData.isEmpty {
                    emptyContent()
                } else {
                    gridBody
                }
            }
        }
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .onAppear(perform: seedColumnVisibilityIfNeeded)
    }

    // MARK: Body sections

    private var gridBody: some View {
        VStack(spacing: 0) {
            toolbarRow
            Divider().overlay(theme.colors.border)
            headerRow
            Divider().overlay(theme.colors.border)
            scrollableRows
            if showsPagingFooter {
                Divider().overlay(theme.colors.border)
                pagingFooter
            }
        }
    }

    private var toolbarRow: some View {
        HStack(spacing: theme.spacing.sm) {
            if showsColumnConfiguration {
                columnConfigurationMenu
            }
            Spacer(minLength: 0)
            if case .paged = largeDatasetStrategy {
                Text(pageSummaryLabel)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.xs)
        .background(theme.colors.surfaceElevated)
    }

    private var bulkToolbarRow: some View {
        HStack(spacing: theme.spacing.md) {
            Text("\(selection?.wrappedValue.count ?? 0) selected")
                .font(theme.typography.label.font)
                .foregroundStyle(theme.colors.textSecondary)
            bulkToolbar(selection?.wrappedValue ?? [])
            Spacer(minLength: 0)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(theme.colors.interactiveFill.opacity(0.08))
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            ForEach(activeColumns) { column in
                Button {
                    toggleSort(for: column)
                } label: {
                    HStack(spacing: 4) {
                        Text(column.title)
                            .font(theme.typography.label.font)
                            .foregroundStyle(theme.colors.textSecondary)
                        if column.sortable && sortColumnID == column.id {
                            Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(theme.colors.primary)
                        }
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .disabled(!column.sortable)
            }
        }
        .background(theme.colors.surfaceElevated)
    }

    private var scrollableRows: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(windowedRows.rows) { row in
                    selectableDataRow(row)
                    Divider().overlay(theme.colors.border)
                }
            }
        }
        #if os(macOS)
        .focusable()
        .focused($isGridFocused)
        .macOSRowActivationKeys(onReturn: activateSelectedRow, hasHandler: onRowActivate != nil)
        .macOSKeyboardRowNavigation(
            isEnabled: selectionMode != .none && selection != nil && editingCell == nil,
            onUp: { moveKeyboardSelection(by: -1) },
            onDown: { moveKeyboardSelection(by: 1) }
        )
        #endif
    }

    private var pagingFooter: some View {
        HStack(spacing: theme.spacing.md) {
            Button {
                changePage(by: -1)
            } label: {
                Label("Previous", systemImage: "chevron.left")
                    .font(theme.typography.caption.font)
            }
            .buttonStyle(.plain)
            .disabled(windowedRows.pageIndex <= 0)

            Text("Page \(windowedRows.pageIndex + 1) of \(windowedRows.pageCount)")
                .font(theme.typography.caption.font)
                .foregroundStyle(theme.colors.textSecondary)

            Button {
                changePage(by: 1)
            } label: {
                Label("Next", systemImage: "chevron.right")
                    .font(theme.typography.caption.font)
            }
            .buttonStyle(.plain)
            .disabled(windowedRows.pageIndex >= windowedRows.pageCount - 1)

            Spacer(minLength: 0)

            Text("\(displayRows.count) total rows")
                .font(theme.typography.caption.font)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(theme.colors.surfaceElevated)
    }

    private var columnConfigurationMenu: some View {
        Menu {
            ForEach(columns) { column in
                Toggle(isOn: columnVisibilityBinding(for: column)) {
                    Text(column.title)
                }
            }
        } label: {
            Label("Columns", systemImage: "tablecells")
                .font(theme.typography.caption.font)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .menuStyle(.borderlessButton)
    }

    // MARK: Row rendering

    private func selectableDataRow(_ row: Row) -> some View {
        let isSelected = selection?.wrappedValue.contains(row.id) ?? false

        return HStack(spacing: 0) {
            ForEach(activeColumns) { column in
                cellView(for: column, row: row)
            }
        }
        .background(isSelected ? theme.colors.interactiveFill.opacity(0.12) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            guard editingCell == nil else { return }
            updateSelection(for: row.id)
            #if os(macOS)
            if macOSActivatesOnSingleClick {
                onRowActivate?(row)
            }
            #else
            onRowActivate?(row)
            #endif
        }
        #if os(macOS)
        .simultaneousGesture(
            TapGesture(count: 2).onEnded {
                if let column = activeColumns.first(where: { $0.editable }) {
                    beginEditing(row: row, column: column)
                } else {
                    onRowActivate?(row)
                }
            }
        )
        #endif
    }

    @ViewBuilder
    private func cellView(for column: DFDataGridColumn<Row>, row: Row) -> some View {
        let isEditing = editingCell?.rowID == row.id && editingCell?.columnID == column.id

        Group {
            if isEditing {
                inlineEditField(for: column, row: row)
            } else {
                Text(column.value(row))
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) {
                        guard column.editable else { return }
                        beginEditing(row: row, column: column)
                    }
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func inlineEditField(for column: DFDataGridColumn<Row>, row: Row) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            TextField(column.title, text: editForm.binding(for: DFDataGridEditField.value))
                .textFieldStyle(.plain)
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.textPrimary)
                #if os(macOS)
                .focused($isEditFieldFocused)
                #endif
                .onSubmit { commitEdit(for: row.id, column: column) }

            if case .error(let message) = editForm.validationState(for: DFDataGridEditField.value) {
                Text(message)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.destructive)
                    .lineLimit(2)
            }
        }
        .onAppear {
            #if os(macOS)
            isEditFieldFocused = true
            #endif
        }
    }

    // MARK: Derived data

    private var activeColumns: [DFDataGridColumn<Row>] {
        DFDataGridSupport.visibleColumns(columns, visibility: columnVisibility)
    }

    private var tableColumns: [DFDataTableColumn<Row>] {
        DFDataGridSupport.tableColumns(from: activeColumns)
    }

    private var filteredData: [Row] {
        DFDataTableSupport.filteredRows(data, columns: tableColumns, filterQuery: filterQuery)
    }

    private var displayRows: [Row] {
        DFDataTableSupport.sortedRows(
            filteredData,
            columns: tableColumns,
            sortColumnID: sortColumnID,
            sortAscending: sortAscending
        )
    }

    private var windowedRows: (rows: [Row], pageIndex: Int, pageCount: Int) {
        DFDataGridSupport.pagedRows(displayRows, strategy: largeDatasetStrategy, pageIndex: pageIndex)
    }

    private var showsSelectionToolbar: Bool {
        selectionMode != .none && !(selection?.wrappedValue.isEmpty ?? true)
    }

    private var showsPagingFooter: Bool {
        if case .paged = largeDatasetStrategy {
            return displayRows.count > 0
        }
        return false
    }

    private var pageSummaryLabel: String {
        "Showing \(windowedRows.rows.count) of \(displayRows.count)"
    }

    // MARK: Actions

    private func seedColumnVisibilityIfNeeded() {
        guard columnVisibility.isEmpty else { return }
        columnVisibility = Dictionary(uniqueKeysWithValues: columns.map { ($0.id, $0.defaultVisible) })
    }

    private func columnVisibilityBinding(for column: DFDataGridColumn<Row>) -> Binding<Bool> {
        Binding(
            get: { columnVisibility[column.id, default: column.defaultVisible] },
            set: { columnVisibility[column.id] = $0 }
        )
    }

    private func toggleSort(for column: DFDataGridColumn<Row>) {
        guard column.sortable else { return }
        if sortColumnID == column.id {
            sortAscending.toggle()
        } else {
            sortColumnID = column.id
            sortAscending = true
        }
        pageIndex = 0
        onSort?(column.id, sortAscending)
    }

    private func updateSelection(for id: Row.ID) {
        guard selectionMode != .none, let selection else { return }
        selection.wrappedValue = DFDataTableSupport.toggledSelection(
            id,
            in: selection.wrappedValue,
            mode: selectionMode
        )
    }

    private func activateSelectedRow() {
        guard let onRowActivate, let selection, !selection.wrappedValue.isEmpty else { return }
        guard let row = displayRows.first(where: { selection.wrappedValue.contains($0.id) }) else { return }
        onRowActivate(row)
    }

    #if os(macOS)
    private func moveKeyboardSelection(by direction: Int) {
        guard selectionMode != .none, let selection else { return }
        selection.wrappedValue = DFDataTableSupport.keyboardMovedSelection(
            direction: direction,
            rows: windowedRows.rows,
            current: selection.wrappedValue,
            mode: selectionMode
        )
    }
    #endif

    private func changePage(by delta: Int) {
        let next = windowedRows.pageIndex + delta
        pageIndex = next
        onPageChange?(next)
    }

    private func beginEditing(row: Row, column: DFDataGridColumn<Row>) {
        guard column.editable, onCellCommit != nil else { return }
        editingCell = EditingCell(rowID: row.id, columnID: column.id)
        editForm = DFFormState(
            fields: [DFDataGridEditField.value: column.validators],
            initialValues: [DFDataGridEditField.value: column.value(row)]
        )
    }

    private func commitEdit(for rowID: Row.ID, column: DFDataGridColumn<Row>) {
        guard editForm.validate(field: DFDataGridEditField.value) else { return }
        let newValue = editForm.values[DFDataGridEditField.value, default: ""]
        onCellCommit?(rowID, column.id, newValue)
        editingCell = nil
    }
}
