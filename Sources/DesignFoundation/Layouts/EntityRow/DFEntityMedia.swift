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
    /// A manually-drawn disclosure chevron. Don't use this when the row is a `NavigationLink`'s
    /// label inside a `List` on iOS — the system already draws its own disclosure chevron there,
    /// so this would duplicate it. Pass `nil` (or `.text`/`.badge`) in that case instead, and
    /// reserve `.chevron` for rows that signal tappability on their own (e.g. via `onTap`, outside
    /// a `List`/`NavigationLink`).
    case chevron
}
