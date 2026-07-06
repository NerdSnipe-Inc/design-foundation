import SwiftUI

#if DEBUG

#Preview("Icon + Title") {
    DFEmptyState(
        icon: "tray",
        title: "No items yet"
    )
    .padding()
}

#Preview("Icon + Title + Message") {
    DFEmptyState(
        icon: "magnifyingglass",
        title: "No results found",
        message: "Try adjusting your search or filters to find what you're looking for."
    )
    .padding()
}

#Preview("Icon + Title + Message + Action") {
    DFEmptyState(
        icon: "folder.badge.plus",
        title: "No projects",
        message: "Get started by creating your first project.",
        actionTitle: "Create Project",
        onAction: {}
    )
    .padding()
}

#endif
