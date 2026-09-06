#!/usr/bin/env python3
"""
Captures a screenshot of every DFPlayground screen/gallery/block/shell/composition
example, frames each into a presentable card, groups them into per-category strip
composites, and writes Content/index.md (this repo) plus a matching
../DesignFoundationPro/Content/index.md for the Pro-tagged entries.

Capture mechanism: DFPlayground already ships headless-automation hooks
(Sources/DFPlayground/AutomationHooks.swift, ContentView.NavItem.fromID) that open
a specific screen/block/shell/app/top-level-tab as its own window when launched with
the right environment variable. This script launches `swift run` once per manifest
entry, brings the window frontmost, reads its on-screen position/size via
AppleScript (System Events), captures exactly that rect with `screencapture -R`,
then kills the process and moves to the next entry.

This drives the REAL, LIVE desktop session — it will raise/lower windows and can be
visibly disruptive while it runs (~115+ launch/capture/kill cycles). Run it only when
you're at the machine and not relying on other foreground windows for ~20-30 minutes.

Usage: python3 scripts/generate_screenshot_catalog.py [--skip-capture]
  --skip-capture   Skip the live capture pass and only re-run framing/index
                    generation from whatever raw PNGs already exist in
                    Content/RawCaptures/ (useful for iterating on the framing
                    style without re-driving the GUI every time).
"""
from __future__ import annotations

import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFilter
except ModuleNotFoundError as error:
    raise SystemExit(
        "scripts/generate_screenshot_catalog.py requires Pillow. "
        "Install it with `python3 -m pip install Pillow`, then rerun."
    ) from error

REPO_ROOT = Path(__file__).resolve().parent.parent
PLAYGROUND_ROOT = REPO_ROOT.parent / "DFPlayground"
PRO_ROOT = REPO_ROOT.parent / "DesignFoundationPro"

RAW_DIR = REPO_ROOT / "Content" / "RawCaptures"
FRAMES_DIR = REPO_ROOT / "Content" / "Frames"
GROUPS_DIR = REPO_ROOT / "Content" / "Groups"
INDEX_FILE = REPO_ROOT / "Content" / "index.md"
PRO_INDEX_FILE = PRO_ROOT / "Content" / "index.md"

FRAME_SUFFIX = ".framed.png"
GROUP_SUFFIX = ".strip.png"
GROUP_ROW_SIZE = 4

LAUNCH_SETTLE_SECONDS = 7.0
ACTIVATE_SETTLE_SECONDS = 1.2
BUILD_TIMEOUT_SECONDS = 120


@dataclass(frozen=True)
class CaptureTarget:
    category: str
    name: str
    env_var: str
    env_value: str
    source_path: str  # repo-relative path shown in the index, for the "source" link
    is_pro: bool = False
    hide_main: bool = False


def _pro_screens() -> list[CaptureTarget]:
    # id -> (display name, source file). Kept in the same order they appear in
    # ScreenFocusView.swift's switch statement.
    ids = [
        ("DFAIChatThreadScreen", "AIChat/DFAIChatThreadScreen.swift"),
        ("DFAIChatNewScreen", "AIChat/DFAIChatNewScreen.swift"),
        ("DFAIChatSettingsSheet", "AIChat/DFAIChatSettingsSheet.swift"),
        ("DFAnalyticsOverviewScreen", "Analytics/DFAnalyticsOverviewScreen.swift"),
        ("DFAnalyticsEventsScreen", "Analytics/DFAnalyticsEventsScreen.swift"),
        ("DFAnalyticsRevenueScreen", "Analytics/DFAnalyticsRevenueScreen.swift"),
        ("DFAnalyticsUsersScreen", "Analytics/DFAnalyticsUsersScreen.swift"),
        ("DFCRMHomeScreen", "CRM/DFCRMHomeScreen.swift"),
        ("DFCRMContactsScreen", "CRM/DFCRMContactsScreen.swift"),
        ("DFCRMContactDetailScreen", "CRM/DFCRMContactDetailScreen.swift"),
        ("DFCRMPipelineScreen", "CRM/DFCRMPipelineScreen.swift"),
        ("DFCRMDealDetailScreen", "CRM/DFCRMDealDetailScreen.swift"),
        ("DFCRMAnalyticsScreen", "CRM/DFCRMAnalyticsScreen.swift"),
        ("DFDocumentBrowserScreen", "Documents/DFDocumentBrowserScreen.swift"),
        ("DFDocumentEditorScreen", "Documents/DFDocumentEditorScreen.swift"),
        ("DFDocumentSearchScreen", "Documents/DFDocumentSearchScreen.swift"),
        ("DFEcommerceStoreHomeScreen", "Ecommerce/StoreHome/DFEcommerceStoreHomeScreen.swift"),
        ("DFEcommerceOrdersScreen", "Ecommerce/Orders/DFEcommerceOrdersScreen.swift"),
        ("DFEcommerceOrderDetailScreen", "Ecommerce/OrderDetail/DFEcommerceOrderDetailScreen.swift"),
        ("DFEcommerceProductsScreen", "Ecommerce/Products/DFEcommerceProductsScreen.swift"),
        ("DFEcommerceRevenueScreen", "Ecommerce/Revenue/DFEcommerceRevenueScreen.swift"),
        ("DFOnboardingFlow", "Onboarding/DFOnboardingFlow.swift"),
        ("DFPMHomeScreen", "ProjectManager/DFPMHomeScreen.swift"),
        ("DFPMBoardScreen", "ProjectManager/DFPMBoardScreen.swift"),
        ("DFPMListScreen", "ProjectManager/DFPMListScreen.swift"),
        ("DFPMTimelineScreen", "ProjectManager/DFPMTimelineScreen.swift"),
        ("DFPMTeamScreen", "ProjectManager/DFPMTeamScreen.swift"),
        ("DFPMTaskDetailScreen", "ProjectManager/DFPMTaskDetailScreen.swift"),
        ("DFSettingsAccountScreen", "Settings/DFSettingsAccountScreen.swift"),
        ("DFSettingsBillingScreen", "Settings/DFSettingsBillingScreen.swift"),
        ("DFSettingsSecurityScreen", "Settings/DFSettingsSecurityScreen.swift"),
        ("DFSettingsNotificationsScreen", "Settings/DFSettingsNotificationsScreen.swift"),
        ("DFSettingsTeamScreen", "Settings/DFSettingsTeamScreen.swift"),
        ("DFSettingsDangerZoneScreen", "Settings/DFSettingsDangerZoneScreen.swift"),
        ("DFSocialFeedScreen", "Social/Feed/DFSocialFeedScreen.swift"),
        ("DFSocialExploreScreen", "Social/Explore/DFSocialExploreScreen.swift"),
        ("DFSocialNotificationsScreen", "Social/Notifications/DFSocialNotificationsScreen.swift"),
        ("DFSocialProfileScreen", "Social/Profile/DFSocialProfileScreen.swift"),
    ]
    return [
        CaptureTarget("Pro Screens", name, "DFP_SCREEN_ID", name, path, is_pro=True, hide_main=True)
        for name, path in ids
    ]


def _pro_blocks() -> list[CaptureTarget]:
    ids = [
        "DFWelcomeBlock", "DFSignInBlock", "DFSignUpBlock", "DFOTPBlock", "DFForgotPasswordBlock",
        "DFStatCardBlock", "DFMetricGridBlock", "DFProgressRingBlock", "DFLineChartBlock",
        "DFBarChartBlock", "DFDonutChartBlock", "DFChartPlaceholderBlock", "DFFeatureCarouselBlock",
        "DFPermissionRequestBlock", "DFPlanSelectionBlock", "DFSuccessBlock", "DFSettingsSectionBlock",
        "DFAccountBlock", "DFNotificationPreferencesBlock", "DFDangerZoneBlock", "DFActivityFeedBlock",
        "DFEmptyStateBlock", "DFSearchResultsBlock", "DFBlockSkeletonBlock", "DFAddressBlock",
        "DFDateRangeBlock", "DFMultiStepFormBlock", "DFTagPickerBlock", "DFProfileHeaderBlock",
        "DFDataGrid",
    ]
    return [
        CaptureTarget("Pro Blocks", name, "DFP_BLOCK_ID", name, "Blocks/", is_pro=True, hide_main=True)
        for name in ids
    ]


def _shells() -> list[CaptureTarget]:
    ids = [
        "Standard Sidebar", "Dual Sidebar", "Three Column", "Icon Rail", "Inset Sidebar",
        "Search Sidebar", "Calendar Sidebar", "File Tree", "Workspace Sidebar",
        "Expandable Submenu", "Dropdown Submenu", "Popover Sidebar", "Sheet Sidebar",
        "Right Inspector", "Floating Overlay", "Sticky Header", "Nested Dual Column",
        "Adaptive Shell",
    ]
    return [
        CaptureTarget("Shell Layouts", name, "DFP_SHELL_NAME", name, "Shells/", is_pro=True, hide_main=True)
        for name in ids
    ]


def _apps() -> list[CaptureTarget]:
    ids = [
        ("DFCRMRootView", "CRM/DFCRMRootView.swift"),
        ("DFPMRootView", "ProjectManager/DFPMRootView.swift"),
        ("DFSocialAppShell", "Social/Shell/DFSocialAppShell.swift"),
        ("DFOnboardingFlow", "Onboarding/DFOnboardingFlow.swift"),
        ("DFAnalyticsRootView", "Analytics/DFAnalyticsRootView.swift"),
        ("DFSettingsRootView", "Settings/DFSettingsRootView.swift"),
        ("DFEcommerceRootView", "Ecommerce/DFEcommerceRootView.swift"),
        ("DFAIChatRootView", "AIChat/DFAIChatRootView.swift"),
        ("DFDocumentsRootView", "Documents/DFDocumentsRootView.swift"),
        ("DFBookingRootView", "Booking/DFBookingRootView.swift"),
        ("DFFoodRootView", "Food/DFFoodRootView.swift"),
        ("DFNewsRootView", "News/DFNewsRootView.swift"),
    ]
    return [
        CaptureTarget("Composition Examples", name, "DFP_APP_ID", name, path, is_pro=True, hide_main=True)
        for name, path in ids
    ]


def _top_level_tabs() -> list[CaptureTarget]:
    entries = [
        ("Welcome", "Foundation", "Sources/DFPlayground/WelcomeView.swift"),
        ("Buttons", "Foundation", "Sources/DFPlayground/Screens/ButtonsScreen.swift"),
        ("Text & Icons", "Foundation", "Sources/DFPlayground/Screens/TextAndIconsScreen.swift"),
        ("Badges & Avatars", "Foundation", "Sources/DFPlayground/Screens/BadgesAndAvatarsScreen.swift"),
        ("Dividers", "Foundation", "Sources/DFPlayground/Screens/DividersScreen.swift"),
        ("Text Fields", "Foundation", "Sources/DFPlayground/Screens/TextFieldsScreen.swift"),
        ("Controls", "Foundation", "Sources/DFPlayground/Screens/ControlsScreen.swift"),
        ("Progress", "Foundation", "Sources/DFPlayground/Screens/ProgressScreen.swift"),
        ("Alerts & Toasts", "Foundation", "Sources/DFPlayground/Screens/AlertsAndToastsScreen.swift"),
        ("Lists & Tables", "Foundation", "Sources/DFPlayground/Screens/ListsAndTablesScreen.swift"),
        ("Navigation", "Foundation", "Sources/DFPlayground/Screens/NavigationScreen.swift"),
        ("Content & Media", "Foundation", "Sources/DFPlayground/Screens/ContentPrimitivesScreen.swift"),
        ("Forms & Validation", "Foundation", "Sources/DFPlayground/Screens/FormsValidationScreen.swift"),
        ("Data Tables", "Foundation", "Sources/DFPlayground/Screens/DataTablesScreen.swift"),
        ("Pro Blocks", "Pro Index", "Sources/DFPlayground/ProBlocksGalleryView.swift"),
        ("Pro Screens", "Pro Index", "Sources/DFPlayground/ProScreensGalleryView.swift"),
        ("Shell Layouts", "Pro Index", "Sources/DFPlayground/ShellsGalleryView.swift"),
        ("Themes", "Foundation", "Sources/DFPlayground/ThemePickerView.swift"),
        ("Composition Examples", "Pro Index", "Sources/DFPlayground/CompositionExamplesGalleryView.swift"),
    ]
    return [
        CaptureTarget(category, name, "DFP_TAB_ID", name, path, is_pro=(category == "Pro Index"))
        for name, category, path in entries
    ]


def build_manifest() -> list[CaptureTarget]:
    return _top_level_tabs() + _pro_screens() + _pro_blocks() + _shells() + _apps()


def slug(text: str) -> str:
    return "".join(c if c.isalnum() else "-" for c in text).strip("-")


# MARK: - Live capture (drives the real desktop — see module docstring)

def _run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, text=True, **kwargs)


def build_playground_once() -> None:
    print("Building DFPlayground...")
    result = _run(["swift", "build"], cwd=PLAYGROUND_ROOT, timeout=BUILD_TIMEOUT_SECONDS)
    if result.returncode != 0:
        raise SystemExit(f"DFPlayground build failed:\n{result.stdout}\n{result.stderr}")


def capture_target(target: CaptureTarget, binary: Path) -> Path | None:
    env_overrides = {target.env_var: target.env_value}
    if target.hide_main:
        env_overrides["DFP_HIDE_MAIN"] = "1"

    import os
    env = {**os.environ, **env_overrides}

    proc = subprocess.Popen([str(binary)], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    try:
        time.sleep(LAUNCH_SETTLE_SECONDS)
        _run(["osascript", "-e", 'tell application "DFPlayground" to activate'])
        _run(["osascript", "-e",
              'tell application "System Events" to set frontmost of process "DFPlayground" to true'])
        time.sleep(ACTIVATE_SETTLE_SECONDS)

        pos = _run(["osascript", "-e",
                    'tell application "System Events" to tell process "DFPlayground" to get position of window 1'])
        size = _run(["osascript", "-e",
                     'tell application "System Events" to tell process "DFPlayground" to get size of window 1'])
        if pos.returncode != 0 or size.returncode != 0:
            print(f"  SKIP {target.category}/{target.name}: could not read window geometry")
            return None

        x, y = (p.strip() for p in pos.stdout.split(","))
        w, h = (s.strip() for s in size.stdout.split(","))

        out_path = RAW_DIR / f"{slug(target.category)}__{slug(target.name)}.png"
        RAW_DIR.mkdir(parents=True, exist_ok=True)
        capture = _run(["screencapture", f"-R{x},{y},{w},{h}", "-o", str(out_path)])
        if capture.returncode != 0 or not out_path.exists():
            print(f"  SKIP {target.category}/{target.name}: screencapture failed")
            return None
        return out_path
    finally:
        proc.terminate()
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()
        _run(["pkill", "-f", "DFPlayground"])
        time.sleep(0.5)


def run_capture_pass(manifest: list[CaptureTarget]) -> None:
    build_playground_once()
    binary = PLAYGROUND_ROOT / ".build" / "debug" / "DFPlayground"
    if not binary.exists():
        raise SystemExit(f"Expected built binary at {binary}, not found")

    print(f"Capturing {len(manifest)} targets — this drives the live desktop, do not use the machine "
          f"for other foreground work until it finishes.")
    for i, target in enumerate(manifest, 1):
        print(f"[{i}/{len(manifest)}] {target.category} / {target.name}")
        capture_target(target, binary)


# MARK: - Framing + index generation

CARD_PADDING = 24
CARD_BACKGROUND = (24, 24, 27, 255)
CARD_BORDER = (63, 63, 70, 255)
CARD_RADIUS = 20
SHADOW_BLUR = 18
SHADOW_OFFSET = 8


def frame_image(src: Path, dest: Path) -> None:
    shot = Image.open(src).convert("RGBA")
    w, h = shot.size

    canvas_w = w + CARD_PADDING * 2
    canvas_h = h + CARD_PADDING * 2
    shadow_pad = SHADOW_BLUR * 2

    base = Image.new("RGBA", (canvas_w + shadow_pad * 2, canvas_h + shadow_pad * 2), (0, 0, 0, 0))

    # Drop shadow
    shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_box = [
        shadow_pad + SHADOW_OFFSET,
        shadow_pad + SHADOW_OFFSET,
        shadow_pad + canvas_w + SHADOW_OFFSET,
        shadow_pad + canvas_h + SHADOW_OFFSET,
    ]
    shadow_draw.rounded_rectangle(shadow_box, radius=CARD_RADIUS, fill=(0, 0, 0, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(SHADOW_BLUR))
    base = Image.alpha_composite(base, shadow)

    # Card background + border
    card = Image.new("RGBA", base.size, (0, 0, 0, 0))
    card_draw = ImageDraw.Draw(card)
    card_box = [shadow_pad, shadow_pad, shadow_pad + canvas_w, shadow_pad + canvas_h]
    card_draw.rounded_rectangle(card_box, radius=CARD_RADIUS, fill=CARD_BACKGROUND, outline=CARD_BORDER, width=1)
    base = Image.alpha_composite(base, card)

    # Screenshot, corner-clipped to sit inside the card
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w, h], radius=max(CARD_RADIUS - CARD_PADDING, 0), fill=255)
    base.paste(shot, (shadow_pad + CARD_PADDING, shadow_pad + CARD_PADDING), mask)

    dest.parent.mkdir(parents=True, exist_ok=True)
    base.save(dest)


def build_strip(images: list[Path], dest: Path) -> None:
    if not images:
        return
    thumbs = [Image.open(p).convert("RGBA") for p in images]
    thumb_h = 220
    resized = []
    for img in thumbs:
        ratio = thumb_h / img.height
        resized.append(img.resize((max(int(img.width * ratio), 1), thumb_h)))

    rows = [resized[i:i + GROUP_ROW_SIZE] for i in range(0, len(resized), GROUP_ROW_SIZE)]
    row_heights = [thumb_h] * len(rows)
    row_widths = [sum(im.width for im in row) + 16 * (len(row) - 1) for row in rows]

    strip_w = max(row_widths) if row_widths else 0
    strip_h = sum(row_heights) + 16 * (len(rows) - 1)
    strip = Image.new("RGBA", (strip_w, max(strip_h, 1)), (0, 0, 0, 0))

    y = 0
    for row in rows:
        x = 0
        for im in row:
            strip.paste(im, (x, y), im)
            x += im.width + 16
        y += thumb_h + 16

    dest.parent.mkdir(parents=True, exist_ok=True)
    strip.save(dest)


@dataclass
class IndexEntry:
    category: str
    name: str
    frame_path: Path
    source_path: str


def generate_frames_and_index(manifest: list[CaptureTarget]) -> None:
    entries_by_category: dict[str, list[IndexEntry]] = {}
    pro_entries_by_category: dict[str, list[IndexEntry]] = {}

    for target in manifest:
        raw_path = RAW_DIR / f"{slug(target.category)}__{slug(target.name)}.png"
        if not raw_path.exists():
            continue
        frame_path = FRAMES_DIR / f"{slug(target.category)}__{slug(target.name)}{FRAME_SUFFIX}"
        frame_image(raw_path, frame_path)

        entry = IndexEntry(target.category, target.name, frame_path, target.source_path)
        bucket = pro_entries_by_category if target.is_pro else entries_by_category
        bucket.setdefault(target.category, []).append(entry)

    for category, entries in {**entries_by_category, **pro_entries_by_category}.items():
        strip_path = GROUPS_DIR / f"{slug(category)}{GROUP_SUFFIX}"
        build_strip([e.frame_path for e in entries], strip_path)

    write_index(INDEX_FILE, "DesignFoundation", entries_by_category, cross_link_pro=bool(pro_entries_by_category))
    if pro_entries_by_category:
        write_index(PRO_INDEX_FILE, "DesignFoundationPro", pro_entries_by_category, cross_link_pro=False)


def write_index(
    path: Path,
    title: str,
    entries_by_category: dict[str, list[IndexEntry]],
    cross_link_pro: bool,
) -> None:
    lines = [f"# {title} Screenshot Catalog", ""]
    lines.append("Generated by `scripts/generate_screenshot_catalog.py` — do not edit by hand; "
                  "re-run the script instead.")
    lines.append("")
    if cross_link_pro:
        lines.append("Pro-tier entries (Pro Screens, Pro Blocks, Shell Layouts, Composition Examples) "
                      "are cataloged separately in [DesignFoundationPro's own index]"
                      "(../../DesignFoundationPro/Content/index.md).")
        lines.append("")

    for category in sorted(entries_by_category):
        entries = entries_by_category[category]
        lines.append(f"## {category}")
        lines.append("")
        strip_rel = f"Groups/{slug(category)}{GROUP_SUFFIX}"
        lines.append(f"![{category} overview]({strip_rel})")
        lines.append("")
        lines.append("| Preview | Name | Source |")
        lines.append("|---|---|---|")
        for entry in entries:
            frame_rel = f"Frames/{entry.frame_path.name}"
            lines.append(f"| ![{entry.name}]({frame_rel}) | {entry.name} | `{entry.source_path}` |")
        lines.append("")

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines))
    print(f"Wrote {path}")


def main() -> None:
    skip_capture = "--skip-capture" in sys.argv
    manifest = build_manifest()
    if not skip_capture:
        run_capture_pass(manifest)
    generate_frames_and_index(manifest)


if __name__ == "__main__":
    main()
