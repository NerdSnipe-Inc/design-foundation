#if DEBUG
import SwiftUI

#Preview("Outlined — States") {
    VStack(spacing: 20) {
        DFTextField("Email", text: .constant("user@example.com"), placeholder: "you@example.com")
        DFTextField("Error", text: .constant("bad"), placeholder: "", validationState: .error("Invalid email"))
        DFTextField("Valid", text: .constant("good@example.com"), placeholder: "", validationState: .valid)
        DFTextField("Disabled", text: .constant(""), placeholder: "Disabled")
            .disabled(true)
    }
    .padding()
    .dfTextFieldStyle(.outlined)
}

#Preview("Filled — States") {
    VStack(spacing: 20) {
        DFTextField("Name", text: .constant("Jane"), placeholder: "Your name")
        DFTextField("Error", text: .constant(""), placeholder: "Required", validationState: .error("Required"))
        DFTextField("Disabled", text: .constant(""), placeholder: "Disabled")
            .disabled(true)
    }
    .padding()
    .dfTextFieldStyle(.filled)
}

#Preview("With Accessories") {
    VStack(spacing: 20) {
        DFTextField(
            "Search",
            text: .constant(""),
            placeholder: "Search...",
            leading: { Image(systemName: "magnifyingglass") },
            trailing: { Image(systemName: "xmark.circle.fill") }
        )
    }
    .padding()
}
#endif
