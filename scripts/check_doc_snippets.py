#!/usr/bin/env python3
"""
Compiles every ```swift fenced code block in DesignFoundation's AI-agent-facing
docs against the real package, so a doc snippet that doesn't match the actual
API fails CI instead of silently drifting (see CLAUDE.md's canonical-source note
for why this exists).

Usage: python3 scripts/check_doc_snippets.py [--keep]
  --keep   leave the generated harness files on disk for inspection (default:
           they're written fresh each run into scripts/DocSnippetCheck/Generated,
           which is gitignored).

Exit code is the underlying `swift build`'s exit code — 0 means every snippet
in every doc file below type-checked successfully.
"""
import re
import sys
import subprocess
import textwrap
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

# Every file whose ```swift fences should be compile-checked. Add to this list
# whenever a new doc gets code samples — the CI workflow calls this same script.
#
# NOT yet included: docs/product-description.md and docs/wiki/Style-System.md.
# Both need a smarter mode than this script's "each fence compiles standalone"
# model handles: Style-System.md is one continuous narrative where a type
# declared in an early fence (e.g. `GlowingNeonButtonStyle`) is used by later,
# separate fences, and several fences use `{ ... }` as a literal "elided code"
# placeholder rather than real Swift. Handle by either concatenating a file's
# fences in document order (opt-in per file) or adding a `{ ... }` -> `{ EmptyView() }`
# preprocessing pass, then add them here.
DOC_FILES = [
    "CLAUDE.md",
    "AGENTS.md",
    ".cursor/rules/design-foundation.mdc",
]

GENERATED_DIR = REPO_ROOT / "scripts" / "DocSnippetCheck" / "Generated"
FENCE_RE = re.compile(r"```swift\n(.*?)```", re.DOTALL)

# Fences containing one of these at column 0 are treated as complete, standalone
# top-level declarations (a whole `@main` app, a whole `struct ...: View`, etc.)
# and compiled as their own file rather than wrapped in a harness function body.
# A fence that's just `import X` is also toplevel — imports aren't legal inside a
# function body, and IMPORTS below already covers SwiftUI/DesignFoundation anyway.
TOPLEVEL_MARKERS = re.compile(
    r"^(@main\b|import\s|(public |private )?(struct|class|enum|extension)\s)",
    re.MULTILINE,
)

# Access modifiers are meaningless once a snippet is wrapped in a throwaway function
# (and `private`/`fileprivate` on a local var/func is a compile error, not just a
# no-op — Swift only allows access modifiers at non-local scope) — strip them from
# fragment bodies before wrapping, wherever they appear (e.g. after a property-wrapper
# attribute: `@Environment(\.dfTheme) private var theme`). Real top-level declaration
# fences are left untouched, since access control is legitimate there.
ACCESS_MODIFIER_RE = re.compile(r"\b(?:public|private|fileprivate|internal|open)\s+(?=(?:var|let|func)\b)")

IMPORTS = "import SwiftUI\nimport DesignFoundation\n"

# Stand-in declarations for the free identifiers doc snippets reference (`$email`,
# `roles`, `contacts`, etc.) so fragments type-check without a real app around them.
# Keep this in sync with the vocabulary actually used across DOC_FILES — if a new
# snippet introduces a new free identifier, add a stub for it here.
HARNESS_STUBS = textwrap.dedent(
    """\
    struct Contact: Identifiable {
        let id = UUID()
        var name: String = ""
        var company: String = ""
    }
    struct DocRole: Identifiable, Hashable {
        let id = UUID()
        var name: String = ""
    }

    @State var email: String = ""
    @State var password: String = ""
    @State var agreed: Bool = false
    @State var enabled: Bool = false
    @State var flag: Bool = false
    @State var date: Date = Date()
    @State var volume: Double = 0.5
    @State var query: String = ""
    @State var text: String = ""
    @State var bio: String = ""
    @State var val: Double = 0.5
    @State var quantity: Int = 1
    @State var role: DocRole = DocRole(name: "Admin")
    @State var showAlert: Bool = false
    @State var showModal: Bool = false
    @State var showSheet: Bool = false
    @State var showPopover: Bool = false
    @State var show: Bool = false
    @State var tab: String = "home"
    @State var selected: String? = nil
    @State var sel: String? = nil
    @State var selection: String? = nil
    let roles: [DocRole] = [DocRole(name: "Admin"), DocRole(name: "Member")]
    let contacts: [Contact] = []
    let condition: Bool = false
    let action: () -> Void = {}
    func deleteItem() {}

    struct DetailView: View {
        let id: String
        var body: some View { Text(id) }
    }
    let url = URL(string: "https://example.com")!
    let content = Text("Content")
    func submit(_ email: String, _ password: String) {}
    struct Item: Identifiable {
        let id = UUID()
        var title: String = ""
        var subtitle: String = ""
        var icon: String = ""
    }
    let items: [Item] = []
    let tabItems: [DFTabItem] = []
    @State var selectedDate: Date = Date()
    let oneYearFromNow = Date().addingTimeInterval(60 * 60 * 24 * 365)
    func hasEvent(on date: Date) -> Bool { false }
    func clearFilters() {}
    func requestNotificationPermission() {}
    func dismissPrompt() {}
    func clear() {}
    @State var showPalette: Bool = false
    func handle(_ item: DFCommandPaletteItem) {}
    let sections: [DFSidebarSection] = []
    let sidebarSections: [DFSidebarSection] = []
    let columnVisibility = NavigationSplitViewVisibility.all
    struct ContentView: View { var body: some View { EmptyView() } }
    struct YourContentView: View { var body: some View { EmptyView() } }
    struct YourView: View { var body: some View { EmptyView() } }
    struct MyView: View { var body: some View { EmptyView() } }
    struct ModalContent: View { var body: some View { EmptyView() } }
    struct SheetContent: View { var body: some View { EmptyView() } }
    struct PopoverContent: View { var body: some View { EmptyView() } }
    let someImage = Image(systemName: "photo")
    func tabContent(for id: String) -> some View { EmptyView() }
    struct ToolbarItems: View { var body: some View { EmptyView() } }
    let publishedDate = Date()
    @State var sizeSelection: String = "sm"
    @State var showGallery: Bool = false
    let image1 = Image(systemName: "photo")
    let image2 = Image(systemName: "photo.fill")
    let image3 = Image(systemName: "photo.on.rectangle")
    """
)


def extract_snippets():
    snippets = []
    for relpath in DOC_FILES:
        path = REPO_ROOT / relpath
        if not path.exists():
            continue
        text = path.read_text()
        for m in FENCE_RE.finditer(text):
            code = m.group(1)
            start_line = text[: m.start()].count("\n") + 1
            snippets.append((relpath, start_line, code))
    return snippets


def is_toplevel(code):
    return bool(TOPLEVEL_MARKERS.search(code))


def generate(snippets):
    GENERATED_DIR.mkdir(parents=True, exist_ok=True)
    for f in GENERATED_DIR.glob("snippet_*.swift"):
        f.unlink()
    placeholder = GENERATED_DIR / "Placeholder.swift"
    if placeholder.exists():
        placeholder.unlink()  # regenerated snippets replace it; restored by git on a fresh checkout

    for i, (relpath, line, code) in enumerate(snippets):
        header = f"// GENERATED — from {relpath}:{line}. Do not edit; edit the source doc instead.\n"
        if is_toplevel(code):
            content = f"{header}{IMPORTS}\n{code}\n"
        else:
            stripped_code = ACCESS_MODIFIER_RE.sub("", code)
            body = textwrap.indent(stripped_code, "    ")
            stubs = textwrap.indent(HARNESS_STUBS, "    ")
            content = (
                f"{header}{IMPORTS}\n"
                # @MainActor: doc snippets are always written as if inside SwiftUI view code,
                # which is MainActor-isolated (e.g. @Environment(\\.openURL) requires it).
                # @available(..., 26, *): several snippets intentionally demonstrate Liquid
                # Glass APIs the docs already label "iOS 26+/macOS 26+" — the snippet is
                # checked for correct syntax/argument shape, not for whether the *doc's own*
                # availability comment matches reality (verify that by eye, this only checks
                # "does the call compile").
                f"@available(iOS 26, macOS 26, visionOS 2, *)\n"
                f"@MainActor func __snippet_{i:03d}() {{\n{stubs}\n{body}\n}}\n"
            )
        (GENERATED_DIR / f"snippet_{i:03d}.swift").write_text(content)

    return len(snippets)


def main():
    keep = "--keep" in sys.argv
    snippets = extract_snippets()
    count = generate(snippets)
    print(f"Extracted and generated {count} snippet file(s) from {len(DOC_FILES)} doc file(s).")

    result = subprocess.run(
        ["swift", "build", "--target", "DocSnippetCheck"],
        cwd=REPO_ROOT,
    )

    if not keep:
        pass  # generated files stay — they're gitignored and cheap; re-run regenerates them fresh

    if result.returncode != 0:
        print(
            "\nOne or more documentation code samples failed to compile. "
            "Fix the source `.md`/`.mdc` file listed in the failing snippet's "
            "'GENERATED — from ...' header comment, then re-run this script.",
            file=sys.stderr,
        )
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
