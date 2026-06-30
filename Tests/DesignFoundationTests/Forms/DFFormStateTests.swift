import SwiftUI
import Testing
@testable import DesignFoundation

@Suite("DFFormState")
@MainActor
struct DFFormStateTests {
    @Test("stores initial values and validates required field")
    func requiredFieldValidation() {
        let form = DFFormState(fields: [
            "email": [DFRequiredValidator(), DFEmailValidator()]
        ], initialValues: ["email": ""])

        #expect(form.values["email"] == "")
        #expect(form.isValid == false)

        form.setValue("user@example.com", for: "email")
        #expect(form.isValid == true)
        #expect(form.errors["email"] == nil)
        #expect(form.touched.contains("email"))
    }

    @Test("validate(field:) records error for invalid value")
    func validateFieldRecordsError() {
        let form = DFFormState(fields: [
            "email": [DFEmailValidator(message: "Invalid email")]
        ])

        form.setValue("bad", for: "email", markAsTouched: false)
        #expect(form.validate(field: "email") == false)
        #expect(form.errors["email"] == "Invalid email")
        #expect(form.validationState(for: "email") == .error("Invalid email"))
    }

    @Test("validate() marks submit attempt and validates all fields")
    func validateAllFields() {
        let form = DFFormState(fields: [
            "name": [DFRequiredValidator()],
            "email": [DFRequiredValidator(), DFEmailValidator()]
        ])

        #expect(form.validate() == false)
        #expect(form.hasAttemptedSubmit == true)
        #expect(form.errors["name"] == "This field is required")
        #expect(form.errors["email"] == "This field is required")

        form.setValue("Ada Lovelace", for: "name")
        form.setValue("ada@example.com", for: "email")
        #expect(form.validate() == true)
        #expect(form.errors.isEmpty)
    }

    @Test("validation state stays hidden until touched or submit")
    func hiddenUntilTouchedOrSubmit() {
        let form = DFFormState(fields: [
            "name": [DFRequiredValidator()]
        ])

        form.setValue("", for: "name", markAsTouched: false)
        _ = form.validate(field: "name", markAsTouched: false)

        #expect(form.validationState(for: "name") == .none)

        form.markTouched("name")
        #expect(form.validationState(for: "name") == .error("This field is required"))
    }

    @Test("binding updates value and touched state")
    func bindingUpdatesValue() {
        let form = DFFormState(fields: [
            "username": [DFMinLengthValidator(minLength: 3)]
        ])

        form.binding(for: "username").wrappedValue = "ab"
        #expect(form.values["username"] == "ab")
        #expect(form.touched.contains("username"))
        #expect(form.validationState(for: "username") == .error("Must be at least 3 characters"))

        form.binding(for: "username").wrappedValue = "abc"
        #expect(form.validationState(for: "username") == .valid)
    }

    @Test("register adds field validators after init")
    func registerField() {
        let form = DFFormState()
        form.register(field: "code", validators: [DFRegexValidator(pattern: #"^\d{4}$"#, message: "4 digits")])

        form.setValue("12", for: "code")
        #expect(form.validationState(for: "code") == .error("4 digits"))
    }
}

@Suite("DFValidatedTextField")
@MainActor
struct DFValidatedTextFieldTests {
    @Test("type is a View")
    func isView() {
        let _: any View = DFValidatedTextField("Email", field: "email", form: DFFormState())
    }
}
