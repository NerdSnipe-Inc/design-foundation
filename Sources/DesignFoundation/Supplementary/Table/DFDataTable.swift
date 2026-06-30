import SwiftUI

// MARK: - Column

/// Shared column descriptor for `DFDataTable`; aliases `DFTableColumn`.
public typealias DFDataTableColumn<Row> = DFTableColumn<Row> where Row: Identifiable & Sendable

// MARK: - Selection mode

public enum DFDataTableSelectionMode: Sendable {
    case none
    case single
    case multiple
}

// MARK: - Sort & selection helpers

enum DFDataTableSupport {
    static func sortedRows<Row: Identifiable & Sendable>(
        _ data: [Row],
        columns: [DFDataTableColumn<Row>],
        sortColumnID: String?,
        sortAscending: Bool
    ) -> [Row] {
        guard let id = sortColumnID,
              let column = columns.first(where: { $0.id == id }) else {
            return data
        }
        return data.sorted {
            sortAscending
                ? column.value($0) < column.value($1)
                : column.value($0) > column.value($1)
        }
    }

    static func toggledSelection<ID: Hashable>(
        _ id: ID,
        in selection: Set<ID>,
        mode: DFDataTableSelectionMode
    ) -> Set<ID> {
        switch mode {
        case .none:
            return selection
        case .single:
            return selection.contains(id) ? [] : [id]
        case .multiple:
            var updated = selection
            if updated.contains(id) {
                updated.remove(id)
            } else {
                updated.insert(id)
            }
            return updated
        }
    }

    static func showsEmptyState<Row>(data: [Row]) -> Bool {
        data.isEmpty
    }

    /// Concatenates all column string values for a row (space-separated).
    static func rowSearchText<Row>(
        _ row: Row,
        columns: [DFDataTableColumn<Row>]
    ) -> String {
        columns.map { $0.value(row) }.joined(separator: " ")
    }

    /// Filters rows when `filterQuery` is non-empty (case-insensitive substring match on `rowSearchText`).
    static func filteredRows<Row: Identifiable & Sendable>(
        _ data: [Row],
        columns: [DFDataTableColumn<Row>],
        filterQuery: String
    ) -> [Row] {
        let query = filterQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return data }
        let needle = query.lowercased()
        return data.filter { row in
            rowSearchText(row, columns: columns).lowercased().contains(needle)
        }
    }

    /// Moves row selection by one step for keyboard navigation (macOS scrollable fallback).
    static func keyboardMovedSelection<Row: Identifiable>(
        direction: Int,
        rows: [Row],
        current: Set<Row.ID>,
        mode: DFDataTableSelectionMode
    ) -> Set<Row.ID> {
        guard mode != .none, !rows.isEmpty, direction != 0 else { return current }
        let ids = rows.map(\.id)
        let anchorIndex: Int
        if let selected = current.first, let index = ids.firstIndex(of: selected) {
            anchorIndex = index
        } else {
            anchorIndex = direction > 0 ? -1 : ids.count
        }
        let nextIndex = min(max(anchorIndex + direction, 0), ids.count - 1)
        return [ids[nextIndex]]
    }
}

// MARK: - Data table

public struct DFDataTable<Row: Identifiable & Sendable, EmptyContent: View>: View {
    private let data: [Row]
    private let columns: [DFDataTableColumn<Row>]
    private let selection: Binding<Set<Row.ID>>?
    private let selectionMode: DFDataTableSelectionMode
    /// When non-empty, rows are kept when any column value contains this string (case-insensitive). Bind a search field to this parameter.
    private let filterQuery: String
    private let onSort: (@Sendable (String, Bool) -> Void)?
    private let onRowActivate: (@MainActor (Row) -> Void)?
    private let emptyContent: () -> EmptyContent

    @Environment(\.dfTheme) private var theme
    @State private var sortColumnID: String? = nil
    @State private var sortAscending: Bool = true
    #if os(macOS)
    @FocusState private var isTableFocused: Bool
    #endif

    public init(
        data: [Row],
        columns: [DFDataTableColumn<Row>],
        selection: Binding<Set<Row.ID>>? = nil,
        selectionMode: DFDataTableSelectionMode = .multiple,
        filterQuery: String = "",
        onSort: (@Sendable (String, Bool) -> Void)? = nil,
        onRowActivate: (@MainActor (Row) -> Void)? = nil,
        @ViewBuilder emptyContent: @escaping () -> EmptyContent = { EmptyView() }
    ) {
        self.data = data
        self.columns = columns
        self.selection = selection
        self.selectionMode = selectionMode
        self.filterQuery = filterQuery
        self.onSort = onSort
        self.onRowActivate = onRowActivate
        self.emptyContent = emptyContent
    }

    public var body: some View {
        Group {
            if DFDataTableSupport.showsEmptyState(data: displayRows) {
                emptyContent()
            } else {
                platformTable
            }
        }
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var platformTable: some View {
        #if os(macOS)
        macOSTable
        #else
        scrollableTable
        #endif
    }

    // MARK: macOS — native Table

    #if os(macOS)
    private var macOSTable: some View {
        VStack(spacing: 0) {
            headerRow
            Divider()
                .overlay(theme.colors.border)
            macOSNativeTable
        }
        .focusable()
        .focused($isTableFocused)
        .macOSRowActivationKeys(onReturn: activateSelectedRow, hasHandler: onRowActivate != nil)
    }

    @ViewBuilder
    private var macOSNativeTable: some View {
        if columns.isEmpty {
            scrollableTable
        } else if columns.count <= 6 {
            macOSStaticColumnTable
        } else {
            scrollableTable
        }
    }

    @ViewBuilder
    private var macOSStaticColumnTable: some View {
        let rows = displayRows
        let selectionBinding = macOSSelectionBinding

        switch columns.count {
        case 1:
            if let selectionBinding {
                Table(rows, selection: selectionBinding) {
                    TableColumn(columns[0].title) { (row: Row) in
                        cellContent(for: columns[0], row: row)
                    }
                }
            } else {
                Table(rows) {
                    TableColumn(columns[0].title) { (row: Row) in
                        cellContent(for: columns[0], row: row)
                    }
                }
            }
        case 2:
            if let selectionBinding {
                Table(rows, selection: selectionBinding) {
                    TableColumn(columns[0].title) { (row: Row) in cellContent(for: columns[0], row: row) }
                    TableColumn(columns[1].title) { (row: Row) in cellContent(for: columns[1], row: row) }
                }
            } else {
                Table(rows) {
                    TableColumn(columns[0].title) { (row: Row) in cellContent(for: columns[0], row: row) }
                    TableColumn(columns[1].title) { (row: Row) in cellContent(for: columns[1], row: row) }
                }
            }
        case 3:
            if let selectionBinding {
                Table(rows, selection: selectionBinding) {
                    TableColumn(columns[0].title) { (row: Row) in cellContent(for: columns[0], row: row) }
                    TableColumn(columns[1].title) { (row: Row) in cellContent(for: columns[1], row: row) }
                    TableColumn(columns[2].title) { (row: Row) in cellContent(for: columns[2], row: row) }
                }
            } else {
                Table(rows) {
                    TableColumn(columns[0].title) { (row: Row) in cellContent(for: columns[0], row: row) }
                    TableColumn(columns[1].title) { (row: Row) in cellContent(for: columns[1], row: row) }
                    TableColumn(columns[2].title) { (row: Row) in cellContent(for: columns[2], row: row) }
                }
            }
        case 4:
            if let selectionBinding {
                Table(rows, selection: selectionBinding) {
                    TableColumn(columns[0].title) { (row: Row) in cellContent(for: columns[0], row: row) }
                    TableColumn(columns[1].title) { (row: Row) in cellContent(for: columns[1], row: row) }
                    TableColumn(columns[2].title) { (row: Row) in cellContent(for: columns[2], row: row) }
                    TableColumn(columns[3].title) { (row: Row) in cellContent(for: columns[3], row: row) }
                }
            } else {
                Table(rows) {
                    TableColumn(columns[0].title) { (row: Row) in cellContent(for: columns[0], row: row) }
                    TableColumn(columns[1].title) { (row: Row) in cellContent(for: columns[1], row: row) }
                    TableColumn(columns[2].title) { (row: Row) in cellContent(for: columns[2], row: row) }
                    TableColumn(columns[3].title) { (row: Row) in cellContent(for: columns[3], row: row) }
                }
            }
        case 5:
            if let selectionBinding {
                Table(rows, selection: selectionBinding) {
                    TableColumn(columns[0].title) { (row: Row) in cellContent(for: columns[0], row: row) }
                    TableColumn(columns[1].title) { (row: Row) in cellContent(for: columns[1], row: row) }
                    TableColumn(columns[2].title) { (row: Row) in cellContent(for: columns[2], row: row) }
                    TableColumn(columns[3].title) { (row: Row) in cellContent(for: columns[3], row: row) }
                    TableColumn(columns[4].title) { (row: Row) in cellContent(for: columns[4], row: row) }
                }
            } else {
                Table(rows) {
                    TableColumn(columns[0].title) { (row: Row) in cellContent(for: columns[0], row: row) }
                    TableColumn(columns[1].title) { (row: Row) in cellContent(for: columns[1], row: row) }
                    TableColumn(columns[2].title) { (row: Row) in cellContent(for: columns[2], row: row) }
                    TableColumn(columns[3].title) { (row: Row) in cellContent(for: columns[3], row: row) }
                    TableColumn(columns[4].title) { (row: Row) in cellContent(for: columns[4], row: row) }
                }
            }
        case 6:
            if let selectionBinding {
                Table(rows, selection: selectionBinding) {
                    TableColumn(columns[0].title) { (row: Row) in cellContent(for: columns[0], row: row) }
                    TableColumn(columns[1].title) { (row: Row) in cellContent(for: columns[1], row: row) }
                    TableColumn(columns[2].title) { (row: Row) in cellContent(for: columns[2], row: row) }
                    TableColumn(columns[3].title) { (row: Row) in cellContent(for: columns[3], row: row) }
                    TableColumn(columns[4].title) { (row: Row) in cellContent(for: columns[4], row: row) }
                    TableColumn(columns[5].title) { (row: Row) in cellContent(for: columns[5], row: row) }
                }
            } else {
                Table(rows) {
                    TableColumn(columns[0].title) { (row: Row) in cellContent(for: columns[0], row: row) }
                    TableColumn(columns[1].title) { (row: Row) in cellContent(for: columns[1], row: row) }
                    TableColumn(columns[2].title) { (row: Row) in cellContent(for: columns[2], row: row) }
                    TableColumn(columns[3].title) { (row: Row) in cellContent(for: columns[3], row: row) }
                    TableColumn(columns[4].title) { (row: Row) in cellContent(for: columns[4], row: row) }
                    TableColumn(columns[5].title) { (row: Row) in cellContent(for: columns[5], row: row) }
                }
            }
        default:
            EmptyView()
        }
    }

    private var macOSSelectionBinding: Binding<Set<Row.ID>>? {
        guard selectionMode != .none, let selection else { return nil }
        return selection
    }

    private func cellContent(for column: DFDataTableColumn<Row>, row: Row) -> some View {
        Text(column.value(row))
            .font(theme.typography.body.font)
            .foregroundStyle(theme.colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                onRowActivate?(row)
            }
    }
    #endif

    // MARK: Scrollable rows (iOS + macOS wide tables)

    private var scrollableTable: some View {
        VStack(spacing: 0) {
            headerRow
            Divider()
                .overlay(theme.colors.border)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(displayRows) { row in
                        selectableDataRow(row)
                        Divider()
                            .overlay(theme.colors.border)
                    }
                }
            }
        }
        #if os(macOS)
        .focusable()
        .focused($isTableFocused)
        .macOSRowActivationKeys(onReturn: activateSelectedRow, hasHandler: onRowActivate != nil)
        .macOSKeyboardRowNavigation(
            isEnabled: selectionMode != .none && selection != nil,
            onUp: { moveKeyboardSelection(by: -1) },
            onDown: { moveKeyboardSelection(by: 1) }
        )
        #endif
    }

    // MARK: Shared header

    private var headerRow: some View {
        HStack(spacing: 0) {
            ForEach(columns) { column in
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
                                .accessibilityLabel("\(column.title), sorted \(sortAscending ? "ascending" : "descending")")
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

    private func selectableDataRow(_ row: Row) -> some View {
        let isSelected = selection?.wrappedValue.contains(row.id) ?? false

        return Button {
            updateSelection(for: row.id)
            #if !os(macOS)
            onRowActivate?(row)
            #endif
        } label: {
            HStack(spacing: 0) {
                ForEach(columns) { column in
                    Text(column.value(row))
                        .font(theme.typography.body.font)
                        .foregroundStyle(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.md)
                        .padding(.vertical, theme.spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .background(
                isSelected
                    ? theme.colors.interactiveFill.opacity(0.12)
                    : Color.clear
            )
        }
        .buttonStyle(.plain)
        .disabled(selectionMode == .none || selection == nil)
        #if os(macOS)
        .simultaneousGesture(
            TapGesture(count: 2).onEnded {
                onRowActivate?(row)
            }
        )
        #endif
    }

    // MARK: Sort & selection

    private var filteredData: [Row] {
        DFDataTableSupport.filteredRows(data, columns: columns, filterQuery: filterQuery)
    }

    private var displayRows: [Row] {
        DFDataTableSupport.sortedRows(
            filteredData,
            columns: columns,
            sortColumnID: sortColumnID,
            sortAscending: sortAscending
        )
    }

    private func toggleSort(for column: DFDataTableColumn<Row>) {
        guard column.sortable else { return }

        if sortColumnID == column.id {
            sortAscending.toggle()
        } else {
            sortColumnID = column.id
            sortAscending = true
        }
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
            rows: displayRows,
            current: selection.wrappedValue,
            mode: selectionMode
        )
    }
    #endif
}

#if os(macOS)
extension View {
    @ViewBuilder
    func macOSRowActivationKeys(onReturn: @escaping () -> Void, hasHandler: Bool) -> some View {
        if hasHandler {
            self.onKeyPress(.return) {
                onReturn()
                return .handled
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func macOSKeyboardRowNavigation(
        isEnabled: Bool,
        onUp: @escaping () -> Void,
        onDown: @escaping () -> Void
    ) -> some View {
        if isEnabled {
            self
                .onKeyPress(.upArrow) {
                    onUp()
                    return .handled
                }
                .onKeyPress(.downArrow) {
                    onDown()
                    return .handled
                }
        } else {
            self
        }
    }
}
#endif
