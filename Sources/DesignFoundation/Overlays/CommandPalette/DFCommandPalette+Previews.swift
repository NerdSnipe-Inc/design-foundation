import SwiftUI

private let sampleItems: [DFCommandPaletteItem] = [
    DFCommandPaletteItem(title: "New Document", subtitle: "Create a blank document", icon: "doc.badge.plus"),
    DFCommandPaletteItem(title: "New Folder", subtitle: "Create a folder in the current directory", icon: "folder.badge.plus"),
    DFCommandPaletteItem(title: "Open Settings", subtitle: "App preferences and account settings", icon: "gearshape"),
    DFCommandPaletteItem(title: "Search Files", subtitle: "Find files across all projects", icon: "magnifyingglass"),
    DFCommandPaletteItem(title: "Invite Teammate", subtitle: "Send an email invite", icon: "person.badge.plus"),
    DFCommandPaletteItem(title: "Toggle Dark Mode", subtitle: "Switch between light and dark appearance", icon: "moon.stars"),
    DFCommandPaletteItem(title: "Export as PDF", subtitle: "Export the current document", icon: "square.and.arrow.up"),
    DFCommandPaletteItem(title: "Sign Out", icon: "rectangle.portrait.and.arrow.right"),
]

#Preview("DFCommandPalette — Standard") {
    @Previewable @State var isPresented = true
    @Previewable @State var lastSelected: String = "None"

    VStack(spacing: 16) {
        Text("Last selected: \(lastSelected)")
        DFButton("Open Command Palette") { isPresented = true }
    }
    .padding()
    .dfCommandPalette(isPresented: $isPresented, items: sampleItems) { item in
        lastSelected = item.title
    }
}

#Preview("DFCommandPalette — Empty Items") {
    @Previewable @State var isPresented = true

    Color.clear
        .dfCommandPalette(isPresented: $isPresented, items: []) { _ in }
}
