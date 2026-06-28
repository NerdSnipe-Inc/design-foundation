# Contributing to DesignFoundation

Thank you for taking the time to contribute. This document covers everything you need to get a change merged cleanly.

---

## Workflow

1. **Fork** the repository and clone your fork locally.
2. **Create a branch** from `main` using the naming convention below.
3. Make your changes, keeping commits focused and conventional.
4. Open a **pull request** against `main` with a description that explains what changed and why.

### Branch naming

```
feat/short-description
fix/short-description
chore/short-description
docs/short-description
```

---

## Commit message format

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>

[optional body]
```

**Types:** `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`

**Scope** is the component or subsystem: `button`, `theme`, `tokens`, `tabbar`, etc.

Examples:
```
feat(card): add glass style variant
fix(textfield): correct filled-style disabled stroke color
chore: update SPM manifest for visionOS target
docs(readme): add quick-start example
```

Do not add a Co-Author line in commits unless you are explicitly coordinating with another contributor who asked to be credited.

---

## Pull request requirements

- All tests must pass (`swift test`).
- If you add a component, add at least one `#Preview` block in its source file.
- Include a clear PR description: what changed, which component(s) are affected, and how to verify the change.
- Accessibility: any new interactive component must carry correct `accessibilityLabel`, `accessibilityAddTraits`, and reduced-motion handling.
- No `AnyView` double-wraps. No bare `TODO` comments in shipped code.

---

## Code style

- **Swift 6 strict concurrency.** The package compiles with `StrictConcurrency` enabled. All value types must be `Sendable`. Use `@unchecked Sendable` only where `AnyView` forces it, and document why.
- Follow the existing pattern for style protocols: define `*StyleConfiguration`, `*Style` protocol, `Any*Style` type-erased wrapper, and a `View.df*Style(_:)` modifier.
- Components read from `DFTheme` via `@Environment(\.dfTheme)`; they never define their own color or spacing defaults in isolation.
- Prefer `let` over `var`. Prefer value types over reference types.

---

## Reporting issues

See the issue templates in `.github/ISSUE_TEMPLATE/` — use `bug_report.md` for bugs and `feature_request.md` for new component or token proposals. Providing a minimal reproduction snippet is the single fastest way to get a bug fixed.
