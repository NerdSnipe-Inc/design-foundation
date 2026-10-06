import SwiftUI

// MARK: - State

/// Where a step (or timeline item) sits relative to the current position.
///
/// Every state has a distinct shape as well as a distinct color (checkmark, ringed marker, outline,
/// exclamation mark), so progress never depends on color alone.
public enum DFStepState: Sendable, Equatable, CaseIterable {
    case complete
    case current
    case upcoming
    case error

    /// The state as VoiceOver reads it, e.g. "current".
    public var accessibilityValue: String {
        switch self {
        case .complete: return "complete"
        case .current: return "current"
        case .upcoming: return "upcoming"
        case .error: return "error"
        }
    }

    /// Pure state resolution: maps a current position onto one state per step.
    ///
    /// - `count` of zero or less yields an empty array.
    /// - `currentIndex` is clamped to `0...count`. A negative index behaves like `0` (first step current);
    ///   an index at or beyond `count` marks every step `.complete`, which is how a finished flow reads.
    /// - Indices in `errorIndices` resolve to `.error` regardless of position; out-of-range entries are ignored.
    public static func resolve(count: Int, currentIndex: Int, errorIndices: Set<Int> = []) -> [DFStepState] {
        guard count > 0 else { return [] }
        let clamped = min(max(currentIndex, 0), count)
        return (0..<count).map { index -> DFStepState in
            if errorIndices.contains(index) { return .error }
            if index < clamped { return .complete }
            if index == clamped { return .current }
            return .upcoming
        }
    }

    /// Resolves states for `steps`, treating each step with `hasError == true` as `.error`.
    public static func resolve(steps: [DFStep], currentIndex: Int) -> [DFStepState] {
        var errors = Set<Int>()
        for (index, step) in steps.enumerated() where step.hasError {
            errors.insert(index)
        }
        return resolve(count: steps.count, currentIndex: currentIndex, errorIndices: errors)
    }
}

// MARK: - Step

/// One step of a `DFStepIndicator`. Value-driven: no arbitrary views.
public struct DFStep: Sendable, Identifiable, Equatable {
    public let id: String
    public var title: String
    /// Shown by vertical layouts; horizontal layouts show the title only.
    public var subtitle: String?
    /// SF Symbol shown in the marker while the step is current or upcoming.
    public var systemImage: String?
    /// Forces `.error` regardless of `currentIndex`.
    public var hasError: Bool

    /// - Parameter id: Stable identity; defaults to `title`.
    public init(
        id: String? = nil,
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        hasError: Bool = false
    ) {
        self.id = id ?? title
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.hasError = hasError
    }

    /// The VoiceOver label for a step, e.g. "Step 2 of 4, Shipping". Pair it with
    /// `DFStepState.accessibilityValue` for "Step 2 of 4, Shipping, current".
    public static func accessibilityLabel(position: Int, of total: Int, title: String) -> String {
        "Step \(position) of \(total), \(title)"
    }
}
