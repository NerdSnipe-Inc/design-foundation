import SwiftUI

/// Binds a `DFOTPField` to `DFFormState` and surfaces field errors via `DFValidationState`.
public struct DFValidatedOTPField: View {
    private let label: String
    private let field: String
    private let length: Int
    private let allowedCharacters: DFOTPCharacterSet
    private let onComplete: ((String) -> Void)?
    @Bindable private var form: DFFormState

    public init(
        _ label: String,
        field: String,
        form: DFFormState,
        length: Int = 6,
        allowedCharacters: DFOTPCharacterSet = .digits,
        onComplete: ((String) -> Void)? = nil
    ) {
        self.label = label
        self.field = field
        self.form = form
        self.length = length
        self.allowedCharacters = allowedCharacters
        self.onComplete = onComplete
    }

    public var body: some View {
        DFOTPField(
            label,
            text: form.binding(for: field),
            length: length,
            validationState: form.validationState(for: field),
            allowedCharacters: allowedCharacters,
            onComplete: onComplete
        )
    }
}
