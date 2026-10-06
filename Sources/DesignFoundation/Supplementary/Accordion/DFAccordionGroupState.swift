import Foundation

/// Pure value type that owns the open/closed bookkeeping for a `DFAccordionGroup`.
///
/// Kept free of SwiftUI so the exclusive-open and multi-open rules can be unit tested directly.
/// In exclusive mode (`allowsMultipleExpanded == false`, the default) at most one id is ever
/// expanded; expanding another id collapses the previous one. In multi mode any number of ids may
/// be expanded at once.
public struct DFAccordionGroupState: Sendable, Equatable {
    public let allowsMultipleExpanded: Bool
    public private(set) var expandedIDs: Set<String>

    /// In exclusive mode an `expandedIDs` seed with more than one id is trimmed to a single id
    /// (the lexicographically smallest, so the result is deterministic).
    public init(allowsMultipleExpanded: Bool = false, expandedIDs: Set<String> = []) {
        self.allowsMultipleExpanded = allowsMultipleExpanded
        if allowsMultipleExpanded {
            self.expandedIDs = expandedIDs
        } else if let first = expandedIDs.min() {
            self.expandedIDs = [first]
        } else {
            self.expandedIDs = []
        }
    }

    public func isExpanded(_ id: String) -> Bool {
        expandedIDs.contains(id)
    }

    public mutating func toggle(_ id: String) {
        setExpanded(!isExpanded(id), for: id)
    }

    public mutating func expand(_ id: String) {
        setExpanded(true, for: id)
    }

    public mutating func collapse(_ id: String) {
        setExpanded(false, for: id)
    }

    public mutating func collapseAll() {
        expandedIDs.removeAll()
    }

    public mutating func setExpanded(_ expanded: Bool, for id: String) {
        if expanded {
            if !allowsMultipleExpanded {
                expandedIDs.removeAll()
            }
            expandedIDs.insert(id)
        } else {
            expandedIDs.remove(id)
        }
    }
}
