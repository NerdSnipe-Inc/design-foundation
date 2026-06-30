import Observation
import SwiftUI

/// Observable form state for keyed text fields with validator rules, errors, and touched tracking.
@Observable
@MainActor
public final class DFFormState {
    public private(set) var values: [String: String]
    public private(set) var errors: [String: String]
    public private(set) var touched: Set<String>
    public private(set) var hasAttemptedSubmit: Bool

    private var validators: [String: [any DFFieldValidator]]

    public init(
        fields: [String: [any DFFieldValidator]] = [:],
        initialValues: [String: String] = [:]
    ) {
        self.validators = fields
        self.values = initialValues
        self.errors = [:]
        self.touched = []
        self.hasAttemptedSubmit = false

        for field in fields.keys where values[field] == nil {
            values[field] = ""
        }
    }

    public func register(
        field: String,
        validators: [any DFFieldValidator],
        initialValue: String = ""
    ) {
        self.validators[field] = validators
        if values[field] == nil {
            values[field] = initialValue
        }
    }

    public func setValue(_ value: String, for field: String, markAsTouched: Bool = true) {
        values[field] = value
        if markAsTouched {
            touched.insert(field)
            _ = validate(field: field, markAsTouched: false)
        }
    }

    public func markTouched(_ field: String) {
        touched.insert(field)
        _ = validate(field: field, markAsTouched: false)
    }

    public func binding(for field: String) -> Binding<String> {
        Binding(
            get: { self.values[field, default: ""] },
            set: { self.setValue($0, for: field) }
        )
    }

    public func validationState(for field: String) -> DFValidationState {
        guard let error = errors[field] else {
            if touched.contains(field),
               !(validators[field]?.isEmpty ?? true),
               !(values[field, default: ""].isEmpty) {
                return .valid
            }
            return .none
        }

        if touched.contains(field) || hasAttemptedSubmit {
            return .error(error)
        }
        return .none
    }

    @discardableResult
    public func validate(field: String, markAsTouched: Bool = true) -> Bool {
        if markAsTouched {
            touched.insert(field)
        }

        let value = values[field, default: ""]
        for validator in validators[field] ?? [] {
            if let message = validator.validate(value) {
                errors[field] = message
                return false
            }
        }
        errors.removeValue(forKey: field)
        return true
    }

    @discardableResult
    public func validate() -> Bool {
        hasAttemptedSubmit = true
        var isValid = true
        for field in validators.keys {
            if !validate(field: field) {
                isValid = false
            }
        }
        return isValid
    }

    public var isValid: Bool {
        validators.keys.allSatisfy { field in
            let value = values[field, default: ""]
            return (validators[field] ?? []).allSatisfy { $0.validate(value) == nil }
        }
    }
}
