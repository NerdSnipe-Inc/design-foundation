import SwiftUI

#Preview("DFAlert — Variants") {
    @Previewable @State var showBasic = false
    @Previewable @State var showDestructive = false

    VStack(spacing: 16) {
        Button("Show basic alert") { showBasic = true }
        Button("Show destructive alert") { showDestructive = true }
    }
    .padding()
    .dfAlert(
        isPresented: $showBasic,
        title: "Save Changes?",
        message: "Your changes will be saved.",
        actions: [
            DFAlertAction(title: "Save"),
            DFAlertAction(title: "Cancel", role: .cancel),
        ]
    )
    .dfAlert(
        isPresented: $showDestructive,
        title: "Delete Item",
        message: "This action cannot be undone.",
        actions: [
            DFAlertAction(title: "Delete", role: .destructive),
            DFAlertAction(title: "Cancel", role: .cancel),
        ]
    )
}
