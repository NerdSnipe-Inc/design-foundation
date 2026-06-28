/// Validation state for input components (DFTextField, DFSecureField).
public enum DFValidationState: Sendable {
    case none
    case error(String)
    case valid
}
