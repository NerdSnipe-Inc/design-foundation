import SwiftUI

public struct DFList<Data: RandomAccessCollection, RowContent: View>: View
where Data.Element: Identifiable, Data.Element.ID: Hashable {
    private let data: Data
    private let selection: Binding<Set<Data.Element.ID>?>?
    private let onDelete: ((IndexSet) -> Void)?
    private let onMove: ((IndexSet, Int) -> Void)?
    private let rowContent: (Data.Element) -> RowContent

    @Environment(\.dfTheme) private var theme

    public init(
        _ data: Data,
        selection: Binding<Set<Data.Element.ID>?>? = nil,
        onDelete: ((IndexSet) -> Void)? = nil,
        onMove: ((IndexSet, Int) -> Void)? = nil,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) {
        self.data = data
        self.selection = selection
        self.onDelete = onDelete
        self.onMove = onMove
        self.rowContent = rowContent
    }

    public var body: some View {
        List(selection: selection) {
            ForEach(data) { item in
                rowContent(item)
            }
            .onDelete(perform: onDelete)
            .onMove(perform: onMove)
        }
        .scrollContentBackground(.hidden)
        .background(theme.colors.background)
        .listStyle(.plain)
    }
}
