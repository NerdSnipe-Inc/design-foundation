import SwiftUI

#if DEBUG

#Preview("All variants — filled") {
    HStack(spacing: 12) {
        DFChip("Label")
        DFChip(.labelWithIcon("Filter", systemImage: "line.3.horizontal.decrease"))
        DFChip(.dismissible("Removable", onDismiss: {}))
        DFChip(.selectable("Selectable"), isSelected: true)
    }
    .padding()
}

#Preview("All styles") {
    VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 12) {
            DFChip("Filled").dfChipStyle(.filled)
            DFChip("Tinted").dfChipStyle(.tinted)
            DFChip("Outlined").dfChipStyle(.outlined)
        }
        HStack(spacing: 12) {
            DFChip(.selectable("Filled"), isSelected: true).dfChipStyle(.filled)
            DFChip(.selectable("Tinted"), isSelected: true).dfChipStyle(.tinted)
            DFChip(.selectable("Outlined"), isSelected: true).dfChipStyle(.outlined)
        }
    }
    .padding()
}

#Preview("Dark mode") {
    HStack(spacing: 12) {
        DFChip("Label")
        DFChip(.dismissible("Removable", onDismiss: {}))
    }
    .padding()
    .preferredColorScheme(.dark)
}

#endif
