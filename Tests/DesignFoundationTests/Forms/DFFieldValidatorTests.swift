import Testing
@testable import DesignFoundation

@Suite("DFRequiredValidator")
struct DFRequiredValidatorTests {
    @Test("rejects whitespace-only values")
    func rejectsWhitespace() {
        let validator = DFRequiredValidator()
        #expect(validator.validate("   ") == "This field is required")
    }

    @Test("accepts non-empty values")
    func acceptsNonEmpty() {
        let validator = DFRequiredValidator(message: "Required")
        #expect(validator.validate("hello") == nil)
    }

    @Test("uses custom message")
    func customMessage() {
        let validator = DFRequiredValidator(message: "Name is required")
        #expect(validator.validate("") == "Name is required")
    }
}

@Suite("DFEmailValidator")
struct DFEmailValidatorTests {
    @Test("accepts valid email")
    func acceptsValidEmail() {
        let validator = DFEmailValidator()
        #expect(validator.validate("user@example.com") == nil)
    }

    @Test("rejects invalid email")
    func rejectsInvalidEmail() {
        let validator = DFEmailValidator()
        #expect(validator.validate("not-an-email") == "Enter a valid email address")
    }

    @Test("skips empty values")
    func skipsEmpty() {
        let validator = DFEmailValidator()
        #expect(validator.validate("") == nil)
    }
}

@Suite("DFMinLengthValidator")
struct DFMinLengthValidatorTests {
    @Test("rejects values below minimum")
    func rejectsShortValue() {
        let validator = DFMinLengthValidator(minLength: 8)
        #expect(validator.validate("short") == "Must be at least 8 characters")
    }

    @Test("accepts values at or above minimum")
    func acceptsLongEnoughValue() {
        let validator = DFMinLengthValidator(minLength: 8, message: "Too short")
        #expect(validator.validate("longenough") == nil)
    }
}

@Suite("DFMaxLengthValidator")
struct DFMaxLengthValidatorTests {
    @Test("rejects values above maximum")
    func rejectsLongValue() {
        let validator = DFMaxLengthValidator(maxLength: 5)
        #expect(validator.validate("toolong") == "Must be at most 5 characters")
    }

    @Test("accepts values within maximum")
    func acceptsShortValue() {
        let validator = DFMaxLengthValidator(maxLength: 5, message: "Too long")
        #expect(validator.validate("short") == nil)
    }
}

@Suite("DFRegexValidator")
struct DFRegexValidatorTests {
    @Test("accepts matching values")
    func acceptsMatch() {
        let validator = DFRegexValidator(pattern: #"^\d{3}$"#, message: "Must be 3 digits")
        #expect(validator.validate("123") == nil)
    }

    @Test("rejects non-matching values")
    func rejectsNonMatch() {
        let validator = DFRegexValidator(pattern: #"^\d{3}$"#, message: "Must be 3 digits")
        #expect(validator.validate("12") == "Must be 3 digits")
    }

    @Test("skips empty values")
    func skipsEmpty() {
        let validator = DFRegexValidator(pattern: #"^\d{3}$"#, message: "Must be 3 digits")
        #expect(validator.validate("") == nil)
    }
}
