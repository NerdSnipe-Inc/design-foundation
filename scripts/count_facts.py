#!/usr/bin/env python3
"""
count_facts.py (DesignFoundation, free package) - the ONE reproducible source of numeric facts.

Every number quoted in README / CLAUDE.md / AGENTS.md / .cursor rules / llms.txt / the docs site / the wiki
must come from this script (`--markdown` prints the table to paste from) and CI runs
`--check` so a wrong number fails the build. Python 3 stdlib only, no Swift toolchain needed
(except the optional --cross-check / --run-tests).

USAGE
  python3 scripts/count_facts.py                    human-readable report
  python3 scripts/count_facts.py --json             machine-readable facts (incl. definitions + check_spec)
  python3 scripts/count_facts.py --markdown         compact facts table
  python3 scripts/count_facts.py --check FILE...    scan md/mdc/html/txt files (globs ok) for numeric claims
                                                    ("55 screens", "30+ components", ...) and report every
                                                    claim that disagrees. Exit 1 on any MISMATCH.
        --strict            also fail on ALT (documented alternative count) and LOOSE ('N+' far below actual)
        --facts-other FILE  JSON from the Pro script; enables verification of Pro-owned claims
                            (screens/blocks/shells/verticals...). Without it those claims are skipped.
  python3 scripts/count_facts.py --cross-check      run `swift package dump-symbol-graph` and diff the
                                                    compiler's public type / View / enum-case sets against
                                                    this scanner's
  python3 scripts/count_facts.py --run-tests        also run `swift test` and record RUNTIME test numbers
                                                    (kept separate from the static @Test count)
A line containing the text `facts-ignore` is skipped by --check (for legitimate non-count numbers).

WHAT IS SCANNED
  Sources/DesignFoundation/**/*.swift, excluding files named *Previews.swift and every `#if DEBUG` region.
  Tests are never scanned for API facts (only counted for the test metric). Comments and string literals are
  blanked before parsing. `#if compiler(...)` / `#available` gating is NOT evaluated: a declaration gated to
  the Xcode 26 SDK still counts (Package.swift's platform floor is 18 but the API surface includes .glass).

VISIBILITY RULE
  "Public" = effective public API: explicit `public`/`open`, or a member of a `public extension`, or a
  requirement of a public protocol, or a case of a public enum - AND every enclosing type is public too.

METRIC DEFINITIONS (the numbers in `canonical`)
  public_view_types      public struct/class conforming to SwiftUI `View` (directly or via an extension).
  components_standalone  public_view_types minus `supporting_views`. CANONICAL "components" figure for prose:
                         "N components". A component is a View a developer instantiates as UI.
  supporting_views       public Views that are building blocks or infrastructure of another component, not
                         a UI element on their own: DFPopupIconBadge / DFPopupHeader / DFPopupActions
                         (the "pieces" of DFPopupCard) and DFPopupHost (mount point behind .dfPopup).
                         (explicit list in SUPPORTING_VIEWS below; the only judgement call in the view split)
  modifiers_presentation public `func dfXxx` in `extension View` that is neither a style setter nor a theme
                         setter: overlays, layout, navigation chrome (dfModal, dfSheet, dfPopup, dfToast,
                         dfBottomBar, dfNavigationBar, ...). Counted by DISTINCT NAME (overloads reported).
  modifiers_style_setters public View funcs named df<Component>Style (inject a style into the environment).
  modifiers_theme        dfTheme + dfThemePreset.
  style_protocols        public protocols named DF*Style (a "styleable component" = one protocol).
  style_structs          public structs conforming to a DF*Style protocol, excluding type-erasers (Any*).
                         (the `Sendable` subset is reported separately; normally identical.)
  style_shorthands       `static var/func` members of `extension DFxStyle where Self == X` (the `.filled` sugar).
  components_with_glass  style protocols that ship a `.glass` shorthand or a *Glass* style struct.
  theme_presets          `static let` presets declared in DFThemePreset (each = a light + a dark DFTheme).
  color/spacing/radius/typography/animation tokens: stored public properties (colors: only `Color`-typed) of DFColorTokens /
                         DFSpacingTokens / DFRadiusTokens / DFTypographyTokens / DFAnimationTokens;
                         shadow levels = stored properties of DFShadowTokens.
  component_token_structs public DF*Tokens structs in DFComponentTokens.swift (per-component overrides);
  component_token_fields  their stored optional properties in total.
  environment_keys       public `var dfXxx` in `extension EnvironmentValues`.
  validators             public structs conforming to DFFieldValidator (built-in ones).
  popup_* / toast_*      styles = concrete style structs of DFPopupStyle / DFToastStyle; kinds, positions,
                         transitions, backdrops, severities, layouts = case counts of the public enums.
  public_types_total     public struct/class/enum/protocol/actor incl. nested public ones.
  tests_static_swift_testing  count of `@Test` attributes under Tests/ (NOT a pass count; runtime numbers only
                         appear under `runtime_tests` when --run-tests was used).
"""
# ---------------------------------------------------------------------------
# Shared Swift declaration scanner (identical in both repos' count scripts).
# It is a lexical scanner, not a compiler: comments and string literals are
# blanked, `#if DEBUG` regions are dropped, brace structure is tracked, and every
# declaration is resolved to an *effective public visibility* (explicit access
# modifier, `public extension` inheritance, enclosing-type visibility, protocol
# requirements, enum cases). Its output is cross-checked against the compiler's
# symbol graph (see --symbol-graph) — the two must agree.
# ---------------------------------------------------------------------------
import argparse
import json
import re
import sys
from collections import OrderedDict, defaultdict
from pathlib import Path

TYPE_KINDS = ("struct", "class", "enum", "protocol", "actor")
SCOPE_KINDS = TYPE_KINDS + ("extension",)
ACCESS_WORDS = ("public", "open", "internal", "private", "fileprivate", "package")


def _skip_string(s, i, out):
    """s[i] is the opening quote. Blank the literal into `out`; return index after it."""
    n = len(s)
    hashes = 0
    j = i
    while j > 0 and s[j - 1] == "#":  # raw string: hashes were already emitted; count them
        hashes += 1
        j -= 1
    multiline = s.startswith('"""', i)
    q = '"""' if multiline else '"'
    out.append(" " * len(q))
    i += len(q)
    closer = q + "#" * hashes
    while i < n:
        c = s[i]
        if s.startswith(closer, i):
            out.append(" " * len(closer))
            return i + len(closer)
        if c == "\\" and s.startswith("\\" + "#" * hashes + "(", i):
            # interpolation: skip balanced parens (strings inside handled recursively)
            k = i + 2 + hashes
            depth = 1
            out.append(" " * (k - i))
            while k < n and depth:
                ch = s[k]
                if ch == '"':
                    k = _skip_string(s, k, out)
                    continue
                if ch == "(":
                    depth += 1
                elif ch == ")":
                    depth -= 1
                out.append("\n" if ch == "\n" else " ")
                k += 1
            i = k
            continue
        if c == "\\" and hashes == 0 and i + 1 < n:
            out.append(" " + ("\n" if s[i + 1] == "\n" else " "))
            i += 2
            continue
        out.append("\n" if c == "\n" else " ")
        i += 1
        if not multiline and c == "\n":
            return i  # unterminated single-line string; bail
    return i


def strip_comments_strings(s):
    out = []
    i, n = 0, len(s)
    while i < n:
        c = s[i]
        if c == "/" and i + 1 < n and s[i + 1] == "/":
            j = s.find("\n", i)
            j = n if j < 0 else j
            out.append(" " * (j - i))
            i = j
        elif c == "/" and i + 1 < n and s[i + 1] == "*":
            depth = 1
            k = i + 2
            while k < n and depth:
                if s.startswith("/*", k):
                    depth += 1
                    k += 2
                elif s.startswith("*/", k):
                    depth -= 1
                    k += 2
                else:
                    k += 1
            out.append("".join("\n" if ch == "\n" else " " for ch in s[i:k]))
            i = k
        elif c == '"':
            i = _skip_string(s, i, out)
        elif c == "#" and re.match(r'#+"', s[i:i + 6]):
            m = re.match(r"#+", s[i:])
            out.append(m.group(0))
            i += len(m.group(0))
            i = _skip_string(s, i, out)
        else:
            out.append(c)
            i += 1
    return "".join(out)


def drop_debug_blocks(s):
    """Blank every `#if DEBUG` ... (`#else`|`#endif`) region (release-only code is kept)."""
    lines = s.split("\n")
    stack = []  # each: {"debug": bool, "blank": bool}
    out = []
    for ln in lines:
        t = ln.strip()
        blank_here = any(f["blank"] for f in stack)
        if t.startswith("#if"):
            stack.append({"debug": re.fullmatch(r"#if\s+DEBUG", t) is not None, "blank": False})
            if stack[-1]["debug"]:
                stack[-1]["blank"] = True
            out.append("" if (blank_here or stack[-1]["blank"]) else ln)
            continue
        if t.startswith("#elseif") or t.startswith("#else"):
            if stack and stack[-1]["debug"]:
                stack[-1]["blank"] = False
            out.append(ln if not any(f["blank"] for f in stack) else "")
            continue
        if t.startswith("#endif"):
            was_blank = any(f["blank"] for f in stack)
            if stack:
                stack.pop()
            out.append("" if was_blank else ln)
            continue
        out.append("" if blank_here else ln)
    return "\n".join(out)


MOD = (r"(?:(?:public|internal|private|fileprivate|open|package)(?:\([a-z]+\))?|final|static|class|indirect|"
       r"mutating|nonmutating|override|required|convenience|lazy|nonisolated(?:\([a-z]+\))?|weak|dynamic|"
       r"prefix|postfix|infix|@[\w.]+(?:\([^()\n]*(?:\([^()\n]*\)[^()\n]*)*\))?)")
DECL_RE = re.compile(
    r"(?:^|(?<=[{};]))[ \t]*(?P<mods>(?:" + MOD + r"[ \t]+)*)"
    r"(?P<kind>struct|class|enum|protocol|extension|actor|func|var|let|case|typealias|init|subscript)\b",
    re.M,
)


class Decl:
    __slots__ = ("kind", "name", "mods", "access", "file", "line", "parent", "inherits", "target",
                 "where_self", "static", "header", "public", "off", "scope_open", "scope_close", "folder",
                 "children", "cases")

    def __init__(self, **kw):
        self.children = []
        self.cases = []
        for k in self.__slots__:
            if k not in kw and not hasattr(self, k):
                setattr(self, k, None)
        for k, v in kw.items():
            setattr(self, k, v)

    @property
    def qname(self):
        base = self.target if self.kind == "extension" else self.name
        if self.parent is not None and self.parent.kind != "extension" and self.kind != "extension":
            return self.parent.qname + "." + base
        if self.parent is not None and self.parent.kind == "extension" and self.kind != "extension":
            return self.parent.target + "." + base
        return base


def _split_top(s, sep=","):
    parts, depth, cur = [], 0, []
    for ch in s:
        if ch in "<([":
            depth += 1
        elif ch in ">)]":
            depth -= 1
        if ch == sep and depth == 0:
            parts.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
    parts.append("".join(cur))
    return [p.strip() for p in parts if p.strip()]


def _parse_inherits(after_name):
    """after_name: text following the type name up to `{`. Returns (inherit idents, where clause)."""
    s = after_name
    if s.lstrip().startswith("<"):  # generic parameter clause
        depth, k = 0, s.index("<")
        for k in range(s.index("<"), len(s)):
            if s[k] == "<":
                depth += 1
            elif s[k] == ">" and s[k - 1] != "-":
                depth -= 1
                if depth == 0:
                    s = s[k + 1:]
                    break
    where = ""
    m = re.search(r"\bwhere\b", s)
    if m:
        where = s[m.end():].strip()
        s = s[:m.start()]
    s = s.strip()
    inh = []
    if s.startswith(":"):
        for part in _split_top(s[1:]):
            part = re.sub(r"^(@\w+\s+)+", "", part).strip()
            m2 = re.match(r"[\w.]+", part)
            if m2:
                inh.append(m2.group(0).split(".")[-1])
    return inh, where


def parse_source(text, relpath, folder):
    clean = drop_debug_blocks(strip_comments_strings(text))
    # brace pairs
    pairs = {}  # open offset -> close offset
    stack = []
    for i, ch in enumerate(clean):
        if ch == "{":
            stack.append(i)
        elif ch == "}" and stack:
            pairs[stack.pop()] = i
    close_to_open = {v: k for k, v in pairs.items()}
    opens_sorted = sorted(pairs)
    line_starts = [0]
    for m in re.finditer("\n", clean):
        line_starts.append(m.end())
    import bisect

    def lineno(off):
        return bisect.bisect_right(line_starts, off)

    def innermost_open(off):
        # innermost brace pair containing off (open < off < close)
        best = None
        for o in opens_sorted:
            if o >= off:
                break
            if pairs[o] > off:
                best = o
        return best

    decls = []
    scope_by_open = {}
    for m in DECL_RE.finditer(clean):
        kind = m.group("kind")
        mods = m.group("mods").split()
        rest_start = m.end()
        # `class func` etc: DECL_RE greedy mods eat 'class' as a modifier, leaving kind=func — fine.
        if kind == "class" and re.match(r"\s*(func|var|let|subscript)\b", clean[rest_start:rest_start + 12]):
            continue
        encl = innermost_open(m.start() + len(m.group(0)) - len(kind))
        if encl is not None and encl not in scope_by_open:
            # enclosing brace is a func/closure/var body (not a type scope) -> local declaration
            # (scope_by_open is filled lazily in order; enclosing scopes precede members)
            continue
        access, static = None, False
        for md in mods:
            base = md.split("(")[0]
            if md in ("static", "class"):
                static = True
            if base in ACCESS_WORDS and "(" not in md:
                access = base
        d = Decl(kind=kind, mods=mods, access=access, file=relpath, line=lineno(m.start("kind")),
                 folder=folder, static=static, off=m.start("kind"))
        d.parent = scope_by_open.get(encl)
        tail = clean[rest_start:]
        if kind in SCOPE_KINDS:
            ob = tail.find("{")
            if ob < 0:
                continue
            header = tail[:ob]
            d.header = header
            if kind == "extension":
                mt = re.match(r"\s*([\w.]+)", header)
                d.target = mt.group(1) if mt else "?"
                d.name = d.target
                inh, where = _parse_inherits(header[mt.end():] if mt else header)
            else:
                mt = re.match(r"\s*`?([\w]+)`?", header)
                d.name = mt.group(1) if mt else "?"
                inh, where = _parse_inherits(header[mt.end():] if mt else header)
            d.inherits = inh
            mw = re.match(r"\s*Self\s*==\s*([\w.]+)", where)
            d.where_self = mw.group(1) if mw else None
            d.scope_open = rest_start + ob
            scope_by_open[d.scope_open] = d
        elif kind == "case":
            # enum cases: `case a, b(Int), c = 1` up to end of line at depth 0
            eol = tail.find("\n")
            body = tail[: eol if eol >= 0 else len(tail)]
            names = []
            for part in _split_top(body):
                mm = re.match(r"\s*`?(\w+)`?", part)
                if mm:
                    names.append(mm.group(1))
            d.name = names[0] if names else "?"
            d.cases = names
        elif kind in ("func", "var", "let", "typealias"):
            mm = re.match(r"\s*`?([\w]+)`?", tail)
            if not mm:
                mm = re.match(r"\s*([^\s(<]+)", tail)  # operator func
            d.name = mm.group(1) if mm else "?"
            eol = tail.find("\n")
            d.header = tail[: eol if eol >= 0 else len(tail)]
        elif kind == "init":
            d.name = "init"
        else:
            d.name = kind
        if d.parent is not None:
            d.parent.children.append(d)
        decls.append(d)
    return decls


def resolve_visibility(all_decls):
    """Sets d.public for every declaration. Two passes: type visibility, then members."""
    types = defaultdict(list)
    for d in all_decls:
        if d.kind in TYPE_KINDS:
            types[d.name].append(d)

    def own_visible(d, memo={}):
        key = id(d)
        if key in memo:
            return memo[key]
        memo[key] = False  # recursion guard
        p = d.parent
        acc = d.access
        if acc is None:
            if p is not None and p.kind == "extension" and p.access in ("public", "open"):
                acc = "public"
            elif p is not None and p.kind == "protocol":
                acc = "public" if own_visible(p) else "internal"
            elif p is not None and p.kind == "enum" and d.kind == "case":
                acc = "public" if own_visible(p) else "internal"
            elif p is not None and p.kind == "extension" and p.access is None and d.kind == "case":
                acc = "internal"
            else:
                acc = "internal"
        ok = acc in ("public", "open")
        if ok and d.kind == "extension":
            # visible extension iff target is external or a visible in-module type
            tgt = d.target.split(".")[-1]
            if tgt in types:
                ok = any(own_visible(t) for t in types[tgt])
        if ok and p is not None:
            if p.kind == "extension":
                # a member is only public API if the extension's target is; explicit access on the
                # extension is not required when the member itself says `public`.
                tgt = p.target.split(".")[-1]
                if tgt in types:
                    ok = any(own_visible(t) for t in types[tgt])
                if p.access in ("private", "fileprivate", "internal", "package") and d.access is None:
                    ok = False
            else:
                ok = own_visible(p)
        memo[key] = ok
        return ok

    memo = {}
    for d in all_decls:
        d.public = own_visible(d, memo)
    return types


def load_module(root: Path, target_dir: str, skip_names=None):
    """Parse every non-preview .swift file under root/Sources/<target_dir>."""
    src = root / "Sources" / target_dir
    decls = []
    files = []
    for f in sorted(src.rglob("*.swift")):
        if re.search(r"Previews?\.swift$", f.name):
            continue
        rel = f.relative_to(src)
        folder = rel.parts[0] if len(rel.parts) > 1 else "(root)"
        files.append(str(rel))
        decls.extend(parse_source(f.read_text(encoding="utf-8"), str(rel), folder))
    resolve_visibility(decls)
    return decls, files


class Module:
    def __init__(self, decls, files):
        self.decls = decls
        self.files = files
        self.types = [d for d in decls if d.kind in TYPE_KINDS and d.public]
        self.by_name = defaultdict(list)
        for d in decls:
            if d.kind in TYPE_KINDS:
                self.by_name[d.name].append(d)
        # conformances added by extensions (`extension Foo: View`)
        self.extra_inherits = defaultdict(set)
        for d in decls:
            if d.kind == "extension" and d.inherits:
                self.extra_inherits[d.target.split(".")[-1]].update(d.inherits)

    def inherits_of(self, t):
        return set(t.inherits or []) | self.extra_inherits.get(t.name, set())

    def conforms(self, t, proto):
        return proto in self.inherits_of(t)

    def public_types(self, kind=None):
        return [t for t in self.types if kind is None or t.kind == kind]

    def members(self, t, kind=None, static=None, pub=True):
        """Members declared directly in the type body and in extensions of it."""
        out = list(t.children)
        for e in self.decls:
            if e.kind == "extension" and e.target.split(".")[-1] == t.name:
                out.extend(e.children)
        return [m for m in out if (kind is None or m.kind == kind)
                and (static is None or m.static == static) and (not pub or m.public)]

    def stored_props(self, t):
        """Instance `var`/`let` declared in the type body that have no accessor body / are stored-looking."""
        res = []
        for m in t.children:
            if m.kind in ("var", "let") and m.public and not m.static:
                res.append(m)
        return res


def rel(d):
    return {"name": d.qname, "file": d.file, "line": d.line}


def line_of_file_count(path, pattern):
    return len(re.findall(pattern, Path(path).read_text(encoding="utf-8", errors="replace"), re.M))


def count_swift_testing(tests_dir: Path):
    n_test = n_suite = n_xctest = 0
    per_file = {}
    for f in sorted(tests_dir.rglob("*.swift")):
        clean = drop_debug_blocks(strip_comments_strings(f.read_text(encoding="utf-8")))
        t = len(re.findall(r"^[ \t]*@Test\b", clean, re.M))
        s = len(re.findall(r"^[ \t]*@Suite\b", clean, re.M))
        x = len(re.findall(r"^[ \t]*(?:@\w+\s+)*func\s+test\w*\s*\(", clean, re.M))
        n_test, n_suite, n_xctest = n_test + t, n_suite + s, n_xctest + x
        if t or s or x:
            per_file[str(f.relative_to(tests_dir))] = {"test": t, "suite": s, "xctest_funcs": x}
    return {"swift_testing_@Test": n_test, "swift_testing_@Suite": n_suite, "xctest_test_funcs": n_xctest,
            "files": per_file}


def package_info(pkg: Path):
    t = pkg.read_text(encoding="utf-8")
    m = re.match(r"// swift-tools-version:\s*([\d.]+)", t)
    plats = re.findall(r"\.(iOS|macOS|visionOS|watchOS|tvOS)\(\s*\.v(\d+)", t)
    return {"swift_tools_version": m.group(1) if m else None,
            "platforms": {p: int(v) for p, v in plats},
            "platforms_text": ", ".join(f"{p} {v}+" for p, v in plats)}


def changelog_version(path: Path):
    """Newest released version = first `## [x.y.z]` heading (the [Unreleased] section is skipped)."""
    try:
        m = re.search(r"^##\s*\[(\d+\.\d+\.\d+)\]", path.read_text(encoding="utf-8"), re.M)
    except OSError:
        return None
    return m.group(1) if m else None


# ------------------------------ symbol-graph cross-check --------------------------------
def symbol_graph_check(build_dir: Path, module_name: str, module: "Module", extra_ok=()):
    """Compare public View-conforming types, public type names and public enum cases with the
    compiler's symbol graph JSON (directory produced by `swift package dump-symbol-graph`)."""
    graphs = sorted(build_dir.rglob(f"{module_name}.symbols.json"))
    if not graphs:
        return {"error": f"no {module_name}.symbols.json under {build_dir}"}
    g = json.loads(graphs[0].read_text())
    syms = {s["identifier"]["precise"]: s for s in g["symbols"]}
    kinds = {"swift.struct": "struct", "swift.class": "class", "swift.enum": "enum", "swift.protocol": "protocol",
             "swift.actor": "actor"}
    comp_types = {}
    for pid, s in syms.items():
        k = s["kind"]["identifier"]
        if k in kinds and s.get("accessLevel") in ("public", "open"):
            comp_types[".".join(s["pathComponents"])] = (pid, kinds[k])
    view_ids = set()
    for r in g["relationships"]:
        if r["kind"] == "conformsTo" and r["target"].endswith("SwiftUI4ViewP") or (
                r["kind"] == "conformsTo" and r.get("targetFallback") == "SwiftUI.View"):
            view_ids.add(r["source"])
    comp_views = {".".join(syms[i]["pathComponents"]) for i in view_ids if i in syms and
                  syms[i]["kind"]["identifier"] in ("swift.struct", "swift.class")}
    mine_types = {t.qname: t.kind for t in module.types}
    mine_views = {t.qname for t in module.types if module.conforms(t, "View") and t.kind in ("struct", "class")}
    # enum cases
    comp_cases = {".".join(s["pathComponents"]) for s in syms.values()
                  if s["kind"]["identifier"] == "swift.enum.case" and s.get("accessLevel") in ("public", "open")}
    mine_cases = set()
    for t in module.types:
        if t.kind == "enum":
            for m in module.members(t, kind="case"):
                for c in m.cases:
                    mine_cases.add(f"{t.qname}.{c}")
    def strip(names):
        return {re.sub(r"\(.*\)$", "", n) for n in names}

    def diff(a, b):
        return {"only_in_script": sorted(a - b), "only_in_compiler": sorted(b - a)}

    # extension members on external types (View modifiers, EnvironmentValues keys) live in @-suffixed graphs
    ext_syms = []
    for gp in sorted(build_dir.rglob(f"{module_name}@*.symbols.json")):
        ext_syms += json.loads(gp.read_text())["symbols"]
    comp_mods = {re.sub(r"\(.*\)$", "", s["pathComponents"][1]) for s in ext_syms
                 if s["pathComponents"][0] == "View" and len(s["pathComponents"]) == 2
                 and s["pathComponents"][1].startswith("df") and s.get("accessLevel") == "public"}
    mine_mods = {f.name for e in module.decls if e.kind == "extension" and e.target == "View"
                 for f in e.children if f.kind == "func" and f.public and f.name.startswith("df")}
    comp_env = {s["pathComponents"][1] for s in ext_syms if s["pathComponents"][0] == "EnvironmentValues"
                and len(s["pathComponents"]) == 2 and s["pathComponents"][1].startswith("df")}
    mine_env = {f.name for e in module.decls if e.kind == "extension" and e.target == "EnvironmentValues"
                for f in e.children if f.kind == "var" and f.public and f.name.startswith("df")}
    # style shorthands: `static` members of `extension DFxStyle where Self == X`
    style_protos = {t.name for t in module.types if t.kind == "protocol" and re.fullmatch(r"DF\w+Style", t.name)}
    mine_short = set()
    for e in module.decls:
        if e.kind == "extension" and e.target in style_protos and e.where_self:
            for c in e.children:
                if c.kind in ("var", "func") and c.static and c.public:
                    mine_short.add(f"{e.target}.{c.name}")
    comp_short = set()
    for s in syms.values():
        pc = s["pathComponents"]
        if len(pc) == 2 and pc[0] in style_protos and s["kind"]["identifier"] in ("swift.type.property", "swift.type.method"):
            comp_short.add(f"{pc[0]}.{re.sub(r'[(].*$', '', pc[1])}")
    mine_short_s = mine_short
    return {
        "compiler_symbol_graph": str(graphs[0]),
        "public_types": {"script": len(mine_types), "compiler": len(comp_types),
                         **diff(set(mine_types), set(comp_types))},
        "public_view_types": {"script": len(mine_views), "compiler": len(comp_views),
                              **diff(mine_views, comp_views)},
        "public_enum_cases": {"script": len(mine_cases), "compiler": len(strip(comp_cases)),
                              **diff(mine_cases, strip(comp_cases))},
        "public_view_modifiers_df": {"script": len(mine_mods), "compiler": len(comp_mods), **diff(mine_mods, comp_mods)},
        "environment_keys_df": {"script": len(mine_env), "compiler": len(comp_env), **diff(mine_env, comp_env)},
        "style_shorthands": {"script": len(mine_short_s), "compiler": len(comp_short), **diff(mine_short_s, comp_short)},
    }


# ------------------------------------ --check mode ------------------------------------
# "one" is left out on purpose: "one component", "one per vertical" are idioms, not counts.
NUMBER_WORDS = {w: i for i, w in enumerate(
    "zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen "
    "seventeen eighteen nineteen twenty".split()) if w != "one"}
IGNORE_MARK = "facts-ignore"
# Words allowed between the number and the noun ("43 accessible components"). Any other word scopes the
# claim to a subset ("three navigation components", "six Settings screens") and the claim is not checked.
ADJECTIVES = ("swiftui|production-ready|production-grade|accessible|primitive|ready-made|pre-built|prebuilt|themed|"
              "native|reusable|composable|finished|premium|total|distinct|public|built-in|builtin|fully|wired|"
              "runnable|self-contained|additional|individual|different|real|tested|documented|more|unique|free|"
              "mit|licensed|polished|ready|ready-to-use|styleable|themeable|customizable|df|pro|ui|cross-platform|"
              "verified|curated|hand-built|reference|full|complete|new|pre-made|high-quality|beautiful|themable")


def _entries_from(facts):
    return facts.get("check_spec", [])


def check_files(paths, entries, strict=False, versions=()):
    """entries: list of {key, noun (regex), canonical, alts {str(value): why}, owner}.
    A claim `N <adjectives> <noun>` is compared with every entry whose noun regex matches.
    Verdicts: OK, ALT (matches a documented alternative count, not the canonical one),
    MORE_THAN (`N+` with N <= canonical), LOOSE (`N+` far below canonical), MISMATCH."""
    import glob as _glob
    files = []
    for p in paths:
        hits = sorted(_glob.glob(p, recursive=True)) or ([p] if Path(p).exists() else [])
        for h in hits:
            hp = Path(h)
            if hp.is_dir():
                files += [str(x) for x in sorted(hp.rglob("*")) if x.suffix in (".md", ".mdc", ".txt", ".html") and x.is_file()]
            elif hp.is_file():
                files.append(str(hp))
    files = list(OrderedDict.fromkeys(files))
    noun_alt = "|".join(f"(?:{n})" for n in sorted({e['noun'] for e in entries}, key=len, reverse=True))
    num = r"(?P<num>\d{1,3}(?:,\d{3})+|\d+|" + "|".join(sorted(NUMBER_WORDS, key=len, reverse=True)) + r")"
    rx = re.compile(r"(?<![\w.$/#-])" + num + r"(?P<plus>\+)?[ \t]+(?:(?:" + ADJECTIVES + r")[ \t]+){0,3}?(?P<noun>" + noun_alt + r")\b",
                    re.I)
    rx_cell = re.compile(r"\|[ \t]*\**(?:(?:" + ADJECTIVES + r")[ \t]+){0,2}(?P<noun>" + noun_alt + r")\**[ \t]*\|[ \t]*\**~?(?P<num>\d+)(?P<plus>\+)?",
                         re.I)
    results = []
    for f in files:
        try:
            text = Path(f).read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for ln, line in enumerate(text.split("\n"), 1):
            if IGNORE_MARK in line:
                continue
            plain = re.sub(r"<[^>]+>", "", line)
            plain = plain.replace("**", "").replace("`", "")
            for ve in versions:
                for vm in re.finditer(ve["regex"], plain):
                    ok = vm.group(1) == ve["canonical"]
                    results.append({"file": f, "line": ln, "claim": vm.group(0).strip(), "verdict": "OK" if ok else "MISMATCH",
                                    "canonical": f"{ve['key']}={ve['canonical']}", "note": "", "text": line.strip()[:160]})
            found = []  # (number token, plus?, noun text, matched text)
            for m in rx.finditer(plain):
                found.append((m.group("num"), bool(m.group("plus")), m.group("noun"), m.group(0).strip()))
            for m in rx_cell.finditer(plain):  # markdown table cells:  | Pro screens | 47 |
                found.append((m.group("num"), bool(m.group("plus")), m.group("noun"), m.group(0).strip("| ")))
            for raw, plus, noun, claim in found:
                raw = raw.lower()
                n = int(raw.replace(",", "")) if (raw.isdigit() or "," in raw) else NUMBER_WORDS[raw]
                if n > 1900 and "," not in raw:  # a year, not a count
                    continue
                matching = [e for e in entries if re.fullmatch(e["noun"], noun, re.I)]
                if not matching:
                    continue
                verdict, why = "MISMATCH", ""
                if all(e.get("generic") and n < 0.5 * e["canonical"] for e in matching):
                    # a small count on a generic noun ("three components", "Auth - 5 blocks") is a scoped
                    # sub-count, not a claim about the whole package: not checked.
                    results.append({"file": f, "line": ln, "claim": claim, "verdict": "SCOPED",
                                    "canonical": "", "note": "small count on a generic noun", "text": line.strip()[:160]})
                    continue
                for e in matching:
                    c = e["canonical"]
                    if plus:
                        if n <= c:
                            verdict = "MORE_THAN" if n >= 0.75 * c else "LOOSE"
                            why = f"'{n}+' <= {c}"
                            break
                    elif n == c:
                        verdict, why = "OK", "canonical"
                        break
                    elif str(n) in e.get("alts", {}):
                        verdict, why = "ALT", e["alts"][str(n)]
                if verdict == "MISMATCH":
                    why = "; ".join(f"{e['key']}={e['canonical']}" for e in matching)
                results.append({"file": f, "line": ln, "claim": claim, "verdict": verdict,
                                "canonical": "; ".join(f"{e['key']}={e['canonical']}" for e in matching),
                                "note": why, "text": line.strip()[:160]})
    return results


def report_check(results, strict, out=sys.stdout):
    fail = ("MISMATCH", "ALT", "LOOSE") if strict else ("MISMATCH",)
    for r in results:
        if r["verdict"] in ("OK", "MORE_THAN", "SCOPED"):
            continue
        print(f"{r['file']}:{r['line']}: {r['verdict']}: \"{r['claim']}\" -> canonical {r['canonical']}"
              + (f" ({r['note']})" if r["verdict"] != "MISMATCH" and r["note"] else ""), file=out)
    n_bad = sum(1 for r in results if r["verdict"] in fail)
    print(f"\nchecked {len(results)} numeric claims: "
          + ", ".join(f"{v}={sum(1 for r in results if r['verdict'] == v)}"
                      for v in ("OK", "SCOPED", "MORE_THAN", "ALT", "LOOSE", "MISMATCH"))
          + (f"  -> FAIL ({n_bad})" if n_bad else "  -> ok"), file=out)
    return 1 if n_bad else 0


# ----------------------------------- free package metrics -----------------------------------
import subprocess

TARGET = "DesignFoundation"
SUPPORTING_VIEWS = ("DFPopupIconBadge", "DFPopupHeader", "DFPopupActions", "DFPopupHost")
THEME_MODIFIERS = ("dfTheme", "dfThemePreset")


def _is_stored(m):
    return "{" not in (m.header or "")


def _cases(m, enum_name):
    ts = [t for t in m.public_types("enum") if t.name == enum_name]
    if not ts:
        return []
    out = []
    for c in m.members(ts[0], kind="case"):
        out.extend(c.cases)
    return out


def _stored(m, struct_name, type_prefix=None):
    ts = [t for t in m.public_types("struct") if t.name == struct_name]
    if not ts:
        return []
    return [p.name for p in m.stored_props(ts[0]) if _is_stored(p)
            and (type_prefix is None or re.match(r"\s*`?\w+`?\s*:\s*" + type_prefix + r"\b", p.header or ""))]


def compute(root: Path):
    decls, files = load_module(root, TARGET)
    m = Module(decls, files)
    pkg = package_info(root / "Package.swift")
    tests = count_swift_testing(root / "Tests")

    # ---- views
    views = [t for t in m.types if t.kind in ("struct", "class") and m.conforms(t, "View")]
    by_folder = defaultdict(list)
    for v in views:
        by_folder[v.folder].append(v.qname)
    standalone = [v for v in views if v.qname not in SUPPORTING_VIEWS]
    supporting = [v for v in views if v.qname in SUPPORTING_VIEWS]

    # ---- view modifiers
    mods = defaultdict(int)
    for e in decls:
        if e.kind == "extension" and e.target == "View":
            for f in e.children:
                if f.kind == "func" and f.public and f.name.startswith("df"):
                    mods[f.name] += 1
    style_setters = sorted(n for n in mods if n.endswith("Style"))
    theme_mods = sorted(n for n in mods if n in THEME_MODIFIERS)
    presentation = sorted(n for n in mods if n not in style_setters and n not in theme_mods)

    # ---- styles
    proto = {t.name: t for t in m.public_types("protocol") if re.fullmatch(r"DF\w+Style", t.name)}
    style_rows = {}
    for pn in sorted(proto):
        structs = [t for t in m.public_types("struct") if pn in m.inherits_of(t) and not t.name.startswith("Any")]
        short = set()
        for e in decls:
            if e.kind == "extension" and e.target == pn and e.where_self:
                for c in e.children:
                    if c.kind in ("var", "func") and c.static and c.public:
                        short.add(c.name)
        style_rows[pn] = {
            "structs": sorted(t.name for t in structs),
            "sendable_structs": sorted(t.name for t in structs if "Sendable" in m.inherits_of(t)),
            "shorthands": sorted(short),
            "glass": ("glass" in short) or any("Glass" in t.name for t in structs),
        }
    glass = sorted(pn for pn, r in style_rows.items() if r["glass"])

    # ---- theme
    presets = []
    for t in m.public_types("struct"):
        if t.name == "DFThemePreset":
            presets = [c.name for c in t.children if c.kind == "let" and c.static and c.public
                       and "DFThemePreset(" in (c.header or "")]
    tok = {k: _stored(m, k, "Color" if k == "DFColorTokens" else None) for k in ("DFColorTokens", "DFSpacingTokens", "DFRadiusTokens", "DFShadowTokens",
                                       "DFTypographyTokens", "DFAnimationTokens")}
    comp_tok = [t for t in m.public_types("struct")
                if t.file.endswith("DFComponentTokens.swift") and re.fullmatch(r"DF\w+Tokens", t.name)
                and t.name != "DFComponentTokens"]
    comp_tok_fields = {t.name: [p.name for p in m.stored_props(t) if _is_stored(p)] for t in comp_tok}
    comp_container = _stored(m, "DFComponentTokens")

    # ---- environment keys
    env = sorted({f.name for e in decls if e.kind == "extension" and e.target == "EnvironmentValues"
                  for f in e.children if f.kind == "var" and f.public and f.name.startswith("df")})
    validators = sorted(t.name for t in m.public_types("struct")
                        if "DFFieldValidator" in m.inherits_of(t) and not t.name.startswith("Any"))

    # ---- popup & toast surface
    def concrete(pn):
        return style_rows.get(pn, {}).get("structs", [])
    popup = {
        "popup_styles": concrete("DFPopupStyle"),
        "popup_kinds": _cases(m, "DFPopupKind"),
        "popup_positions": _cases(m, "DFPopupPosition"),
        "popup_transitions": _cases(m, "DFPopupTransition"),
        "popup_backdrops": _cases(m, "DFPopupBackdrop"),
        "toast_styles": concrete("DFToastStyle"),
        "toast_severities": _cases(m, "DFToastSeverity"),
        "toast_layouts": _cases(m, "DFToastLayout"),
    }
    kinds_count = defaultdict(int)
    for t in m.types:
        kinds_count[t.kind] += 1

    canonical = OrderedDict()
    definitions = {}

    def put(key, val, definition):
        canonical[key] = val
        definitions[key] = definition

    put("public_view_types", len(views), "public struct/class conforming to View")
    put("components_standalone", len(standalone), "CANONICAL 'components': public_view_types minus supporting_views")
    put("components_and_modifiers", len(standalone) + len(presentation),
        "alternative wording 'components and overlays/modifiers': components_standalone + modifiers_presentation")
    put("supporting_views", len(supporting), "popup building blocks/infrastructure: " + ", ".join(SUPPORTING_VIEWS))
    put("modifiers_presentation", len(presentation), "distinct public View funcs df* that are not style/theme setters")
    put("modifiers_style_setters", len(style_setters), "distinct public View funcs df*Style")
    put("modifiers_theme", len(theme_mods), "dfTheme + dfThemePreset")
    put("style_protocols", len(proto), "public protocols named DF*Style")
    put("style_structs", sum(len(r["structs"]) for r in style_rows.values()),
        "public structs conforming to a DF*Style protocol (excl. Any* erasers)")
    put("style_structs_sendable", sum(len(r["sendable_structs"]) for r in style_rows.values()),
        "subset of style_structs that also conform to Sendable")
    put("style_shorthands", sum(len(r["shorthands"]) for r in style_rows.values()),
        "static var/func members of `where Self == X` style extensions")
    put("components_with_glass", len(glass), "style protocols with a .glass shorthand or *Glass* struct")
    put("theme_presets", len(presets), "static presets in DFThemePreset (each has light+dark)")
    put("theme_variants", 2 * len(presets), "theme_presets x (light, dark)")
    put("color_tokens", len(tok["DFColorTokens"]), "stored public `Color` properties of DFColorTokens (the Bool respectsColorScheme is not a color)")
    put("spacing_tokens", len(tok["DFSpacingTokens"]), "stored public properties of DFSpacingTokens")
    put("radius_tokens", len(tok["DFRadiusTokens"]), "stored public properties of DFRadiusTokens")
    put("shadow_levels", len(tok["DFShadowTokens"]), "stored public properties of DFShadowTokens")
    put("typography_scales", len(tok["DFTypographyTokens"]), "stored public properties of DFTypographyTokens")
    put("animation_tokens", len(tok["DFAnimationTokens"]), "stored public properties of DFAnimationTokens")
    put("component_token_structs", len(comp_tok), "public DF*Tokens structs in DFComponentTokens.swift")
    put("component_token_fields", sum(len(v) for v in comp_tok_fields.values()),
        "stored properties across those structs")
    put("component_token_slots", len(comp_container), "stored properties of DFComponentTokens itself")
    put("environment_keys", len(env), "public var df* in extension EnvironmentValues")
    put("validators", len(validators), "public structs conforming to DFFieldValidator")
    for k, v in popup.items():
        put(k + "_count", len(v), "count of " + k + " (list in detail.popup_toast)")
    put("public_types_total", len(m.types), "public struct/class/enum/protocol/actor incl. nested")
    put("source_files", len(files), "Sources/DesignFoundation/**/*.swift excluding *Previews.swift")
    put("tests_static_swift_testing", tests["swift_testing_@Test"], "static count of @Test attributes (not a pass count)")
    put("tests_static_suites", tests["swift_testing_@Suite"], "static count of @Suite attributes")
    put("release_version", changelog_version(root / "CHANGELOG.md"), "newest released heading in CHANGELOG.md (tag must match)")
    put("swift_tools_version", pkg["swift_tools_version"], "first line of Package.swift")
    put("platforms", pkg["platforms_text"], "Package.swift platforms")

    detail = OrderedDict(
        views_by_folder={k: sorted(v) for k, v in sorted(by_folder.items())},
        views_by_folder_counts={k: len(v) for k, v in sorted(by_folder.items())},
        supporting_views=[v.qname for v in supporting],
        modifiers={"presentation": presentation, "style_setters": style_setters, "theme": theme_mods,
                   "overload_counts": dict(sorted(mods.items()))},
        style_protocols=style_rows, components_with_glass=glass, theme_presets=presets, tokens=tok,
        component_tokens=comp_tok_fields, component_token_slots=comp_container,
        environment_keys=env, validators=validators, popup_toast=popup,
        public_types_by_kind=dict(kinds_count),
        tests=tests, package=pkg)

    # check spec: how prose numbers map to facts
    C = canonical
    pop_styles = C["popup_styles_count"]
    spec = [
        {"generic": True, "key": "components_standalone", "noun": r"components?", "canonical": C["components_standalone"],
         "alts": {str(C["public_view_types"]): "all public View types incl. supporting pieces"}},
        {"key": "components_and_modifiers", "noun": r"components and (?:overlays|modifiers|presentation modifiers)",
         "canonical": C["components_and_modifiers"], "alts": {}},
        {"generic": True, "key": "modifiers_presentation", "noun": r"(?:view )?modifiers?", "canonical": C["modifiers_presentation"],
         "alts": {str(C["modifiers_presentation"] + C["modifiers_style_setters"] + C["modifiers_theme"]):
                  "all df* View modifiers"}},
        {"key": "theme_presets", "noun": r"(?:theme )?presets?", "canonical": C["theme_presets"],
         "alts": {str(C["theme_variants"]): "light+dark variants"}},
        {"key": "style_protocols", "noun": r"style protocols?|styleable components?", "canonical": C["style_protocols"], "alts": {}},
        {"key": "popup_styles", "noun": r"popup (?:surface )?styles?", "canonical": pop_styles, "alts": {}},
        {"key": "toast_styles", "noun": r"toast styles?", "canonical": C["toast_styles_count"], "alts": {}},
        {"key": "popup_kinds", "noun": r"popup kinds?", "canonical": C["popup_kinds_count"], "alts": {}},
        {"key": "popup_positions", "noun": r"popup positions?|anchor positions?", "canonical": C["popup_positions_count"], "alts": {}},
        {"key": "popup_transitions", "noun": r"popup transitions?", "canonical": C["popup_transitions_count"], "alts": {}},
        {"key": "popup_backdrops", "noun": r"popup backdrops?|backdrops?", "canonical": C["popup_backdrops_count"], "alts": {}},
        {"generic": True, "key": "validators", "noun": r"(?:built-in )?validators?", "canonical": C["validators"], "alts": {}},
        {"key": "environment_keys", "noun": r"environment (?:keys|values)", "canonical": C["environment_keys"], "alts": {}},
        {"key": "public_types_total", "noun": r"public types", "canonical": C["public_types_total"], "alts": {}},
        {"key": "component_token_structs", "noun": r"component[- ]token (?:structs|types|sets)", "canonical": C["component_token_structs"], "alts": {}},
        {"key": "color_tokens", "noun": r"colou?r tokens|colou?r roles", "canonical": C["color_tokens"], "alts": {}},
        {"key": "spacing_tokens", "noun": r"spacing tokens", "canonical": C["spacing_tokens"], "alts": {}},
        {"key": "radius_tokens", "noun": r"radius tokens", "canonical": C["radius_tokens"], "alts": {}},
        {"key": "typography_scales", "noun": r"typography (?:scales|tokens|styles)|type scales", "canonical": C["typography_scales"], "alts": {}},
        {"key": "shadow_levels", "noun": r"shadow (?:tokens|levels)", "canonical": C["shadow_levels"], "alts": {}},
        {"key": "tests_static", "noun": r"(?:unit )?tests", "canonical": C["tests_static_swift_testing"], "alts": {}},
    ]
    versions = [{"key": "release_version", "canonical": C["release_version"],
                 "regex": r"design-foundation\"?\s*,\s*from:\s*\"(\d+\.\d+\.\d+)\""}]
    return {"package": "DesignFoundation", "canonical": canonical, "version_spec": versions, "definitions": definitions,
            "detail": detail, "check_spec": spec, "_module": m}


def run_tests(root):
    p = subprocess.run(["swift", "test"], cwd=root, capture_output=True, text=True)
    out = p.stdout + p.stderr
    res = {"command": "swift test", "exit_code": p.returncode}
    m = re.findall(r"Test run with (\d+) tests? in (\d+) suites? (passed|failed)", out)
    if m:
        res["swift_testing"] = {"tests": int(m[-1][0]), "suites": int(m[-1][1]), "result": m[-1][2]}
    x = re.findall(r"Executed (\d+) tests?, with (\d+) failures?", out)
    if x:
        res["xctest"] = {"tests": int(x[-1][0]), "failures": int(x[-1][1])}
    res["tail"] = out.strip().split("\n")[-6:]
    return res


def cross_check(root: Path, m):
    p = subprocess.run(["swift", "package", "dump-symbol-graph"], cwd=root, capture_output=True, text=True)
    # the extractor may exit non-zero for the *test* module while the library's graph was written fine
    if not list((root / ".build").rglob(TARGET + ".symbols.json")):
        return {"error": "dump-symbol-graph failed", "tail": (p.stdout + p.stderr).strip().split("\n")[-8:]}
    return symbol_graph_check(root / ".build", TARGET, m)


# ------------------------------------------ output ------------------------------------------
def human(f):
    d = f["detail"]
    out = []
    w = out.append
    w(f"DesignFoundation facts  (Package.swift: swift-tools-version {f['canonical']['swift_tools_version']}, {f['canonical']['platforms']})")
    w("=" * 78)
    w("CANONICAL FIGURES (use these in prose)")
    for k, v in f["canonical"].items():
        w(f"  {k:32} {str(v):>8}   {f['definitions'][k]}")
    w("\nPUBLIC VIEWS BY FOLDER (public_view_types = %d; * = supporting)" % f["canonical"]["public_view_types"])
    for k, v in d["views_by_folder"].items():
        w(f"  {k} ({len(v)}): " + ", ".join(n + ("*" if n in SUPPORTING_VIEWS else "") for n in v))
    w("\nVIEW MODIFIERS")
    w("  presentation/layout (%d): %s" % (len(d["modifiers"]["presentation"]), ", ".join(d["modifiers"]["presentation"])))
    w("  style setters (%d): %s" % (len(d["modifiers"]["style_setters"]), ", ".join(d["modifiers"]["style_setters"])))
    w("  theme (%d): %s" % (len(d["modifiers"]["theme"]), ", ".join(d["modifiers"]["theme"])))
    w("\nSTYLE PROTOCOLS  (structs / shorthands; G = has .glass)")
    for pn, r in d["style_protocols"].items():
        w(f"  {pn:28} structs={len(r['structs']):2} shorthands={len(r['shorthands']):2} {'G' if r['glass'] else ' '}  {', '.join(r['shorthands'])}")
    w("\nTHEME: presets = " + ", ".join(d["theme_presets"]))
    for k, v in d["tokens"].items():
        w(f"  {k} ({len(v)}): {', '.join(v)}")
    w("  component tokens: " + ", ".join(f"{k}({len(v)})" for k, v in d["component_tokens"].items()))
    w("\nENVIRONMENT KEYS (%d): %s" % (len(d["environment_keys"]), ", ".join(d["environment_keys"])))
    w("VALIDATORS (%d): %s" % (len(d["validators"]), ", ".join(d["validators"])))
    w("\nPOPUP / TOAST SURFACE")
    for k, v in d["popup_toast"].items():
        w(f"  {k} ({len(v)}): {', '.join(v)}")
    w("\nPUBLIC TYPES BY KIND: " + ", ".join(f"{k}={v}" for k, v in d["public_types_by_kind"].items()))
    w("TESTS (static): " + ", ".join(f"{k}={v}" for k, v in d["tests"].items() if k != "files"))
    if f.get("runtime_tests"):
        w("TESTS (runtime, `%s`): %s" % (f["runtime_tests"]["command"], json.dumps({k: v for k, v in f["runtime_tests"].items() if k != "tail"})))
    w("\nAMBIGUITIES / ALTERNATIVE COUNTS")
    c = f["canonical"]
    w(f"  components: {c['components_standalone']} canonical (standalone Views); {c['public_view_types']} if supporting pieces are counted.")
    w(f"  components + presentation modifiers together: {c['components_and_modifiers']} (only valid if the sentence says 'components and modifiers/overlays').")
    w(f"  modifiers: {c['modifiers_presentation']} presentation/layout; {c['modifiers_presentation'] + c['modifiers_style_setters'] + c['modifiers_theme']} counting style + theme setters too.")
    w(f"  presets: {c['theme_presets']} (each with light+dark = {c['theme_variants']} DFTheme values).")
    return "\n".join(out)


def markdown(f):
    rows = ["| Fact | Value | Definition |", "|---|---|---|"]
    for k, v in f["canonical"].items():
        rows.append(f"| `{k}` | {v} | {f['definitions'][k]} |")
    return "\n".join(rows)


def _swift_str(s):
    return '"' + str(s).replace("\\", "\\\\").replace('"', '\\"') + '"'


def swift_source(f, root):
    """Deterministic Swift constants file for sample apps (--swift). Only values computed above."""
    C = f["canonical"]
    lic = (root / "LICENSE").read_text().splitlines()[0].strip() if (root / "LICENSE").exists() else ""
    license_id = "MIT" if lic.startswith("MIT") else lic
    tools_major = C["swift_tools_version"].split(".")[0]
    ints = [
        ("components", C["components_standalone"], "public View types minus supporting views"),
        ("themePresets", C["theme_presets"], "DFThemePreset cases"),
        ("popupStyles", C["popup_styles_count"], "popup surface styles"),
        ("toastStyles", C["toast_styles_count"], "toast styles"),
        ("toastSeverities", C["toast_severities_count"], "toast severities"),
        ("popupPositions", C["popup_positions_count"], "popup positions"),
    ]
    L = [
        "// GENERATED by scripts/count_facts.py --swift — do not edit.",
        "// Source: Sources/ of the DesignFoundation package (facts derived from code).",
        "enum DFFreeFacts {",
    ]
    for name, val, doc in ints:
        L.append("    /// %s" % doc)
        L.append("    static let %s = %d" % (name, val))
    L += [
        "    /// newest released heading in CHANGELOG.md",
        "    static let releaseVersion = %s" % _swift_str(C["release_version"]),
        "    /// major of swift-tools-version in Package.swift",
        "    static let swiftMajor = %s" % _swift_str(tools_major),
        "    static let platforms = %s" % _swift_str(C["platforms"]),
        "    /// first line of LICENSE",
        "    static let license = %s" % _swift_str(license_id),
        "    /// every integer token above (and version/platform digits), for guard tests",
        "    static let numericTokens: Set<String> = [%s]" % ", ".join(
            _swift_str(t) for t in sorted(set(
                [str(v) for _, v, _ in ints] + re.findall(r"\d+", C["release_version"] + " " + C["platforms"] + " " + tools_major)))),
        "}",
        "",
    ]
    return "\n".join(L)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[1], add_help=True)
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--markdown", action="store_true")
    ap.add_argument("--swift", action="store_true", help="print a generated Swift constants file (for sample apps)")
    ap.add_argument("--check", nargs="+", metavar="FILE")
    ap.add_argument("--strict", action="store_true")
    ap.add_argument("--facts-other", metavar="JSON", help="the other package's --json output")
    ap.add_argument("--cross-check", action="store_true")
    ap.add_argument("--run-tests", action="store_true")
    ap.add_argument("--root", default=None, help="repo root (default: parent of this script's directory)")
    a = ap.parse_args(argv)
    root = Path(a.root) if a.root else Path(__file__).resolve().parent.parent
    f = compute(root)
    m = f.pop("_module")
    if a.run_tests:
        f["runtime_tests"] = run_tests(root)
    if a.cross_check:
        f["compiler_cross_check"] = cross_check(root, m)
    if a.check:
        entries = list(f["check_spec"])
        skipped_note = ""
        if a.facts_other:
            entries += json.loads(Path(a.facts_other).read_text()).get("check_spec", [])
        else:
            entries += [dict(e, unverifiable=True) for e in OTHER_PACKAGE_SPEC]
        versions = list(f["version_spec"]) + (json.loads(Path(a.facts_other).read_text()).get("version_spec", []) if a.facts_other else [])
        results = check_files(a.check, [e for e in entries if not e.get("unverifiable")], a.strict, versions)
        return report_check(results, a.strict)
    if a.swift:
        sys.stdout.write(swift_source(f, root))
        return 0
    if a.json:
        print(json.dumps(f, indent=2, sort_keys=False))
    elif a.markdown:
        print(markdown(f))
    else:
        print(human(f))
        if a.cross_check:
            print("\nCOMPILER CROSS-CHECK\n" + json.dumps(f["compiler_cross_check"], indent=2))
    return 0


OTHER_PACKAGE_SPEC = []  # Pro-owned claims are only verified when --facts-other is given

if __name__ == "__main__":
    sys.exit(main())
