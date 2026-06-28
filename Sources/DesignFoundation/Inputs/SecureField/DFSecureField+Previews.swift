#if DEBUG
import SwiftUI

#Preview("Outlined — States") {
    VStack(spacing: 20) {
        DFSecureField("Password", text: .constant("secret123"), placeholder: "••••••••")
        DFSecureField("Error", text: .constant(""), placeholder: "Password", validationState: .error("Too short"))
        DFSecureField("Disabled", text: .constant(""), placeholder: "Disabled")
            .disabled(true)
    }
    .padding()
    .dfSecureFieldStyle(.outlined)
}

#Preview("Filled — States") {
    VStack(spacing: 20) {
        DFSecureField("Password", text: .constant("secret123"), placeholder: "••••••••")
        DFSecureField("Valid", text: .constant("strongPass!"), placeholder: "Password", validationState: .valid)
        DFSecureField("Disabled", text: .constant(""), placeholder: "Disabled")
            .disabled(true)
    }
    .padding()
    .dfSecureFieldStyle(.filled)
}
#endif
