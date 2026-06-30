import Foundation

/// Validates a single field value. Return `nil` when valid, or an error message when invalid.
public protocol DFFieldValidator: Sendable {
    func validate(_ value: String) -> String?
}

// MARK: - Required

public struct DFRequiredValidator: DFFieldValidator, Sendable {
    public let message: String

    public init(message: String = "This field is required") {
        self.message = message
    }

    public func validate(_ value: String) -> String? {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? message : nil
    }
}

// MARK: - Email

public struct DFEmailValidator: DFFieldValidator, Sendable {
    public let message: String

    private static let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

    public init(message: String = "Enter a valid email address") {
        self.message = message
    }

    public func validate(_ value: String) -> String? {
        guard !value.isEmpty else { return nil }
        return DFRegexValidator(pattern: Self.pattern, message: message).validate(value)
    }
}

// MARK: - Min Length

public struct DFMinLengthValidator: DFFieldValidator, Sendable {
    public let minLength: Int
    public let message: String

    public init(minLength: Int, message: String? = nil) {
        self.minLength = minLength
        self.message = message ?? "Must be at least \(minLength) characters"
    }

    public func validate(_ value: String) -> String? {
        value.count >= minLength ? nil : message
    }
}

// MARK: - Max Length

public struct DFMaxLengthValidator: DFFieldValidator, Sendable {
    public let maxLength: Int
    public let message: String

    public init(maxLength: Int, message: String? = nil) {
        self.maxLength = maxLength
        self.message = message ?? "Must be at most \(maxLength) characters"
    }

    public func validate(_ value: String) -> String? {
        value.count <= maxLength ? nil : message
    }
}

// MARK: - Regex

public struct DFRegexValidator: DFFieldValidator, Sendable {
    public let pattern: String
    public let message: String
    public let options: NSRegularExpression.Options

    public init(
        pattern: String,
        message: String,
        options: NSRegularExpression.Options = []
    ) {
        self.pattern = pattern
        self.message = message
        self.options = options
    }

    public func validate(_ value: String) -> String? {
        guard !value.isEmpty else { return nil }
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return message
        }
        let range = NSRange(value.startIndex..., in: value)
        return regex.firstMatch(in: value, range: range) != nil ? nil : message
    }
}
