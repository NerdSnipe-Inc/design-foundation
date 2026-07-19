import SwiftUI

#if DEBUG

#Preview("Severities") {
    VStack(spacing: 12) {
        DFBanner(icon: "info.circle.fill", message: "New version available.", severity: .info)
        DFBanner(icon: "checkmark.circle.fill", message: "Changes saved.", severity: .success)
        DFBanner(icon: "exclamationmark.triangle.fill", message: "Storage almost full.", severity: .warning)
        DFBanner(icon: "xmark.octagon.fill", message: "Payment failed.", severity: .error)
    }
    .padding()
}

#Preview("With action and dismiss") {
    DFBanner(
        icon: "arrow.down.circle.fill",
        message: "A new update is ready to install.",
        severity: .info,
        actionTitle: "Update Now",
        onAction: {},
        isDismissible: true,
        onDismiss: {}
    )
    .padding()
}

#Preview("Dark mode") {
    DFBanner(icon: "info.circle.fill", message: "New version available.", severity: .info, isDismissible: true, onDismiss: {})
        .padding()
        .preferredColorScheme(.dark)
}

#endif
