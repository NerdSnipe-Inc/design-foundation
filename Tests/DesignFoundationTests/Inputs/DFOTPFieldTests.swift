import Testing
import SwiftUI
@testable import DesignFoundation

@Suite("DFOTPCode sanitizing")
struct DFOTPCodeSanitizingTests {
    @Test("plain digits pass through")
    func plainDigits() {
        #expect(DFOTPCode("123456").text == "123456")
    }

    @Test("empty input stays empty")
    func emptyInput() {
        let code = DFOTPCode("")
        #expect(code.text == "")
        #expect(code.isComplete == false)
    }

    @Test("paste with spaces is normalized")
    func pasteWithSpaces() {
        #expect(DFOTPCode("123 456").text == "123456")
        #expect(DFOTPCode(" 1 2 3 4 5 6 ").text == "123456")
    }

    @Test("paste with dashes is normalized")
    func pasteWithDashes() {
        #expect(DFOTPCode("123-456").text == "123456")
        #expect(DFOTPCode("12-34-56").text == "123456")
    }

    @Test("paste with surrounding text keeps only the digits")
    func pasteWithSurroundingText() {
        #expect(DFOTPCode("Your code is 482913.").text == "482913")
    }

    @Test("newlines and tabs are dropped")
    func whitespaceControls() {
        #expect(DFOTPCode("12\n34\t56\r\n").text == "123456")
    }

    @Test("non-digits are dropped in digits mode")
    func nonDigitsDropped() {
        #expect(DFOTPCode("a1b2c3").text == "123")
        #expect(DFOTPCode("abc").text == "")
        #expect(DFOTPCode("12.5").text == "125")
    }

    @Test("non-ASCII digit lookalikes are rejected")
    func nonASCIIDigits() {
        #expect(DFOTPCode("١٢٣").text == "")
        #expect(DFOTPCode("①②").text == "")
        #expect(DFOTPCode("1２3").text == "13")
    }

    @Test("overflow is clamped to length, keeping the leading characters")
    func overflowClamped() {
        #expect(DFOTPCode("12345678").text == "123456")
        #expect(DFOTPCode("123 456 789").text == "123456")
        #expect(DFOTPCode("1234567", length: 4).text == "1234")
    }

    @Test("length below 1 is raised to 1")
    func lengthFloor() {
        #expect(DFOTPCode("987", length: 0).length == 1)
        #expect(DFOTPCode("987", length: 0).text == "9")
        #expect(DFOTPCode("987", length: -3).text == "9")
    }

    @Test("letters mode keeps ASCII letters only")
    func lettersMode() {
        #expect(DFOTPCode("ab-12 Cd", length: 6, allowedCharacters: .letters).text == "abCd")
    }

    @Test("alphanumeric mode keeps ASCII letters and digits")
    func alphanumericMode() {
        #expect(DFOTPCode("ab-12 Cd_é", length: 8, allowedCharacters: .alphanumeric).text == "ab12Cd")
    }

    @Test("custom mode keeps exactly the given characters")
    func customMode() {
        let allowed: Set<Character> = ["A", "B", "7"]
        let code = DFOTPCode("AB7C8-A", length: 6, allowedCharacters: .custom(allowed))
        #expect(code.text == "AB7A")
    }

    @Test("sanitize is idempotent")
    func idempotent() {
        let once = DFOTPCode.sanitize("12 34-56 78", length: 6, allowedCharacters: .digits)
        let twice = DFOTPCode.sanitize(once, length: 6, allowedCharacters: .digits)
        #expect(once == twice)
    }

    @Test("only digits mode asks for the numeric keyboard")
    func numericKeyboardPreference() {
        #expect(DFOTPCharacterSet.digits.prefersNumericKeyboard)
        #expect(!DFOTPCharacterSet.letters.prefersNumericKeyboard)
        #expect(!DFOTPCharacterSet.alphanumeric.prefersNumericKeyboard)
        #expect(!DFOTPCharacterSet.custom(["1"]).prefersNumericKeyboard)
    }
}

@Suite("DFOTPCode cell layout")
struct DFOTPCodeCellLayoutTests {
    @Test("one cell per position")
    func cellCount() {
        #expect(DFOTPCode("12").cells(isFocused: false).count == 6)
        #expect(DFOTPCode("12", length: 4).cells(isFocused: false).count == 4)
    }

    @Test("cells carry the typed characters and are empty after them")
    func cellCharacters() {
        let cells = DFOTPCode("12", length: 4).cells(isFocused: false)
        #expect(cells.map(\.character) == ["1", "2", nil, nil])
        #expect(cells.map(\.isFilled) == [true, true, false, false])
        #expect(cells.map(\.index) == [0, 1, 2, 3])
        #expect(cells.map(\.id) == [0, 1, 2, 3])
    }

    @Test("active cell is the first empty one while focused")
    func activeCellWhileFocused() {
        let cells = DFOTPCode("12", length: 4).cells(isFocused: true)
        #expect(cells.map(\.isActive) == [false, false, true, false])
    }

    @Test("empty code activates the first cell")
    func activeCellWhenEmpty() {
        let cells = DFOTPCode("", length: 3).cells(isFocused: true)
        #expect(cells.map(\.isActive) == [true, false, false])
    }

    @Test("complete code keeps the last cell active")
    func activeCellWhenComplete() {
        let code = DFOTPCode("1234", length: 4)
        #expect(code.activeIndex == 3)
        #expect(code.cells(isFocused: true).map(\.isActive) == [false, false, false, true])
    }

    @Test("no cell is active while unfocused")
    func noActiveCellUnfocused() {
        let cells = DFOTPCode("12", length: 4).cells(isFocused: false)
        #expect(cells.allSatisfy { !$0.isActive })
    }

    @Test("isComplete and characters")
    func completeAndCharacters() {
        #expect(DFOTPCode("12345").isComplete == false)
        #expect(DFOTPCode("123456").isComplete == true)
        #expect(DFOTPCode("12-3").characters == ["1", "2", "3"])
    }

    @Test("a single-cell code works")
    func singleCell() {
        let code = DFOTPCode("5", length: 1)
        #expect(code.isComplete)
        #expect(code.activeIndex == 0)
        #expect(code.cells(isFocused: true).count == 1)
    }
}

@Suite("DFOTPCode completion")
struct DFOTPCodeCompletionTests {
    private func evaluate(_ raw: String, wasComplete: Bool, length: Int = 6) -> DFOTPCode.Evaluation {
        DFOTPCode.evaluate(raw, length: length, allowedCharacters: .digits, wasComplete: wasComplete)
    }

    @Test("reaching full length fires completion")
    func firesOnFullLength() {
        let result = evaluate("123456", wasComplete: false)
        #expect(result.didComplete)
        #expect(result.isComplete)
        #expect(result.text == "123456")
    }

    @Test("below full length never fires")
    func doesNotFireBelowLength() {
        let result = evaluate("12345", wasComplete: false)
        #expect(!result.didComplete)
        #expect(!result.isComplete)
    }

    @Test("a full-length paste fires from empty")
    func pasteFires() {
        #expect(evaluate("123-456", wasComplete: false).didComplete)
    }

    @Test("an overflowing paste fires once with the clamped code")
    func overflowFires() {
        let result = evaluate("1234567890", wasComplete: false)
        #expect(result.didComplete)
        #expect(result.text == "123456")
    }

    @Test("staying complete does not fire again")
    func doesNotRefire() {
        #expect(!evaluate("123456", wasComplete: true).didComplete)
        // Typing past the end is clamped back to the same code, still not a new completion.
        #expect(!evaluate("1234567", wasComplete: true).didComplete)
    }

    @Test("editing below length re-arms completion")
    func rearms() {
        var wasComplete = false
        var fired: [String] = []
        for input in ["1", "12", "123", "1234", "12345", "123456", "12345", "123450", "123450"] {
            let result = evaluate(input, wasComplete: wasComplete)
            wasComplete = result.isComplete
            if result.didComplete { fired.append(result.text) }
        }
        #expect(fired == ["123456", "123450"])
    }

    @Test("typing one digit at a time fires exactly once")
    func typedOnce() {
        var wasComplete = false
        var count = 0
        var text = ""
        for digit in "123456789" {
            text.append(digit)
            let result = evaluate(text, wasComplete: wasComplete)
            text = result.text
            wasComplete = result.isComplete
            if result.didComplete { count += 1 }
        }
        #expect(count == 1)
        #expect(text == "123456")
    }

    @Test("clearing the field resets completion")
    func clearResets() {
        let cleared = evaluate("", wasComplete: true)
        #expect(!cleared.isComplete)
        #expect(!cleared.didComplete)
        #expect(evaluate("123456", wasComplete: cleared.isComplete).didComplete)
    }

    @Test("a custom length completes at that length")
    func customLength() {
        #expect(evaluate("1234", wasComplete: false, length: 4).didComplete)
        #expect(!evaluate("123", wasComplete: false, length: 4).didComplete)
    }
}

@Suite("DFOTPFieldStyleConfiguration")
struct DFOTPFieldStyleConfigurationTests {
    @Test("configuration holds all values")
    func configurationHoldsValues() {
        let theme = DFTheme.default
        let cells = DFOTPCode("12", length: 4).cells(isFocused: true)
        let config = DFOTPFieldStyleConfiguration(
            label: "Code",
            fieldContent: AnyView(EmptyView()),
            cells: cells,
            isFocused: true,
            isDisabled: false,
            validationState: .error("Wrong code"),
            theme: theme
        )
        #expect(config.label == "Code")
        #expect(config.cells.count == 4)
        #expect(config.isFocused == true)
        #expect(config.isDisabled == false)
        #expect(config.validationState == .error("Wrong code"))
    }
}

@Suite("DFOTPField Environment")
struct DFOTPFieldEnvironmentTests {
    @Test("dfOTPFieldStyle environment key has a default")
    func environmentKeyHasDefault() {
        let values = EnvironmentValues()
        let _ = values.dfOTPFieldStyle
    }
}

@Suite("DFOTPField Built-in Styles")
struct DFOTPFieldBuiltinStyleTests {
    @Test("outlined OTP style instantiates")
    func outlinedInstantiates() {
        let _ = DFOutlinedOTPFieldStyle()
    }

    @Test("filled OTP style instantiates")
    func filledInstantiates() {
        let _ = DFFilledOTPFieldStyle()
    }

    @Test("underlined OTP style instantiates")
    func underlinedInstantiates() {
        let _ = DFUnderlinedOTPFieldStyle()
    }

    #if compiler(>=6.2)
    @Test("glass OTP style instantiates")
    func glassInstantiates() {
        if #available(iOS 26, macOS 26, *) {
            let _ = DFGlassOTPFieldStyle()
        }
    }
    #endif
}

@Suite("DFValidatedOTPField")
@MainActor
struct DFValidatedOTPFieldTests {
    @Test("form binding round-trips an OTP code and validates length")
    func formBinding() {
        let form = DFFormState(fields: [
            "otp": [DFRequiredValidator(), DFMinLengthValidator(minLength: 6)]
        ])
        let binding = form.binding(for: "otp")
        binding.wrappedValue = DFOTPCode("123-456").text
        #expect(form.values["otp"] == "123456")
        #expect(form.validate())

        binding.wrappedValue = DFOTPCode("123").text
        #expect(form.validate() == false)
    }
}
