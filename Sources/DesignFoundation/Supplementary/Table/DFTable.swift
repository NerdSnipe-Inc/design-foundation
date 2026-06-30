import SwiftUI

// MARK: - Column

public struct DFTableColumn<Row: Identifiable & Sendable>: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let sortable: Bool
    public let value: @Sendable (Row) -> String

    public init(
        id: String,
        title: String,
        sortable: Bool = true,
        value: @escaping @Sendable (Row) -> String
    ) {
        self.id = id
        self.title = title
        self.sortable = sortable
        self.value = value
    }
}

// MARK: - Table

public struct DFTable<Row: Identifiable & Sendable>: View {
    private let data: [Row]
    private let columns: [DFTableColumn<Row>]
    private let onSort: ((String, Bool) -> Void)?

    @Environment(\.dfTheme) private var theme
    @State private var sortColumnID: String? = nil
    @State private var sortAscending: Bool = true

    public init(
        data: [Row],
        columns: [DFTableColumn<Row>],
        onSort: ((String, Bool) -> Void)? = nil
    ) {
        self.data = data
        self.columns = columns
        self.onSort = onSort
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerRow
            Divider()
                .overlay(theme.colors.border)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(sortedData) { row in
                        dataRow(row)
                        Divider()
                            .overlay(theme.colors.border)
                    }
                }
            }
        }
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            ForEach(columns) { col in
                Button {
                    if sortColumnID == col.id {
                        sortAscending.toggle()
                    } else {
                        sortColumnID = col.id
                        sortAscending = true
                    }
                    onSort?(col.id, sortAscending)
                } label: {
                    HStack(spacing: 4) {
                        Text(col.title)
                            .font(theme.typography.label.font)
                            .foregroundStyle(theme.colors.textSecondary)
                        if col.sortable && sortColumnID == col.id {
                            Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(theme.colors.primary)
                                .accessibilityLabel("\(col.title), sorted \(sortAscending ? "ascending" : "descending")")
                        }
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .disabled(!col.sortable)
            }
        }
        .background(theme.colors.surfaceElevated)
    }

    private func dataRow(_ row: Row) -> some View {
        HStack(spacing: 0) {
            ForEach(columns) { col in
                Text(col.value(row))
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.textPrimary)
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var sortedData: [Row] {
        guard let id = sortColumnID,
              let col = columns.first(where: { $0.id == id }) else {
            return data
        }
        return data.sorted {
            sortAscending
                ? col.value($0) < col.value($1)
                : col.value($0) > col.value($1)
        }
    }
}
