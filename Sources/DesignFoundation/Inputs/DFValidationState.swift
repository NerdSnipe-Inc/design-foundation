/// Validation state for input components (DFTextField, DFSecureField).
public enum DFValidationState: Sendable, Equatable {
    case none
    case error(String)
    case valid
}
