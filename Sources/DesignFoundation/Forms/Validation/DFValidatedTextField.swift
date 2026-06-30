import SwiftUI

/// Binds a `DFTextField` to `DFFormState` and surfaces field errors via `DFValidationState`.
public struct DFValidatedTextField: View {
    private let label: String
    private let field: String
    private let placeholder: String
    @Bindable private var form: DFFormState

    public init(
        _ label: String,
        field: String,
        form: DFFormState,
        placeholder: String = ""
    ) {
        self.label = label
        self.field = field
        self.form = form
        self.placeholder = placeholder
    }

    public var body: some View {
        DFTextField(
            label,
            text: form.binding(for: field),
            placeholder: placeholder,
            validationState: form.validationState(for: field)
        )
    }
}
