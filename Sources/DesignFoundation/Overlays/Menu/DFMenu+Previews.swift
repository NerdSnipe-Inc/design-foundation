import SwiftUI

private let sampleSections: [DFMenuSection] = [
    DFMenuSection(title: "Sort by", items: [
        DFMenuItem(title: "Name", systemImage: "textformat", isSelected: true),
        DFMenuItem(title: "Date", systemImage: "calendar"),
        DFMenuItem(title: "Size", systemImage: "ruler", isDisabled: true),
    ]),
    DFMenuSection(items: [
        DFMenuItem(title: "Share", systemImage: "square.and.arrow.up"),
        DFMenuItem(title: "Delete", systemImage: "trash", role: .destructive),
    ]),
]

#Preview("DFMenu — Standard") {
    DFMenu("Options", sections: sampleSections)
        .padding(40)
        .dfThemePreset(.slate)
}

#Preview("DFMenu — Compact, with icon") {
    DFMenu("Options", systemImage: "ellipsis.circle", sections: sampleSections)
        .dfMenuStyle(.compact)
        .padding(40)
        .dfThemePreset(.slate)
}

#Preview("dfContextMenu") {
    DFCard { DFText("Press and hold") }
        .dfContextMenu(sections: sampleSections)
        .padding(40)
        .dfThemePreset(.slate)
}
