import Foundation

// MARK: - Allowed characters

/// Which characters a `DFOTPField` accepts. Anything else (spaces, dashes, letters in a numeric code, ...)
/// is dropped, which is also how a pasted "123 456" or "123-456" becomes "123456".
public enum DFOTPCharacterSet: Sendable, Equatable {
    /// ASCII digits 0-9 (default). The field asks for the numeric keyboard on iOS.
    case digits
    /// ASCII letters A-Z / a-z.
    case letters
    /// ASCII letters and digits.
    case alphanumeric
    /// Exactly the given characters.
    case custom(Set<Character>)

    /// Whether `character` is accepted.
    public func contains(_ character: Character) -> Bool {
        switch self {
        case .digits:
            return character.isASCII && character.isWholeNumber
        case .letters:
            return character.isASCII && character.isLetter
        case .alphanumeric:
            return character.isASCII && (character.isLetter || character.isWholeNumber)
        case .custom(let allowed):
            return allowed.contains(character)
        }
    }

    /// `true` when the numeric keyboard fits (only `.digits`).
    public var prefersNumericKeyboard: Bool {
        if case .digits = self { return true }
        return false
    }
}

// MARK: - Code

/// Pure input-sanitizing and cell-layout logic behind `DFOTPField`. No SwiftUI, no state: given the raw text of the
/// hidden input it says what the code is, which cell is active and when the code has just been completed.
public struct DFOTPCode: Sendable, Equatable {
    /// One visual cell of the field.
    public struct Cell: Sendable, Equatable, Identifiable {
        public let index: Int
        /// The character shown in this cell, `nil` while empty.
        public let character: Character?
        /// `true` for the cell that receives the next character (only while the field is focused).
        public let isActive: Bool

        public var id: Int { index }
        public var isFilled: Bool { character != nil }
    }

    /// Result of feeding raw input through `DFOTPCode.evaluate`.
    public struct Evaluation: Sendable, Equatable {
        /// The sanitized, clamped text. Write it back to the binding when it differs from the raw input.
        public let text: String
        /// `true` when `text` has the full length.
        public let isComplete: Bool
        /// `true` only on the edit that reaches full length from below it. Fire `onComplete` exactly when this is set.
        public let didComplete: Bool
    }

    /// Number of cells (always at least 1).
    public let length: Int
    public let allowedCharacters: DFOTPCharacterSet
    /// The sanitized code, at most `length` characters.
    public let text: String

    /// Sanitizes `raw` immediately; `length` below 1 is raised to 1.
    public init(_ raw: String = "", length: Int = 6, allowedCharacters: DFOTPCharacterSet = .digits) {
        let clamped = max(1, length)
        self.length = clamped
        self.allowedCharacters = allowedCharacters
        self.text = DFOTPCode.sanitize(raw, length: clamped, allowedCharacters: allowedCharacters)
    }

    /// Drops disallowed characters, then keeps the first `length` of what is left.
    public static func sanitize(_ raw: String, length: Int, allowedCharacters: DFOTPCharacterSet = .digits) -> String {
        let limit = max(1, length)
        var result = ""
        var count = 0
        for character in raw where allowedCharacters.contains(character) {
            result.append(character)
            count += 1
            if count == limit { break }
        }
        return result
    }

    /// Sanitizes `raw` and decides whether this edit completed the code.
    ///
    /// `wasComplete` is whether the previous evaluation was complete. Completion fires once on the way up and
    /// re-arms as soon as the text drops below `length` again.
    public static func evaluate(
        _ raw: String,
        length: Int,
        allowedCharacters: DFOTPCharacterSet = .digits,
        wasComplete: Bool
    ) -> Evaluation {
        let clamped = max(1, length)
        let text = sanitize(raw, length: clamped, allowedCharacters: allowedCharacters)
        let isComplete = text.count == clamped
        return Evaluation(text: text, isComplete: isComplete, didComplete: isComplete && !wasComplete)
    }

    /// The code as individual characters.
    public var characters: [Character] { Array(text) }

    /// `true` when every cell is filled.
    public var isComplete: Bool { text.count == length }

    /// Index of the cell that takes the next character. Stays on the last cell once the code is complete.
    public var activeIndex: Int { min(text.count, length - 1) }

    /// One `Cell` per position. `isActive` is only set when `isFocused` is true.
    public func cells(isFocused: Bool) -> [Cell] {
        let typed = characters
        let active = activeIndex
        return (0..<length).map { index in
            Cell(
                index: index,
                character: index < typed.count ? typed[index] : nil,
                isActive: isFocused && index == active
            )
        }
    }
}
