import SwiftUI

private struct Fruit: Identifiable {
    let id: Int
    let name: String
    let icon: String
}

#Preview("DFList — Swipe and Reorder") {
    @Previewable @State var fruits = [
        Fruit(id: 1, name: "Apple", icon: "apple.logo"),
        Fruit(id: 2, name: "Banana", icon: "leaf"),
        Fruit(id: 3, name: "Cherry", icon: "cherry"),
        Fruit(id: 4, name: "Date", icon: "sun.max"),
    ]

    DFList(
        fruits,
        onDelete: { fruits.remove(atOffsets: $0) },
        onMove: { fruits.move(fromOffsets: $0, toOffset: $1) }
    ) { fruit in
        DFListRow(
            title: fruit.name,
            leading: { Image(systemName: fruit.icon) }
        )
    }
#if os(iOS)
    .environment(\.editMode, .constant(.active))
#endif
}

#Preview("DFList — Selection") {
    @Previewable @State var selected: Set<Int>? = []
    @Previewable @State var fruits = [
        Fruit(id: 1, name: "Apple", icon: "apple.logo"),
        Fruit(id: 2, name: "Banana", icon: "leaf"),
        Fruit(id: 3, name: "Cherry", icon: "cherry"),
    ]

    DFList(fruits, selection: $selected) { fruit in
        DFListRow(
            title: fruit.name,
            leading: { Image(systemName: fruit.icon) }
        )
    }
#if os(iOS)
    .environment(\.editMode, .constant(.active))
#endif
}
