# Text and Typography

`DFText` is the primary text rendering component in DesignFoundation. It replaces ad-hoc SwiftUI `Text` + `.font()` + `.foregroundColor()` chains with a single call that automatically adapts to the active theme, respects Dynamic Type scaling, and applies consistent line spacing and tracking across every screen in your app.

**See also:** [[Display-Primitives]] for the component overview · [[Theming]] for the full color and spacing token reference.

---

## Contents

1. [Why DFText](#why-dftext)
2. [Initializer and Style Cases](#initializer-and-style-cases)
3. [Color Modifiers — dfTextStyle](#color-modifiers--dftextstyle)
4. [DFTypographyTokens — Accessing Raw Tokens](#dftypographytokens--accessing-raw-tokens)
5. [Dynamic Type](#dynamic-type)
6. [Multi-Line and Truncation](#multi-line-and-truncation)
7. [Container Cascade](#container-cascade)
8. [Per-Preset Typography Differences](#per-preset-typography-differences)
9. [Accessibility](#accessibility)
10. [Examples](#examples)

---

## Why DFText

A hand-rolled SwiftUI `Text` view needs at minimum:

```swift
// Custom — before DesignFoundation
Text("Section Title")
    .font(.title2)
    .fontWeight(.semibold)
    .foregroundColor(Color(.label))
    .lineSpacing(4)
    .tracking(0.1)
```

That pattern breaks in three ways as your app grows:

- **Theme changes don't propagate.** Hard-coded `.foregroundColor` values do not respond when the user switches from the Default preset to Slate or Copper.
- **Spacing and tracking drift.** Every developer picks slightly different values, and the visual system fragments.
- **No single source of truth.** Updating the body typeface means hunting every `Text` view in the codebase.

`DFText` solves all three:

```swift
// DesignFoundation
DFText("Section Title", style: .title)
```

Under the hood `DFText` reads `DFTypographyTokens` from the injected theme environment. When the theme changes — or when the user adjusts their preferred text size — every `DFText` on screen updates automatically without a single line of app code.

---

## Initializer and Style Cases

```swift
public init(_ content: String, style: DFTextStyle = .body)
```

`style` defaults to `.body`, so the most common case is zero-configuration:

```swift
DFText("Hello, world")                     // .body, theme textPrimary color
DFText("Section Header", style: .headline)
DFText("12,480", style: .display)
DFText("Updated 3 min ago", style: .caption)
```

### Style Reference Table

| Style | SwiftUI Font Base | Weight | Line Spacing | Tracking | Typical Use |
|-------|------------------|--------|-------------|---------|-------------|
| `.display` | `.largeTitle` | Bold | 6 pt | −0.5 | Hero numbers, splash headlines |
| `.title` | `.title2` | Semibold | 4 pt | −0.2 | Screen titles, card headers |
| `.headline` | `.headline` | Semibold | 3 pt | 0.1 | Section headers, list group names |
| `.body` | `.body` | Regular | 4 pt | 0.0 | Paragraph text, descriptions *(default)* |
| `.label` | `.subheadline` | Medium | 2 pt | 0.1 | Row labels, field labels, nav items |
| `.caption` | `.caption` | Regular | 2 pt | 0.3 | Timestamps, helper text, metadata |

> Line spacing and tracking values are theme-token defaults and vary slightly per preset — see [Per-Preset Typography Differences](#per-preset-typography-differences).

---

## Color Modifiers — dfTextStyle

After choosing a size/weight style, you can independently control foreground color using `.dfTextStyle(_:)`:

```swift
DFText("Published", style: .label)
    .dfTextStyle(.primary)    // theme.colors.textPrimary — full emphasis

DFText("3 hours ago", style: .caption)
    .dfTextStyle(.secondary)  // theme.colors.textSecondary — muted

DFText("Custom", style: .body)
    .dfTextStyle(.default)    // no forced color; inherits environment foreground
```

### Visual Description

| Modifier | Color Token | Intended Role |
|----------|------------|---------------|
| `.primary` | `theme.colors.textPrimary` | Headlines, row labels, body copy requiring full contrast |
| `.secondary` | `theme.colors.textSecondary` | Supporting info, timestamps, helper text, subtitles |
| `.default` | *(inherited)* | Let the surrounding environment or a custom `.foregroundStyle()` take effect |

### Cascade Behavior

`.dfTextStyle` is a view modifier, not a property of `DFText` itself, so it composes cleanly with other modifiers:

```swift
DFText("Warning: action is irreversible", style: .body)
    .dfTextStyle(.primary)
    .foregroundStyle(theme.colors.error)   // overrides primary after the fact
```

When no `.dfTextStyle` modifier is applied, `DFText` defaults to `.primary` — full `textPrimary` foreground — so it is always legible without extra configuration.

---

## DFTypographyTokens — Accessing Raw Tokens

Every `DFTextStyle` case is backed by a `DFTextStyle` value struct that exposes its three parameters:

```swift
public struct DFTextStyle: Sendable {
    public let font:        Font
    public let lineSpacing: CGFloat
    public let tracking:    CGFloat
}
```

Access the tokens from `theme.typography` in any view that holds a theme environment reference:

```swift
@Environment(\.dfTheme) private var theme

// Inspect headline tokens
let headlineFont    = theme.typography.headline.font
let headlineLeading = theme.typography.headline.lineSpacing
let headlineKern    = theme.typography.headline.tracking

// Apply tokens to a raw SwiftUI Text if you need markdown or attributed string support
Text("**Bold** and _italic_ supported")
    .font(theme.typography.body.font)
    .lineSpacing(theme.typography.body.lineSpacing)
    .tracking(theme.typography.body.tracking)
    .foregroundStyle(theme.colors.textPrimary)
```

Prefer `DFText` whenever the content is a plain `String`. Drop to raw tokens only when you need SwiftUI `Text` markdown interpolation, `AttributedString`, or advanced text concatenation via `+`.

---

## Dynamic Type

`DFText` uses SwiftUI's scalable font system — the same underlying mechanism as `Font.body`, `Font.title`, and so on. All six style cases scale proportionally with the user's chosen text size in System Preferences / Accessibility Settings.

You do not need to opt in or configure anything. Scaling is on by default.

### Implications for layout

- Avoid fixed heights on containers that hold `DFText`. Prefer `.frame(minHeight:)` or let the container expand naturally.
- When a `DFText` sits inside a `DFCard` or a `DFListRow`, those components also account for Dynamic Type scaling internally.
- If you are composing a custom layout alongside `DFText`, test with the "Accessibility" text size category (xxxxxLarge) to catch truncation early.

```swift
// Good — expands as text scales
DFCard {
    DFText(description, style: .body)
        .fixedSize(horizontal: false, vertical: true)
}

// Fragile — clips large text sizes
DFCard {
    DFText(description, style: .body)
        .frame(height: 44)
}
```

---

## Multi-Line and Truncation

`DFText` wraps across multiple lines by default — identical to SwiftUI `Text`. All standard modifiers apply:

```swift
// Unlimited lines (default)
DFText(longDescription, style: .body)

// Hard cap
DFText(longDescription, style: .body)
    .lineLimit(3)

// Truncate from the middle (useful for file paths, URLs)
DFText("/Users/jamie/Documents/Project Final v3 (copy).sketch", style: .label)
    .lineLimit(1)
    .truncationMode(.middle)

// Reserve space so the layout does not jump when content loads
DFText(asyncTitle ?? "", style: .headline)
    .lineLimit(2)
    .fixedSize(horizontal: false, vertical: true)
    .redacted(reason: asyncTitle == nil ? .placeholder : [])
```

> `DFSkeleton` is the preferred loading placeholder for text that has not yet arrived — it provides the animated shimmer. Use `.redacted(reason:)` only when you need the actual layout geometry before content is available.

---

## Container Cascade

`.dfTextStyle` applied to a container propagates to all `DFText` descendants that do not have their own explicit `.dfTextStyle` modifier. This mirrors how SwiftUI's `.foregroundStyle` cascades.

```swift
// All DFText children inherit .secondary unless overridden
VStack(alignment: .leading, spacing: theme.spacing.xs) {
    DFText("Account", style: .headline)
        .dfTextStyle(.primary)   // explicit override — stays primary
    DFText("Manage your profile and billing", style: .body)
    DFText("Last updated: today", style: .caption)
}
.dfTextStyle(.secondary)        // default for all children in this VStack
```

This pattern is useful for building muted detail panels where most content should read as secondary, with only the heading promoted to primary.

---

## Per-Preset Typography Differences

While all presets share the same six style cases and the same SwiftUI font bases, the `DFTypographyTokens` values inside each token are tuned to match the preset's personality:

### Default

Balanced tracking and line spacing — the neutral reference point.

| Style | Tracking | Line Spacing |
|-------|---------|-------------|
| `.display` | −0.5 | 6 pt |
| `.body` | 0.0 | 4 pt |
| `.caption` | 0.3 | 2 pt |

### Slate

Near-identical to Default. Slightly tighter tracking on `.display` and `.title` to reinforce the refined, professional feel.

### Copper

The most compact preset. Tighter tracking throughout — `.display` tracks at −0.8, `.body` at −0.1 — giving dense layouts a crisp, editorial quality without losing legibility.

### Aurora

Slightly larger display scale with increased line spacing on `.body` (+1 pt) and `.headline` (+0.5 pt), giving the airy, open feel that matches the Aurora color palette.

### Sage

Organic and relaxed. The most generous line spacing preset — `.body` sits at 5 pt, `.caption` at 3 pt — reinforcing the calm, natural aesthetic.

### When this matters

In the vast majority of cases these differences are invisible and you should not write code that branches on the active preset. The tokens exist so that switching from Default to Copper "just feels right" without you doing anything. The one case where it matters is if you are manually applying `theme.typography.*` tokens to a custom view — the values will shift with the preset, which is correct and expected behavior.

---

## Accessibility

### Scalable fonts

All `DFText` styles scale automatically — no action needed. No `.fixedSize` override or explicit `Font.custom` size should be used with `DFText`.

### accessibilityLabel

When the visible text differs from what VoiceOver should read — a metric display showing "12.4k" that should be announced as "twelve point four thousand" — use `.accessibilityLabel`:

```swift
DFText("12.4k", style: .display)
    .accessibilityLabel("12,400 followers")
```

### accessibilityHidden

Decorative or redundant text should be hidden from the accessibility tree:

```swift
DFText("—", style: .caption)
    .accessibilityHidden(true)
```

### Contrast

`theme.colors.textPrimary` and `theme.colors.textSecondary` are designed to meet WCAG AA contrast minimums against their respective background tokens across all five presets. If you override foreground color using `.foregroundStyle()`, you are responsible for verifying contrast ratios.

---

## Examples

### 1. Article Layout

Display title, byline caption, and body copy — the most common reading pattern.

```swift
import DesignFoundation

struct ArticleView: View {
    let article: Article

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                DFText(article.title, style: .display)
                    .dfTextStyle(.primary)

                HStack {
                    DFAvatar(name: article.authorName, size: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        DFText(article.authorName, style: .label)
                            .dfTextStyle(.primary)
                        DFText(article.publishedAt, style: .caption)
                            .dfTextStyle(.secondary)
                    }
                }

                DFDivider()

                DFText(article.body, style: .body)
                    .dfTextStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(theme.spacing.lg)
        }
    }

    @Environment(\.dfTheme) private var theme
}
```

---

### 2. Dashboard Metric

Large number, semantic label, and supporting caption — common in stats cards and KPI grids.

```swift
struct MetricCard: View {
    let value: String
    let label: String
    let delta: String

    var body: some View {
        DFCard {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                DFText(value, style: .display)
                    .dfTextStyle(.primary)
                DFText(label, style: .label)
                    .dfTextStyle(.primary)
                DFText(delta, style: .caption)
                    .dfTextStyle(.secondary)
            }
        }
    }

    @Environment(\.dfTheme) private var theme
}

// Usage
MetricCard(value: "48,201", label: "Monthly Active Users", delta: "+12% vs last month")
```

---

### 3. Profile Bio

Name headline, handle caption, and multi-line bio body.

```swift
struct ProfileHeader: View {
    let profile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFAvatar(url: profile.avatarURL, size: 64)

            DFText(profile.displayName, style: .headline)
                .dfTextStyle(.primary)

            DFText("@\(profile.handle)", style: .caption)
                .dfTextStyle(.secondary)

            if !profile.bio.isEmpty {
                DFText(profile.bio, style: .body)
                    .dfTextStyle(.primary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @Environment(\.dfTheme) private var theme
}
```

---

### 4. Notification Row

Label for the notification title, caption for the timestamp — set via container cascade.

```swift
struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            DFIcon(notification.iconName, size: .md, color: theme.colors.primary)

            VStack(alignment: .leading, spacing: 2) {
                DFText(notification.title, style: .label)
                    .dfTextStyle(.primary)
                DFText(notification.relativeTimestamp, style: .caption)
                    .dfTextStyle(.secondary)
            }

            Spacer()

            if notification.isUnread {
                DFBadge(text: "New")
            }
        }
        .padding(.vertical, theme.spacing.xs)
    }

    @Environment(\.dfTheme) private var theme
}
```

---

### 5. Settings Row

Label name on the left, secondary caption value on the right.

```swift
struct SettingsValueRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            DFText(label, style: .label)
                .dfTextStyle(.primary)
            Spacer()
            DFText(value, style: .label)
                .dfTextStyle(.secondary)
        }
        .padding(.vertical, theme.spacing.xs)
    }

    @Environment(\.dfTheme) private var theme
}

// Usage
SettingsValueRow(label: "Region", value: "United States")
SettingsValueRow(label: "Language", value: "English")
```

---

### 6. Breadcrumb Navigation

A horizontal path of labels separated by chevrons. `.secondary` is applied via cascade on the outer `HStack`, and the active segment overrides to `.primary`.

```swift
struct BreadcrumbBar: View {
    let segments: [String]

    var body: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                if index > 0 {
                    DFIcon("chevron.right", size: .sm, color: theme.colors.textSecondary)
                }
                DFText(segment, style: .caption)
                    .dfTextStyle(index == segments.count - 1 ? .primary : .default)
                    .foregroundStyle(
                        index == segments.count - 1
                            ? theme.colors.textPrimary
                            : theme.colors.textSecondary
                    )
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Breadcrumb: \(segments.joined(separator: ", "))")
    }

    @Environment(\.dfTheme) private var theme
}

// Usage
BreadcrumbBar(segments: ["Settings", "Account", "Privacy"])
```

---

### 7. Error / Empty State Message

Centered icon, title, and supporting body copy — used for empty lists, network errors, and permission gates.

```swift
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionLabel: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            DFIcon(icon, size: .xl, color: theme.colors.textSecondary)

            VStack(spacing: theme.spacing.sm) {
                DFText(title, style: .headline)
                    .dfTextStyle(.primary)
                    .multilineTextAlignment(.center)

                DFText(message, style: .body)
                    .dfTextStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionLabel, let action {
                DFButton(actionLabel) { action() }
                    .dfButtonStyle(.secondary)
            }
        }
        .padding(theme.spacing.xxl)
        .frame(maxWidth: 320)
    }

    @Environment(\.dfTheme) private var theme
}

// Usage
EmptyStateView(
    icon: "tray",
    title: "Nothing here yet",
    message: "Projects you create will appear here. Get started by creating your first project.",
    actionLabel: "Create Project",
    action: { showNewProjectSheet = true }
)
```

---

### 8. Monospace / Code Display

`DFText` does not include a dedicated `.mono` style. When you need monospaced output — code snippets, terminal output, version strings — apply `theme.typography.body.font` and the `.monospaced()` modifier, or use a custom `Font.system` with the design override:

```swift
struct CodeBlock: View {
    let source: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(source)
                .font(theme.typography.body.font.monospaced())
                .lineSpacing(theme.typography.body.lineSpacing)
                .foregroundStyle(theme.colors.textPrimary)
                .padding(theme.spacing.md)
        }
        .background(theme.colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
    }

    @Environment(\.dfTheme) private var theme
}

// Alternatively — fixed monospace size independent of body scale
Text(versionString)
    .font(.system(.caption, design: .monospaced))
    .foregroundStyle(theme.colors.textSecondary)
    .tracking(0.4)
```

The second pattern is appropriate when the monospaced content has a semantic size distinct from body text — short version strings, hex codes, or compact identifiers — and you do not need full Dynamic Type scaling.

---

*Last updated: 2026-07-02 · Part of the [[DesignFoundation]] wiki*
