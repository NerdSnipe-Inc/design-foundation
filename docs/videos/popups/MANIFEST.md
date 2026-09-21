# Popup lab recordings

Real screen recordings of the Popup Lab (DFPlayground) in the iOS 26.5 Simulator (iPhone 17 Pro), driven by XCUITest taps and drags. Nothing is synthesized. Each clip has a `<name>-poster.png`. Stills live in `docs/images/popups/`.

Clip files are `<tier>-<what>-<preset>-<light|dark>.mp4` (h264, yuv420p, 390 px wide, 30 fps, no audio). Launch args: `-demo <id> -preset <p> -appearance <light|dark>`; taps come from `DFPlayground/UITests`.

| file | shows | demo id | API |
|---|---|---|---|
| free-auto-dismiss-toast-sage-dark.mp4 | Toast auto-dismisses without touch | popups-free | DFPopupConfiguration.toast(position:) autoDismissAfter |
| free-backdrop-blur-aurora-light.mp4 | Backdrop option on a centered popup | popups-free (Backdrop picker) | DFPopupConfiguration(backdrop: DFPopupBackdrop.none/.dim/.blur) |
| free-backdrop-dim-slate-dark.mp4 | Backdrop option on a centered popup | popups-free (Backdrop picker) | DFPopupConfiguration(backdrop: DFPopupBackdrop.none/.dim/.blur) |
| free-backdrop-none-sage-light.mp4 | Backdrop option on a centered popup | popups-free (Backdrop picker) | DFPopupConfiguration(backdrop: DFPopupBackdrop.none/.dim/.blur) |
| free-card-delete-confirm-slate-light.mp4 | Delete confirmation, tap Delete, Undo toast, tap Undo | popups-gallery (popup.gallery.delete) | .dfPopup(isPresented:) + DFPopupCard(iconTint: .severity(.error), primaryAction: DFPopupAction(role: .destructive)); DFToastQueue.show(actionTitle:action:) |
| free-card-permission-three-actions-sage-light.mp4 | Permission card with three actions | popups-gallery (popup.gallery.permission) | DFPopupCard(primaryAction:secondaryAction:tertiaryAction:), .dfPopupStyle(.frosted) |
| free-card-promo-gradient-hero-garnet-light.mp4 | Promo card with gradient hero media | popups-gallery (popup.gallery.promo) | DFPopupCard with hero media + content slot |
| free-card-upgrade-aurora-dark.mp4 | Upgrade card with feature list | popups-gallery (popup.gallery.upgrade) | DFPopupCard(icon:title:message:primaryAction:secondaryAction:onClose:) with content builder |
| free-dismiss-drag-floater-copper-dark.mp4 | Drag floater: 35pt snaps back, 160pt dismisses | popups-free | DFPopupConfiguration.floater(...) dismissOnDrag: true |
| free-dismiss-tap-and-outside-slate-light.mp4 | Dismiss by tapping the popup, then by tapping outside | popups-free | DFPopupConfiguration(dismissOnTap:dismissOnOutsideTap:) |
| free-item-bound-swap-garnet-light.mp4 | Item-bound popup content swap | popups-item | .dfPopup(item:configuration:) |
| free-positions-card-sage-dark.mp4 | All nine positions in turn (top-leading ... bottom-trailing) | popups-positions | DFPopupPosition; DFToastQueue.show(position:); DFPopupConfiguration.floater(position:); DFPopupConfiguration(kind: .center, position:) |
| free-positions-floater-copper-light.mp4 | All nine positions in turn (top-leading ... bottom-trailing) | popups-positions | DFPopupPosition; DFToastQueue.show(position:); DFPopupConfiguration.floater(position:); DFPopupConfiguration(kind: .center, position:) |
| free-positions-toast-aurora-light.mp4 | All nine positions in turn (top-leading ... bottom-trailing) | popups-positions | DFPopupPosition; DFToastQueue.show(position:); DFPopupConfiguration.floater(position:); DFPopupConfiguration(kind: .center, position:) |
| free-sheet-share-drag-dismiss-copper-light.mp4 | Share sheet: small drag snaps back, large drag dismisses | popups-gallery (popup.gallery.share) | .dfPopup(isPresented:configuration: .sheet(backdrop: .dim)) |
| free-style-wall-aurora-light.mp4 | Same DFPopupCard presented in all 8 surface styles (standard, frosted, glass, accent, gradient, inverse, outlined, tinted); tap tile, hold, Not now | popups-style-wall | .dfPopupStyle(_:) with DFStandardPopupStyle/DFFrostedPopupStyle/DFGlassPopupStyle/DFAccentPopupStyle/DFGradientPopupStyle/DFInversePopupStyle/DFOutlinedPopupStyle/DFTintedPopupStyle(severity:); DFPopupCard |
| free-style-wall-copper-dark.mp4 | Same DFPopupCard presented in all 8 surface styles (standard, frosted, glass, accent, gradient, inverse, outlined, tinted); tap tile, hold, Not now | popups-style-wall | .dfPopupStyle(_:) with DFStandardPopupStyle/DFFrostedPopupStyle/DFGlassPopupStyle/DFAccentPopupStyle/DFGradientPopupStyle/DFInversePopupStyle/DFOutlinedPopupStyle/DFTintedPopupStyle(severity:); DFPopupCard |
| free-theme-tour-all-presets.mp4 | Auto-cycling Theme Tour: 5 presets, light+dark, 11 scenes (~22 s) | popups-tour (tap popup.tour.start; launch arg -pace 0.4) | .dfThemePreset / DFTheme; popups, toasts across presets |
| free-toast-banner-compact-sage-light.mp4 | Banner and compact toast styles | popups-gallery (toast-banner, toast-compact) | .dfToastStyle(.banner), .dfToastStyle(.compact) |
| free-toast-matrix-aurora-light.mp4 | Toast styles x severities, each fired by a real tap | popups-toast-matrix | DFToastQueue.show(text:icon:duration:severity:position:title:actionTitle:action:) with .dfToastStyle(.default/.tinted/.filled/.inverse/.frosted/.glass/.banner/.compact) |
| free-toast-matrix-copper-dark.mp4 | Toast styles x severities, each fired by a real tap | popups-toast-matrix | DFToastQueue.show(text:icon:duration:severity:position:title:actionTitle:action:) with .dfToastStyle(.default/.tinted/.filled/.inverse/.frosted/.glass/.banner/.compact) |
| free-toast-queue-burst-aurora-light.mp4 | Four toasts queue and show one at a time | popups-gallery (toast-burst) | DFToastQueue.show x4 |
| free-toast-queue-severities-garnet-dark.mp4 | Severity queue (success, info, warning, error) | popups-toasts (popup.toast.all) | DFToastQueue.show(severity:) |
| free-toast-undo-action-slate-dark.mp4 | Undo toast with action, tap Undo | popups-gallery (toast-undo) | .dfToastStyle(.inverse); DFToastQueue.show(actionTitle: "Undo", action:) |
| free-tokens-live-sliders-aurora-light.mp4 | Token sliders (cornerRadius, padding, maxWidth) applied to the live popup | popups-tokens | theme.components.popup = DFPopupTokens(cornerRadius:padding:maxWidth:backdropOpacity:) |
| free-transition-asymmetric-copper-dark.mp4 | Popup transition, presented twice | popups-free (Floater, bottom, Transition picker) | DFPopupConfiguration(transition:) DFPopupTransition .slide/.scale/.fade/.none/.asymmetric |
| free-transition-fade-sage-light.mp4 | Popup transition, presented twice | popups-free (Floater, bottom, Transition picker) | DFPopupConfiguration(transition:) DFPopupTransition .slide/.scale/.fade/.none/.asymmetric |
| free-transition-none-garnet-light.mp4 | Popup transition, presented twice | popups-free (Floater, bottom, Transition picker) | DFPopupConfiguration(transition:) DFPopupTransition .slide/.scale/.fade/.none/.asymmetric |
| free-transition-scale-aurora-dark.mp4 | Popup transition, presented twice | popups-free (Floater, bottom, Transition picker) | DFPopupConfiguration(transition:) DFPopupTransition .slide/.scale/.fade/.none/.asymmetric |
| free-transition-slide-slate-light.mp4 | Popup transition, presented twice | popups-free (Floater, bottom, Transition picker) | DFPopupConfiguration(transition:) DFPopupTransition .slide/.scale/.fade/.none/.asymmetric |
| pro-action-popup-center-slate-light.mp4 | Action popup, centered | popups-pro-gallery (action-center) | .dfActionPopup(isPresented:actions:anchor: .center) |
| pro-action-popup-sheet-sage-dark.mp4 | Action popup as action sheet | popups-pro-gallery (action-sheet) | .dfActionPopup(anchor: .bottom) |
| pro-celebration-confetti-aurora-light.mp4 | Celebration with confetti burst | popups-pro-gallery (popup.pro.celebrate) | .dfCelebrationPopup(isPresented:title:message:actionTitle:) |
| pro-celebration-confetti-garnet-dark.mp4 | Celebration with confetti burst | popups-pro-gallery (popup.pro.celebrate) | .dfCelebrationPopup(isPresented:title:message:actionTitle:) |
| pro-center-dedupe-sage-light.mp4 | Same id re-presented updates in place | popups-pro-center (dedupScripted) | DFPopupCenter.present(id:) |
| pro-center-priority-preemption-slate-dark.mp4 | Critical popup preempts a low one; low returns | popups-pro-center (preempt) | DFPopupCenter.present(id:priority:configuration:); .dfPopupCenter(_:) |
| pro-center-queue-all-copper-light.mp4 | All four priorities queued; inspector | popups-pro-center (all) | DFPopupCenter priorities |
| pro-coachmark-tour-copper-dark.mp4 | Coachmark tour through 4 steps, Next x3, Done | popups-pro-gallery (coachmark-tour) | DFCoachmarkTour + .dfCoachmarkTour(_:) + .dfPopupAnchor(_:) |
| pro-consent-sheet-toggles-slate-light.mp4 | Consent sheet toggles, Save choices | popups-pro-gallery (consent) | .dfConsentSheet(isPresented:categories:onSave:) |
| pro-countdown-bar-sage-light.mp4 | Countdown bar and ring | popups-pro-extras | DFPopupCountdownBar, DFPopupCountdownRing, autoDismissAfter |
| pro-input-popup-keyboard-aurora-dark.mp4 | Input popup, keyboard rises, type, Save | popups-pro-gallery (input) | .dfInputPopup(isPresented:title:initialText:validators:onSubmit:) |
| pro-live-capsule-expand-slate-light.mp4 | Live capsule expand / collapse / Stop | popups-pro-gallery (capsule) | .dfLiveCapsule(isPresented:isExpanded:label:leading:trailing:expanded:) |
| pro-motion-enter-exit-edges-garnet-light.mp4 | Independent enter and exit edges | popups-pro-motion | DFPopupConfiguration.motion(_:enterFrom:exitTo:) |
| pro-motion-presets-snappy-bouncy-gentle-aurora-dark.mp4 | Snappy, Bouncy, Gentle floaters | popups-pro-motion | DFPopupConfiguration.motion(_:enterFrom:exitTo:) presets |
| pro-motion-zoom-drop-elastic-sage-dark.mp4 | Zoom, drop, elastic choreographies | popups-pro-motion | .dfPopupPresentation(motion: .zoom/.drop/.elastic) |
| pro-motion-zoomout-slidefade-copper-light.mp4 | ZoomOut and slideFade | popups-pro-motion | .dfPopupPresentation(motion: .zoomOut/.slideFade) |
| pro-notification-banners-swipe-slate-dark.mp4 | Banner stack, swipe each up to dismiss | popups-pro-gallery (banners) | .dfNotificationBanners(items:) DFNotificationBannerItem |
| pro-pause-on-hold-countdown-aurora-dark.mp4 | Press-and-hold freezes the countdown | popups-pro-extras | .dfPopupPresentation(pausesOnHold: true) |
| pro-permission-prompt-sage-light.mp4 | Permission prompt, tap Turn on notifications | popups-pro-gallery (permission) | .dfPermissionPrompt(isPresented:kind: .notifications) |
| pro-progress-toast-failure-retry-garnet-dark.mp4 | Progress to failure, tap Retry, then success | popups-pro-gallery (progress-fail) | .dfProgressToast(state: .failure, onRetry:) |
| pro-progress-toast-success-sage-light.mp4 | Progress ring morphs to success | popups-pro-gallery (progress) | .dfProgressToast(isPresented:state: .progress -> .success) |
| pro-promo-popup-garnet-light.mp4 | Promo popup | popups-pro-gallery (promo) | .dfPromoPopup(isPresented:badge:media:title:message:actionTitle:secondaryTitle:) |
| pro-rating-stars-feedback-aurora-light.mp4 | 2 stars, Submit, private feedback step, Skip | popups-pro-gallery (rating) | .dfRatingPrompt(isPresented:appName:onSubmit:onRequestReview:) |
| pro-rating-stars-review-copper-dark.mp4 | 5 stars, Submit, App Store review nudge | popups-pro-gallery (rating) | .dfRatingPrompt |
| pro-scrim-blur-keyboard-copper-light.mp4 | Blur scrim, keyboard avoidance | popups-pro-extras (scrim blur) | .dfPopupPresentation(keyboard: .avoid, scrim: .blur(0.7)) |
| pro-scroll-popup-bottom-handoff-aurora-light.mp4 | Scroll then drag-dismiss handoff | popups-pro-scroll (bottom) | .dfScrollPopup(isPresented:headerStyle: .centered, header:content:footer:) |
| pro-scroll-popup-detents-sage-light.mp4 | Detents: drag up to grow, down to shrink and dismiss | popups-pro-scroll (detents) | .dfScrollPopup(detents: [.medium, .large]) |
| pro-scroll-popup-from-top-copper-dark.mp4 | Scroll popup from top, drag up to dismiss | popups-pro-scroll (top) | .dfScrollPopup(fromTop: true) |
| pro-scroll-popup-prominent-blur-garnet-dark.mp4 | Prominent header, blur scrim | popups-pro-scroll (prominent) | .dfScrollPopup(headerStyle: .prominent, scrim: .blur(0.5)) |
| pro-undo-toast-bar-expires-sage-dark.mp4 | Undo toast bar drains and expires | popups-pro-gallery (undo-bar) | .dfUndoToast(indicator: .bar) |
| pro-undo-toast-ring-hold-copper-light.mp4 | Undo toast ring; press-and-hold pauses countdown; tap Undo | popups-pro-gallery (undo) | .dfUndoToast(isPresented:message:duration:indicator: .ring, onUndo:onExpire:) |
| pro-window-popup-above-sheet-aurora-light.mp4 | Window popup above a sheet, then window toast | popups-pro-window | .dfPopupWindow(isPresented:configuration:) |

## Stills (docs/images/popups)

`style-<style>-<preset>-<mode>.jpg` (8 popup styles, aurora light + copper dark), `toast-<style>-success-<preset>-<mode>.jpg`, `toast-tinted-<severity>-slate-light.jpg`, `position-<toast|floater|card>-<slug>-aurora-light.jpg` (27), `card-*` and `sheet-share-copper-light.jpg`, `pro-*` (celebration, promo, permission, rating, consent, banners, undo ring/bar, input, action center/sheet, capsule, progress), `window-*`, `countdown-bar-sage-light.jpg`, `tokens-default-aurora-light.jpg`.

## Regenerate

```sh
cd /Users/nerdsnipe/Projects/DFPlayground
UDID=<sim> RAW=build/popup-raw SHOTS=build/popup-shots DD=build/dd Scripts/record-popups.sh                       # all clips
Scripts/record-popups.sh FreePopupClips/testStyleWallAuroraLight ProPopupClips  # subset
Scripts/encode-popups.sh build/popup-raw ../DesignFoundation/docs/videos/popups
```

Not captured: haptics (the simulator does not produce them), the macOS window path, and the anchored action popup (`popup.pro.action-anchor` did not show its popup in the recording, dropped).
