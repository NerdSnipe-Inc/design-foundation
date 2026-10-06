#if DEBUG
import SwiftUI

private struct DFOTPFieldInteractivePreview: View {
    @State private var code = ""
    @State private var completed = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DFOTPField("Verification code", text: $code) { completed = $0 }
            Text("Completed: \(completed)")
        }
        .padding()
    }
}

#Preview("Outlined — States") {
    VStack(alignment: .leading, spacing: 24) {
        DFOTPField("Empty", text: .constant(""))
        DFOTPField("Partial", text: .constant("123"))
        DFOTPField("Complete", text: .constant("123456"), validationState: .valid)
        DFOTPField("Error", text: .constant("123456"), validationState: .error("That code is incorrect"))
        DFOTPField("Disabled", text: .constant("12"))
            .disabled(true)
    }
    .padding()
    .dfOTPFieldStyle(.outlined)
}

#Preview("Filled — States") {
    VStack(alignment: .leading, spacing: 24) {
        DFOTPField("Partial", text: .constant("42"))
        DFOTPField("Error", text: .constant("424242"), validationState: .error("Code expired"))
        DFOTPField("Disabled", text: .constant(""))
            .disabled(true)
    }
    .padding()
    .dfOTPFieldStyle(.filled)
}

#Preview("Underlined — 4 digits") {
    VStack(alignment: .leading, spacing: 24) {
        DFOTPField("PIN", text: .constant("73"), length: 4)
        DFOTPField("PIN", text: .constant("7391"), length: 4, validationState: .error("Wrong PIN"))
    }
    .padding()
    .dfOTPFieldStyle(.underlined)
}

#Preview("Alphanumeric — 8 characters") {
    DFOTPField("Recovery code", text: .constant("AB12"), length: 8, allowedCharacters: .alphanumeric)
        .padding()
}

#Preview("Interactive") {
    DFOTPFieldInteractivePreview()
}

#if compiler(>=6.2)
#Preview("Glass") {
    if #available(iOS 26, macOS 26, visionOS 26, *) {
        VStack(alignment: .leading, spacing: 24) {
            DFOTPField("Verification code", text: .constant("123"))
            DFOTPField("Error", text: .constant("123456"), validationState: .error("That code is incorrect"))
        }
        .padding()
        .dfOTPFieldStyle(.glass)
    } else {
        Text("Liquid Glass needs iOS/macOS 26")
    }
}
#endif
#endif
