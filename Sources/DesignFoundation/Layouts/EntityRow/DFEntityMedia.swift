import SwiftUI

/// Structured leading-media options shared by `DFEntityRow` and `DFEntityCard`.
/// Deliberately a fixed set (not an arbitrary `@ViewBuilder` slot, unlike `DFListRow`'s
/// leading/trailing closures) — see CLAUDE.md's "DFEntityRow vs DFListRow" note.
public enum DFEntityMedia: Sendable {
    case systemImage(String)
    case avatarInitials(String)
}

/// Structured trailing-content options shared by `DFEntityRow` and `DFEntityCard`.
public enum DFEntityTrailing: Sendable {
    case text(String)
    case badge(String)
    case chevron
}
