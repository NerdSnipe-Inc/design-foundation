# DesignFoundation — Product Roadmap

**Last updated:** 2026-06-28
**Status:** Pre-launch / Active development

---

## Strategic North Star

DesignFoundation's commercial viability does not live in the component primitives. It lives in the **screens and blocks layer** — the pre-built, drop-in UI that saves a founding team two weeks of work they don't have. Everything before that layer is infrastructure. Everything after it is the product.

The model that wins at this layer in developer tooling:

> **Open-source the foundation. Charge for the output.**

Primitives build reputation and drive discovery. Blocks and screens generate revenue. The two feed each other.

---

## The Buyer

**Primary target:** 2–4 person founding team building a SaaS, B2B tool, or internal platform with an iOS/macOS component. They need to ship fast. They don't have a dedicated designer. They will pay real money to not think about UI.

**Not the target (yet):**
- Solo indie devs building consumer apps — too price-sensitive, expect free
- Large enterprises — they have their own design systems and procurement friction
- UIKit shops — wrong stack, wrong mindset

**The unlock signal:** A buyer who thinks "I need three of those screens by end of sprint" the moment they see the demo. If they need to be convinced they have a problem, they're not the buyer.

---

## Phase 0 — Stabilize the Foundation
**Status: In progress**
**Goal: Production-ready primitives, no rough edges**

The current component library is architecturally sound. Before anything else ships, the foundation needs to be stable enough that developers trust it won't break under them.

### Checklist
- [ ] All primitives compile clean under Swift 6 strict concurrency, zero warnings
- [ ] iOS 18, macOS 15, visionOS 2 — all tested on device, not just Simulator
- [ ] Every component has Preview coverage for all built-in style variants
- [ ] `DFValidationState` wired and tested across all input components
- [ ] Liquid Glass variants confirmed on physical iOS 26 / macOS 26 hardware
- [ ] `DFPlatformVariant` behavior verified: compact, expanded, immersive
- [ ] CHANGELOG started — every change tracked from this point forward

### Platform note
The iOS 18 minimum is a real constraint today. Roughly 30–40% of professional apps still support iOS 15 or 16 due to enterprise, healthcare, and financial requirements. This improves naturally as time passes — do not lower the floor to chase those buyers. The Swift 6 and Liquid Glass investment only pays off at iOS 18+. Stay the course; the market will catch up.

---

## Phase 1 — Open Source the Primitives
**Target: Q3 2026**
**Goal: Build reputation, drive organic discovery, establish credibility**

### What to release
The complete primitives layer as published on GitHub under MIT license:
- Core theming engine (`DFTheme`, all token types)
- All primitive components (Button, Text, Icon, Badge, Avatar, Divider)
- All input components (TextField, SecureField, Toggle, Slider, Picker, DatePicker)
- Card layout component
- All overlay components (Modal, Sheet, Popover, Tooltip)
- All built-in style variants including Liquid Glass

### Why open-source and not charge for it
The developers who will pay for the blocks layer need to trust the foundation first. Open-sourcing removes the risk objection entirely. Every star on GitHub, every Reddit post, every "I use DesignFoundation" in a Swift forum thread is earned marketing that a paid primitives tier cannot buy.

The ShadCN playbook is instructive: free components, massive community, enormous reputation — which makes every paid extension they build an easy sell.

### Launch activities
- GitHub README with animated GIF showcase of all components across styles
- Submit to Swift Package Index
- Post to r/iOSProgramming, r/SwiftUI, Hacker News (Show HN)
- Submit to Hacking with Swift newsletter and Swift by Sundell
- Write a technical post: "How we built a Swift 6-safe, multi-platform design system" — this is the developer community's currency

### The demo video
This is not optional. A 90-second screen recording showing:
1. SPM install in 20 seconds
2. Theme applied at app root in 5 lines
3. A full settings screen assembled from components in under 2 minutes
4. Brand color swap that updates every component instantly

This video is worth more than any feature documentation. It creates the "I need this" moment. Invest the time to make it excellent.

---

## Phase 2 — Screens & Blocks (The Paid Product)
**Target: Q4 2026**
**Goal: Launch the commercial product**

This is the phase that determines whether DesignFoundation is a viable business or a well-engineered hobby project.

### What "blocks" means
A block is a self-contained, themeable SwiftUI view that represents a complete, recognizable UI pattern. It accepts data via a configuration struct, respects the active `DFTheme`, and is immediately usable in production without modification. Think of it as a screen section, not a component.

### Block categories — launch set

**Dashboard & Analytics**
- Metric stat card (single KPI with trend indicator)
- Metric grid (2x2 and 3x2 layouts)
- Activity feed row and feed container
- Chart placeholder card (integrates with Swift Charts)
- Progress ring and linear progress block
- Notification badge block

**Authentication Screens**
- Sign in (email + password, social auth buttons)
- Sign up (multi-field with validation)
- Forgot password
- OTP / 2FA confirmation
- Welcome / splash

**Onboarding Flows**
- Feature highlight carousel
- Permission request screens (camera, notifications, location)
- Plan selection / pricing screen
- Success / completion confirmation

**Settings & Account**
- Profile header block
- Settings list section with grouped rows
- Account / subscription block
- Notification preferences block
- Danger zone block (destructive actions)

**Lists & Detail**
- Contact / user row
- Message / notification cell
- Search results list
- Empty state block (with icon, headline, CTA)
- Loading skeleton (matches the shape of common block layouts)

**Forms**
- Multi-step form container with progress indicator
- Address entry block
- Date range picker block
- Tag / chip selection block

### Technical contract for every block
- Accepts a `Configuration` struct with typed, documented properties
- All colors, typography, spacing, and radius driven by `DFTheme` — zero hardcoded values
- Previews for light, dark, and Liquid Glass variants
- Accessibility labels and traits wired by default
- No external dependencies beyond DesignFoundation itself

---

## Phase 3 — Ecosystem Expansion
**Target: 2027**
**Goal: Deepen stickiness, expand the addressable market**

Once the blocks library has traction, the natural extensions are:

### Figma Kit
A Figma component library that mirrors the Swift components — same token names, same style variants, same naming conventions. Designers and developers share a vocabulary. This is a strong conversion driver: designers discover the Figma kit, developers get handed a spec that maps directly to the Swift components.

Price separately or bundle with the blocks license.

### Code Generation
A Swift macro or Xcode source extension that generates a themed component from a Figma token export. Removes the manual sync step between design and code. High value, high complexity — plan for late 2027 at earliest.

### Additional Platform Targets
- **tvOS** — same component library, expanded form factor
- **watchOS** — subset of primitives adapted to the constraints

### Theme Marketplace
A gallery of community-contributed `DFTheme` presets — each a complete visual language (color, typography, radius, shadows) that applies to the entire component and blocks library with one line. Revenue share with contributors, or curated free themes as an acquisition driver.

---

## Pricing Strategy

### The numbers

| Product | Price | Notes |
|---|---|---|
| Primitives | Free / OSS | MIT license on GitHub |
| Blocks Library — Individual | $149 one-time | Per developer, unlimited projects |
| Blocks Library — Team (up to 5) | $449 one-time | Flat team license, no per-seat friction |
| Annual Update Subscription | $39/year | Optional after year 1; covers OS updates, new blocks |
| Figma Kit | $49 one-time | Standalone or bundle with blocks |
| Bundle (Blocks + Figma) | $179 one-time | Slight discount to drive upsell |

### Why these numbers

**$149 for blocks** is the impulse-buy ceiling for developer tooling. It is below the "I need to think about this" threshold for most professional developers, above the "this can't be serious" threshold, and consistent with what the market has validated for similar products (Tailwind UI launched at $149). At $99 you leave money on the table and signal low quality. At $199 you need to work harder to justify the spend.

**One-time purchase, not subscription** for the initial launch. Developers have subscription fatigue and resist recurring charges for tools they'll use heavily for 6 months and then have running in the background. Build the subscription expectation with the *update* tier, not the base product.

**$39/year updates** is the retention and recurring revenue lever. Frame it as platform currency — "every September Apple ships a new OS; this is how we keep the library current." Make the value concrete: "iOS 19 support, visionOS 3 updates, 4 new block categories per year." This converts well when people trust the product because they've shipped something with it.

**Flat team license** at $449 converts better than per-seat at any price. Teams don't want to track who has a license. Remove the friction.

### What not to do
- Do not gate the primitives behind a license. It will kill the community before it starts.
- Do not charge monthly for the base product before you have proven retention. Monthly implies ongoing value delivery you aren't yet set up to demonstrate.
- Do not price below $99 for blocks. Cheap signals low quality to developers who are evaluating risk.

---

## Maintenance & Sustainability

This is the question every serious buyer will ask and most developer tool products fail to answer convincingly.

### The September problem
Apple ships a major OS release every September. SwiftUI has had breaking changes in every major version since its launch. Liquid Glass is new in 2026. Something new will break in 2027. Buyers need to believe that when it breaks, you'll fix it.

### What to commit to publicly
- **OS compatibility updates within 30 days of major OS release.** This is the minimum bar. Missing a new iOS release for 60+ days is a product-ending event for this type of library.
- **A public CHANGELOG** with dates. Not a marketing blog post — a real changelog that shows a commit cadence.
- **A GitHub Issues process.** Bugs reported and acknowledged within 72 hours, fixed within 2 weeks for blockers. This signals the project is alive.
- **A versioning policy.** Semantic versioning with a documented deprecation path. Developers will not adopt a library that has a reputation for silent breaking changes.

### Bus factor planning
If one person maintains this, that is existential risk for buyers considering a dependency. Eventually: document the architecture thoroughly enough that a second contributor could take over. Treat the codebase as if you might hand it off tomorrow.

---

## Revenue Projections (Realistic)

These numbers assume good execution, not perfect execution. They assume the OSS strategy drives discovery and the blocks library converts 2–3% of engaged users.

| Period | Scenario | Revenue |
|---|---|---|
| Launch (months 1–3) | Blocks launch, small audience | $5k–15k |
| Year 1 | Growing OSS community, blocks sales | $25k–65k |
| Year 2 | Established reputation, update subs | $65k–150k |
| Year 3 | Figma kit, theme marketplace, team licenses | $120k–250k |

**The ceiling without significant expansion** is roughly $200k–250k/year as a solo or two-person operation. This is a strong, sustainable indie business. It is not a venture-scale outcome on its own.

**To move past the ceiling** the product needs to expand from a component library into a development platform — code generation, Figma sync, managed update delivery, or a companion app for browsing and copying blocks. That is a different business, built on this foundation.

---

## The Risks Worth Naming

**Someone open-sources a competitor.** This gap will be filled. The question is whether DesignFoundation fills it first and builds enough reputation that it remains the trusted choice even after free alternatives appear. First-mover advantage in OSS is real but not permanent. Execution speed matters.

**SwiftUI itself becomes the design system.** Apple continues expanding SwiftUI's built-in components and design language. If they ship something close to a theming engine in a future SDK, the primitives layer loses most of its value. The blocks layer still has value because Apple does not ship dashboard screens. Concentrate energy there.

**Maintenance drops off.** The single biggest risk for any developer tool is becoming visibly unmaintained. One missed major OS update will trigger a wave of "is this abandoned?" posts. Treat the September update window as an unmovable deadline from day one.

**The iOS 18 floor stays a constraint longer than expected.** If enterprise adoption lags and the addressable market stays artificially small through 2027, revenue will track low. Watch the iOS adoption curves and reassess the floor only if the blocks phase launch is severely constrained by it — not before.

---

## Immediate Next Actions

In priority order:

1. **Finish Phase 0.** Lock down the component library. No rough edges, no known bugs, Liquid Glass confirmed on hardware. This is the base on which everything else rests.

2. **Write the demo video script.** Even before recording. What does someone build in 90 seconds that makes another developer stop scrolling? Answer that question, then record it.

3. **Set up the GitHub repository for public release.** LICENSE, README with the demo GIF, contribution guidelines, issue templates. This is the storefront.

4. **Define the first 10 blocks.** Not all of Phase 2 — just the first ten that will ship with launch. Prioritize the ones with the highest "I need this by Friday" density: sign-in screen, dashboard stat card, settings list, empty state, activity feed.

5. **Build the first 10 blocks.** The experience of building them will reveal gaps in the primitives layer and sharpen the design of the block API. Build before you document.

6. **Decide on the payment infrastructure.** Gumroad, Lemon Squeezy, or Paddle. All three work for developer tools. Lemon Squeezy has the cleanest DX for this use case. Decide early — don't let it be the thing that delays launch.

---

*This document is a living roadmap. Revisit and update it quarterly or when market signals change.*
