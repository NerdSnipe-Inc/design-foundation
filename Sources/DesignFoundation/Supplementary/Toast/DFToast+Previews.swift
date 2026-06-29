#if DEBUG
import SwiftUI

#Preview("DFToast — Severities") {
    let theme = DFTheme.default
    let style = DFDefaultToastStyle()

    VStack(spacing: 16) {
        ForEach([
            DFToastMessage(text: "Your changes have been saved.", icon: "info.circle.fill", severity: .info),
            DFToastMessage(text: "Upload complete.", icon: "checkmark.circle.fill", severity: .success),
            DFToastMessage(text: "Connection unstable.", icon: "wifi.exclamationmark", severity: .warning),
            DFToastMessage(text: "Upload failed — please retry.", icon: "xmark.circle.fill", severity: .error),
        ], id: \.id) { message in
            style.makeBody(configuration: DFToastStyleConfiguration(message: message, theme: theme))
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(theme.colors.background)
    .dfTheme(theme)
}

#Preview("DFToast — Queue") {
    @Previewable @StateObject var queue = DFToastQueue()

    VStack(spacing: 12) {
        DFButton("Info") { queue.show(text: "Your changes have been saved.", icon: "info.circle.fill", severity: .info) }
        DFButton("Success") { queue.show(text: "Upload complete.", icon: "checkmark.circle.fill", severity: .success) }
        DFButton("Warning") { queue.show(text: "Connection unstable.", icon: "wifi.exclamationmark", severity: .warning) }
        DFButton("Error") { queue.show(text: "Upload failed — please retry.", icon: "xmark.circle.fill", severity: .error) }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .dfToast(queue: queue)
    .dfTheme(.default)
}
#endif
