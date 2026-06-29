# Onboarding Flow — Implementation Plan

**Vertical:** Onboarding Flow  
**Package:** `DesignFoundationScreens`  
**Source root:** `Sources/DesignFoundationScreens/Onboarding/`  
**Test root:** `Tests/DesignFoundationScreensTests/Onboarding/`  
**Status:** ⬜ Not started

---

## Overview

A complete, wired, end-to-end onboarding journey. A developer drops in `DFOnboardingFlow`, configures it with a `DFOnboardingConfiguration`, and gets a fully functional first-run experience with state persistence, back navigation, animated transitions, and completion callbacks.

The flow must feel fast, intentional, and encouraging. It is the only chance to make a first impression — every screen must be launch-ready, not a placeholder.

---

## Flow

```
Welcome
  ├─► Sign Up → OTP → Profile → Features → Permissions (0–N) → Plan? → Personalisation? → Success
  └─► Sign In → Success (skips OTP/Profile/Features)
```

State is persisted to `UserDefaults` (or injected store) so a user who quits mid-flow resumes at the correct step. Progress bar is visible on every step except Welcome and Success.

---

## File Map

```
Sources/DesignFoundationScreens/Onboarding/
├── DFOnboardingFlow.swift                    # Coordinator / container (main deliverable)
├── DFOnboardingConfiguration.swift          # Config struct passed in by developer
├── DFOnboardingStep.swift                   # Step enum + state machine helpers
├── DFOnboardingState.swift                  # @Observable state object
├── DFOnboardingProgressBar.swift            # Thin wrapper: DFProgressBar with step context
│
├── Screens/
│   ├── DFOnboardingWelcomeScreen.swift
│   ├── DFOnboardingSignUpScreen.swift
│   ├── DFOnboardingSignInScreen.swift
│   ├── DFOnboardingOTPScreen.swift
│   ├── DFOnboardingProfileScreen.swift
│   ├── DFOnboardingFeaturesScreen.swift
│   ├── DFOnboardingPermissionsScreen.swift
│   ├── DFOnboardingPlanScreen.swift
│   ├── DFOnboardingPersonalisationScreen.swift
│   └── DFOnboardingSuccessScreen.swift

Tests/DesignFoundationScreensTests/Onboarding/
├── DFOnboardingStepTests.swift              # State machine transitions
├── DFOnboardingStateTests.swift             # Persistence, resume logic
└── DFOnboardingConfigurationTests.swift     # Config validation
```

---

## Task Order

Build bottom-up: data model → coordinator → screens in flow order.

| # | Task | File(s) | Depends on |
|---|---|---|---|
| 1 | Step enum + state machine | `DFOnboardingStep.swift` | — |
| 2 | Configuration struct | `DFOnboardingConfiguration.swift` | Step enum |
| 3 | Observable state object | `DFOnboardingState.swift` | Step + Config |
| 4 | Progress bar wrapper | `DFOnboardingProgressBar.swift` | State |
| 5 | Welcome screen | `DFOnboardingWelcomeScreen.swift` | State |
| 6 | Sign Up screen | `DFOnboardingSignUpScreen.swift` | State |
| 7 | Sign In screen | `DFOnboardingSignInScreen.swift` | State |
| 8 | OTP screen | `DFOnboardingOTPScreen.swift` | State |
| 9 | Profile screen | `DFOnboardingProfileScreen.swift` | State |
| 10 | Features screen | `DFOnboardingFeaturesScreen.swift` | State |
| 11 | Permissions screen | `DFOnboardingPermissionsScreen.swift` | State |
| 12 | Plan screen | `DFOnboardingPlanScreen.swift` | State |
| 13 | Personalisation screen | `DFOnboardingPersonalisationScreen.swift` | State |
| 14 | Success screen | `DFOnboardingSuccessScreen.swift` | State |
| 15 | Coordinator / container | `DFOnboardingFlow.swift` | All screens |
| 16 | Tests | `*Tests.swift` | Coordinator |

---

## Task 1 — `DFOnboardingStep.swift`

The step enum is the state machine. All navigation logic derives from it — no ad-hoc booleans anywhere else.

```swift
// Sources/DesignFoundationScreens/Onboarding/DFOnboardingStep.swift

import Foundation

/// Ordered steps in the onboarding flow.
/// The coordinator drives navigation exclusively from this enum —
/// never from ad-hoc Bool flags.
public enum DFOnboardingStep: String, CaseIterable, Codable, Sendable {
    case welcome
    case signUp
    case signIn          // Branched from welcome; skips OTP/profile/features on success
    case otp
    case profile
    case features
    case permissions     // Repeating: one screen per requested permission
    case plan
    case personalisation
    case success
}

extension DFOnboardingStep {
    /// Steps that show a back button.
    public var allowsBack: Bool {
        switch self {
        case .welcome, .success: false
        default: true
        }
    }

    /// Steps that show the progress bar.
    public var showsProgress: Bool {
        switch self {
        case .welcome, .signIn, .success: false
        default: true
        }
    }

    /// The sign-up path in order (skipping sign-in branch).
    public static let signUpPath: [DFOnboardingStep] = [
        .welcome, .signUp, .otp, .profile, .features, .permissions, .plan, .personalisation, .success
    ]

    /// The sign-in path (abbreviated — skips OTP/profile/features).
    public static let signInPath: [DFOnboardingStep] = [
        .welcome, .signIn, .success
    ]
}
```

---

## Task 2 — `DFOnboardingConfiguration.swift`

Developer-facing config. All customisation lives here — no sub-classing, no delegates.

```swift
// Sources/DesignFoundationScreens/Onboarding/DFOnboardingConfiguration.swift

import SwiftUI

/// Permission types the app can request during onboarding.
public enum DFOnboardingPermission: String, Sendable, CaseIterable {
    case notifications
    case camera
    case location
    case contacts
}

/// A single feature highlight shown in the carousel.
public struct DFFeatureHighlight: Sendable {
    public let title: String
    public let body: String
    public let iconName: String   // SF Symbol name

    public init(title: String, body: String, iconName: String) {
        self.title = title
        self.body = body
        self.iconName = iconName
    }
}

/// A personalisation tag the user can select.
public struct DFPersonalisationTag: Identifiable, Sendable {
    public let id: String
    public let label: String

    public init(id: String, label: String) {
        self.id = id
        self.label = label
    }
}

/// Complete configuration for `DFOnboardingFlow`.
/// Pass this at the call site — the flow is entirely driven by it.
public struct DFOnboardingConfiguration: Sendable {

    // MARK: — Branding
    public var appName: String
    public var appLogoImage: Image?

    // MARK: — Welcome
    public var welcomeTagline: String
    public var welcomeHeadline: String

    // MARK: — Social auth
    public var enableAppleSignIn: Bool
    public var enableGoogleSignIn: Bool

    // MARK: — Feature highlights
    /// 3–5 items recommended. Empty list skips the Features step.
    public var featureHighlights: [DFFeatureHighlight]

    // MARK: — Permissions
    /// Permissions are shown in this order, one screen each.
    /// Empty list skips the Permissions step.
    public var requestedPermissions: [DFOnboardingPermission]

    // MARK: — Plan selection
    /// Setting false skips the Plan step entirely.
    public var showPlanSelection: Bool

    // MARK: — Personalisation
    /// Empty list skips the Personalisation step.
    public var personalisationTags: [DFPersonalisationTag]

    // MARK: — Success screen
    public var showConfetti: Bool

    // MARK: — Persistence
    /// Key used to persist resume-step in UserDefaults.
    public var persistenceKey: String

    // MARK: — Callbacks
    /// Called when sign-up completes. Developer performs auth here.
    /// Return true to advance, false to surface an error.
    public var onSignUp: @MainActor (String, String, String) async -> Bool  // name, email, password

    /// Called when sign-in completes.
    public var onSignIn: @MainActor (String, String) async -> Bool          // email, password

    /// Called with the OTP code for verification.
    public var onOTPVerify: @MainActor (String) async -> Bool

    /// Called when OTP resend is requested.
    public var onOTPResend: @MainActor () async -> Void

    /// Called when profile is saved (displayName, optional title).
    public var onProfileSave: @MainActor (String, String?) async -> Void

    /// Called for each permission — developer calls the system API.
    public var onPermissionRequest: @MainActor (DFOnboardingPermission) async -> Void

    /// Called when a plan is selected (plan ID string, or nil if "start free").
    public var onPlanSelected: @MainActor (String?) -> Void

    /// Called with selected tag IDs.
    public var onPersonalisationComplete: @MainActor ([String]) -> Void

    /// Called when the user taps "Take me to [App]" on the Success screen.
    public var onComplete: @MainActor () -> Void

    public init(
        appName: String,
        appLogoImage: Image? = nil,
        welcomeTagline: String,
        welcomeHeadline: String,
        enableAppleSignIn: Bool = true,
        enableGoogleSignIn: Bool = true,
        featureHighlights: [DFFeatureHighlight] = [],
        requestedPermissions: [DFOnboardingPermission] = [],
        showPlanSelection: Bool = true,
        personalisationTags: [DFPersonalisationTag] = [],
        showConfetti: Bool = true,
        persistenceKey: String = "df_onboarding_step",
        onSignUp: @escaping @MainActor (String, String, String) async -> Bool,
        onSignIn: @escaping @MainActor (String, String) async -> Bool,
        onOTPVerify: @escaping @MainActor (String) async -> Bool,
        onOTPResend: @escaping @MainActor () async -> Void,
        onProfileSave: @escaping @MainActor (String, String?) async -> Void,
        onPermissionRequest: @escaping @MainActor (DFOnboardingPermission) async -> Void,
        onPlanSelected: @escaping @MainActor (String?) -> Void,
        onPersonalisationComplete: @escaping @MainActor ([String]) -> Void,
        onComplete: @escaping @MainActor () -> Void
    ) {
        self.appName = appName
        self.appLogoImage = appLogoImage
        self.welcomeTagline = welcomeTagline
        self.welcomeHeadline = welcomeHeadline
        self.enableAppleSignIn = enableAppleSignIn
        self.enableGoogleSignIn = enableGoogleSignIn
        self.featureHighlights = featureHighlights
        self.requestedPermissions = requestedPermissions
        self.showPlanSelection = showPlanSelection
        self.personalisationTags = personalisationTags
        self.showConfetti = showConfetti
        self.persistenceKey = persistenceKey
        self.onSignUp = onSignUp
        self.onSignIn = onSignIn
        self.onOTPVerify = onOTPVerify
        self.onOTPResend = onOTPResend
        self.onProfileSave = onProfileSave
        self.onPermissionRequest = onPermissionRequest
        self.onPlanSelected = onPlanSelected
        self.onPersonalisationComplete = onPersonalisationComplete
        self.onComplete = onComplete
    }
}
```

---

## Task 3 — `DFOnboardingState.swift`

Single `@Observable` object. All screens read from and write to this. The coordinator observes it.

```swift
// Sources/DesignFoundationScreens/Onboarding/DFOnboardingState.swift

import Observation
import Foundation

/// All mutable onboarding state. Injected via `.environment` so every screen
/// can read and write without prop-drilling.
@Observable
@MainActor
public final class DFOnboardingState {

    // MARK: — Navigation
    /// Current step. Set by coordinator; screens advance by calling `advance()`.
    public var currentStep: DFOnboardingStep = .welcome

    /// Navigation path for `NavigationStack`.
    public var path: [DFOnboardingStep] = []

    /// Which permissions have been shown (index into config.requestedPermissions).
    public var currentPermissionIndex: Int = 0

    // MARK: — Collected data
    public var signUpName: String = ""
    public var signUpEmail: String = ""
    public var displayName: String = ""
    public var profileTitle: String = ""
    public var selectedPlanID: String? = nil
    public var selectedTagIDs: Set<String> = []

    // MARK: — UI state
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    public var otpResendSecondsRemaining: Int = 60
    public var otpResendTimerActive: Bool = false

    // MARK: — Persistence
    private let persistenceKey: String

    public init(persistenceKey: String) {
        self.persistenceKey = persistenceKey
        restoreStep()
    }

    // MARK: — Step helpers

    /// Computed total steps for the progress bar (sign-up path only).
    /// Excludes welcome + success + signIn from count.
    public func totalSteps(config: DFOnboardingConfiguration) -> Int {
        var count = 0
        count += 1 // signUp
        count += 1 // otp
        count += 1 // profile
        if !config.featureHighlights.isEmpty { count += 1 }
        count += config.requestedPermissions.count
        if config.showPlanSelection { count += 1 }
        if !config.personalisationTags.isEmpty { count += 1 }
        return max(count, 1)
    }

    /// Computed 1-based index of the current step for the progress bar.
    public func currentStepIndex(config: DFOnboardingConfiguration) -> Int {
        switch currentStep {
        case .welcome, .signIn, .success: return 0
        case .signUp: return 1
        case .otp: return 2
        case .profile: return 3
        case .features: return 4
        case .permissions: return 4 + (config.featureHighlights.isEmpty ? 0 : 0) + currentPermissionIndex + 1
        case .plan:
            let base = 4 + (config.featureHighlights.isEmpty ? 0 : 1) + config.requestedPermissions.count
            return base + 1
        case .personalisation:
            let base = 4 + (config.featureHighlights.isEmpty ? 0 : 1) + config.requestedPermissions.count + (config.showPlanSelection ? 1 : 0)
            return base + 1
        }
    }

    // MARK: — Persistence

    public func persistStep() {
        UserDefaults.standard.set(currentStep.rawValue, forKey: persistenceKey)
    }

    public func clearPersistedStep() {
        UserDefaults.standard.removeObject(forKey: persistenceKey)
    }

    private func restoreStep() {
        guard let raw = UserDefaults.standard.string(forKey: persistenceKey),
              let step = DFOnboardingStep(rawValue: raw) else { return }
        // Never restore to success — that would mean they already completed
        guard step != .success else {
            clearPersistedStep()
            return
        }
        currentStep = step
    }
}
```

---

## Task 4 — `DFOnboardingProgressBar.swift`

Thin wrapper — reads state and config to build the `DFProgressBar` call. No layout logic here.

```swift
// Sources/DesignFoundationScreens/Onboarding/DFOnboardingProgressBar.swift

import SwiftUI
import DesignFoundation

/// Step-based progress bar shown at the top of each onboarding screen.
/// Hidden on Welcome, Sign In, and Success.
struct DFOnboardingProgressBar: View {
    let currentStep: Int     // 1-based
    let totalSteps: Int

    var body: some View {
        DFProgressBar(
            value: totalSteps > 0 ? Double(currentStep) / Double(totalSteps) : 0,
            style: .stepped(current: currentStep, total: totalSteps)
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
```

> **Note:** Adjust the `DFProgressBar` initialiser to match the actual API when wiring — the above shows intent. If `DFProgressBar` takes a simple `value: Double`, drop the `.stepped` style and pass the fraction.

---

## Task 5 — `DFOnboardingWelcomeScreen.swift`

Entry point. No progress bar, no back button. Uses `DFWelcomeBlock` full-screen.

```swift
// Sources/DesignFoundationScreens/Onboarding/Screens/DFOnboardingWelcomeScreen.swift

import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

struct DFOnboardingWelcomeScreen: View {
    let config: DFOnboardingConfiguration
    let onGetStarted: @MainActor () -> Void
    let onSignIn: @MainActor () -> Void

    var body: some View {
        DFWelcomeBlock(
            appName: config.appName,
            logoImage: config.appLogoImage,
            tagline: config.welcomeTagline,
            headline: config.welcomeHeadline,
            primaryLabel: "Get Started",
            primaryAction: onGetStarted,
            secondaryLabel: "I already have an account",
            secondaryAction: onSignIn
        )
        .ignoresSafeArea()
    }
}

#Preview("Light") {
    DFOnboardingWelcomeScreen(
        config: .preview,
        onGetStarted: {},
        onSignIn: {}
    )
}

#Preview("Dark") {
    DFOnboardingWelcomeScreen(
        config: .preview,
        onGetStarted: {},
        onSignIn: {}
    )
    .preferredColorScheme(.dark)
}
```

---

## Task 6 — `DFOnboardingSignUpScreen.swift`

Social auth at top, divider, email/password form below. Validates before advancing. Terms inline.

```swift
// Sources/DesignFoundationScreens/Onboarding/Screens/DFOnboardingSignUpScreen.swift

import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

struct DFOnboardingSignUpScreen: View {
    let config: DFOnboardingConfiguration
    let stepIndex: Int
    let totalSteps: Int
    @Environment(\.dfTheme) private var theme
    @State private var state: DFOnboardingState

    // Sign-up form state (kept local — only promoted to DFOnboardingState on success)
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var termsAccepted = false

    let onBack: @MainActor () -> Void
    let onSuccess: @MainActor (String, String) -> Void  // name, email
    let onAppleSignIn: @MainActor () -> Void
    let onGoogleSignIn: @MainActor () -> Void

    var body: some View {
        VStack(spacing: 0) {
            DFOnboardingProgressBar(currentStep: stepIndex, totalSteps: totalSteps)

            DFSignUpBlock(
                name: $name,
                email: $email,
                password: $password,
                termsAccepted: $termsAccepted,
                isLoading: isLoading,
                errorMessage: errorMessage,
                enableAppleSignIn: config.enableAppleSignIn,
                enableGoogleSignIn: config.enableGoogleSignIn,
                onAppleSignIn: onAppleSignIn,
                onGoogleSignIn: onGoogleSignIn,
                onSubmit: {
                    Task { @MainActor in
                        isLoading = true
                        errorMessage = nil
                        let success = await config.onSignUp(name, email, password)
                        isLoading = false
                        if success {
                            onSuccess(name, email)
                        } else {
                            errorMessage = "Something went wrong. Please try again."
                        }
                    }
                }
            )
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                DFButton(icon: "chevron.left", style: .ghost, action: onBack)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        DFOnboardingSignUpScreen(
            config: .preview,
            stepIndex: 1,
            totalSteps: 7,
            state: .init(persistenceKey: "preview"),
            onBack: {},
            onSuccess: { _, _ in },
            onAppleSignIn: {},
            onGoogleSignIn: {}
        )
    }
}

#Preview("Dark") {
    NavigationStack {
        DFOnboardingSignUpScreen(
            config: .preview,
            stepIndex: 1,
            totalSteps: 7,
            state: .init(persistenceKey: "preview"),
            onBack: {},
            onSuccess: { _, _ in },
            onAppleSignIn: {},
            onGoogleSignIn: {}
        )
    }
    .preferredColorScheme(.dark)
}
```

---

## Task 7 — `DFOnboardingSignInScreen.swift`

Reached via "I already have an account". On success, jumps directly to Success step (bypasses OTP, Profile, Features).

```swift
// Sources/DesignFoundationScreens/Onboarding/Screens/DFOnboardingSignInScreen.swift

import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

struct DFOnboardingSignInScreen: View {
    let config: DFOnboardingConfiguration
    @Environment(\.dfTheme) private var theme

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    let onBack: @MainActor () -> Void
    let onSuccess: @MainActor () -> Void
    let onForgotPassword: @MainActor () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // No progress bar — sign-in is a branch, not a step in the main path

            DFSignInBlock(
                email: $email,
                password: $password,
                isLoading: isLoading,
                errorMessage: errorMessage,
                onSubmit: {
                    Task { @MainActor in
                        isLoading = true
                        errorMessage = nil
                        let success = await config.onSignIn(email, password)
                        isLoading = false
                        if success {
                            onSuccess()
                        } else {
                            errorMessage = "Incorrect email or password."
                        }
                    }
                },
                onForgotPassword: onForgotPassword
            )
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                DFButton(icon: "chevron.left", style: .ghost, action: onBack)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        DFOnboardingSignInScreen(
            config: .preview,
            onBack: {},
            onSuccess: {},
            onForgotPassword: {}
        )
    }
}

#Preview("Dark") {
    NavigationStack {
        DFOnboardingSignInScreen(
            config: .preview,
            onBack: {},
            onSuccess: {},
            onForgotPassword: {}
        )
    }
    .preferredColorScheme(.dark)
}
```

---

## Task 8 — `DFOnboardingOTPScreen.swift`

6-digit auto-advancing input. Resend countdown. Email correction link.

```swift
// Sources/DesignFoundationScreens/Onboarding/Screens/DFOnboardingOTPScreen.swift

import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

struct DFOnboardingOTPScreen: View {
    let config: DFOnboardingConfiguration
    let email: String
    let stepIndex: Int
    let totalSteps: Int
    @Environment(\.dfTheme) private var theme

    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var resendSecondsRemaining = 60
    @State private var resendTimer: Timer? = nil

    let onBack: @MainActor () -> Void
    let onVerified: @MainActor () -> Void

    var body: some View {
        VStack(spacing: 0) {
            DFOnboardingProgressBar(currentStep: stepIndex, totalSteps: totalSteps)

            DFOTPBlock(
                contextMessage: "We sent a 6-digit code to \(email)",
                isLoading: isLoading,
                errorMessage: errorMessage,
                onSubmit: { code in
                    Task { @MainActor in
                        isLoading = true
                        errorMessage = nil
                        let success = await config.onOTPVerify(code)
                        isLoading = false
                        if success {
                            onVerified()
                        } else {
                            errorMessage = "That code didn't match. Please try again."
                        }
                    }
                },
                resendSecondsRemaining: resendSecondsRemaining,
                onResend: {
                    Task { @MainActor in
                        await config.onOTPResend()
                        resendSecondsRemaining = 60
                        startResendTimer()
                    }
                }
            )

            DFButton(
                label: "Wrong email? Go back",
                style: .ghost,
                action: onBack
            )
            .padding(.bottom, 24)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                DFButton(icon: "chevron.left", style: .ghost, action: onBack)
            }
        }
        .onAppear { startResendTimer() }
        .onDisappear { resendTimer?.invalidate() }
    }

    private func startResendTimer() {
        resendTimer?.invalidate()
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if resendSecondsRemaining > 0 {
                    resendSecondsRemaining -= 1
                } else {
                    resendTimer?.invalidate()
                }
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        DFOnboardingOTPScreen(
            config: .preview,
            email: "alex@example.com",
            stepIndex: 2,
            totalSteps: 7,
            onBack: {},
            onVerified: {}
        )
    }
}

#Preview("Dark") {
    NavigationStack {
        DFOnboardingOTPScreen(
            config: .preview,
            email: "alex@example.com",
            stepIndex: 2,
            totalSteps: 7,
            onBack: {},
            onVerified: {}
        )
    }
    .preferredColorScheme(.dark)
}
```

---

## Task 9 — `DFOnboardingProfileScreen.swift`

Single-screen quick profile: display name + optional title. Avatar upload is a placeholder DFButton — actual upload is left to the developer callback.

```swift
// Sources/DesignFoundationScreens/Onboarding/Screens/DFOnboardingProfileScreen.swift

import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

struct DFOnboardingProfileScreen: View {
    let config: DFOnboardingConfiguration
    let stepIndex: Int
    let totalSteps: Int
    @Environment(\.dfTheme) private var theme

    @State private var displayName: String
    @State private var title = ""
    @State private var isLoading = false

    let onBack: @MainActor () -> Void
    let onContinue: @MainActor (String, String?) -> Void  // displayName, title?

    init(
        config: DFOnboardingConfiguration,
        suggestedName: String,
        stepIndex: Int,
        totalSteps: Int,
        onBack: @escaping @MainActor () -> Void,
        onContinue: @escaping @MainActor (String, String?) -> Void
    ) {
        self.config = config
        self._displayName = State(initialValue: suggestedName)
        self.stepIndex = stepIndex
        self.totalSteps = totalSteps
        self.onBack = onBack
        self.onContinue = onContinue
    }

    private var canContinue: Bool { !displayName.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            DFOnboardingProgressBar(currentStep: stepIndex, totalSteps: totalSteps)

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.xl) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        DFText("Tell us about yourself", style: .title2)
                        DFText("This is how you'll appear in the app.", style: .body, color: .secondary)
                    }

                    // Avatar placeholder
                    HStack {
                        Spacer()
                        DFButton(
                            icon: "person.crop.circle.badge.plus",
                            label: "Add Photo",
                            style: .secondary
                        ) { /* developer implements avatar picker via a separate callback if needed */ }
                        Spacer()
                    }

                    DFTextField(
                        label: "Display name",
                        placeholder: "How should we call you?",
                        text: $displayName
                    )

                    DFTextField(
                        label: "Role / title",
                        placeholder: "Optional",
                        text: $title
                    )

                    DFButton(
                        label: "Continue",
                        style: .primary,
                        isLoading: isLoading,
                        isEnabled: canContinue
                    ) {
                        Task { @MainActor in
                            isLoading = true
                            await config.onProfileSave(displayName, title.isEmpty ? nil : title)
                            isLoading = false
                            onContinue(displayName, title.isEmpty ? nil : title)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                DFButton(icon: "chevron.left", style: .ghost, action: onBack)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        DFOnboardingProfileScreen(
            config: .preview,
            suggestedName: "Alex",
            stepIndex: 3,
            totalSteps: 7,
            onBack: {},
            onContinue: { _, _ in }
        )
    }
}

#Preview("Dark") {
    NavigationStack {
        DFOnboardingProfileScreen(
            config: .preview,
            suggestedName: "Alex",
            stepIndex: 3,
            totalSteps: 7,
            onBack: {},
            onContinue: { _, _ in }
        )
    }
    .preferredColorScheme(.dark)
}
```

---

## Task 10 — `DFOnboardingFeaturesScreen.swift`

Wraps `DFFeatureCarouselBlock`. Skip button top-right. Auto-advances after final card's Continue tap.

```swift
// Sources/DesignFoundationScreens/Onboarding/Screens/DFOnboardingFeaturesScreen.swift

import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

struct DFOnboardingFeaturesScreen: View {
    let config: DFOnboardingConfiguration
    let stepIndex: Int
    let totalSteps: Int

    let onBack: @MainActor () -> Void
    let onContinue: @MainActor () -> Void

    var body: some View {
        VStack(spacing: 0) {
            DFOnboardingProgressBar(currentStep: stepIndex, totalSteps: totalSteps)

            DFFeatureCarouselBlock(
                highlights: config.featureHighlights.map {
                    DFFeatureCarouselItem(
                        title: $0.title,
                        body: $0.body,
                        iconName: $0.iconName
                    )
                },
                onComplete: onContinue
            )
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                DFButton(icon: "chevron.left", style: .ghost, action: onBack)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                DFButton(label: "Skip", style: .ghost, action: onContinue)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        DFOnboardingFeaturesScreen(
            config: .preview,
            stepIndex: 4,
            totalSteps: 7,
            onBack: {},
            onContinue: {}
        )
    }
}

#Preview("Dark") {
    NavigationStack {
        DFOnboardingFeaturesScreen(
            config: .preview,
            stepIndex: 4,
            totalSteps: 7,
            onBack: {},
            onContinue: {}
        )
    }
    .preferredColorScheme(.dark)
}
```

---

## Task 11 — `DFOnboardingPermissionsScreen.swift`

One screen per permission. Benefit-focused copy. The developer supplies their own system-permission call in `onPermissionRequest`. Skipped permissions are reported via `onSkip`.

```swift
// Sources/DesignFoundationScreens/Onboarding/Screens/DFOnboardingPermissionsScreen.swift

import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

struct DFOnboardingPermissionsScreen: View {
    let permission: DFOnboardingPermission
    let config: DFOnboardingConfiguration
    let stepIndex: Int
    let totalSteps: Int
    @Environment(\.dfTheme) private var theme

    @State private var isLoading = false

    let onBack: @MainActor () -> Void
    let onAllow: @MainActor () -> Void
    let onSkip: @MainActor () -> Void

    private var permissionMeta: (icon: String, title: String, benefit: String) {
        switch permission {
        case .notifications:
            return ("bell.badge.fill",
                    "Stay in the loop",
                    "Get notified when something important happens — activity, replies, and updates delivered instantly.")
        case .camera:
            return ("camera.fill",
                    "Capture anything",
                    "Scan documents, snap photos, and add visual context right from the app.")
        case .location:
            return ("location.fill",
                    "Content near you",
                    "See relevant items, people, and events based on where you are.")
        case .contacts:
            return ("person.2.fill",
                    "Find your people",
                    "Invite teammates and connect with colleagues already using the app.")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            DFOnboardingProgressBar(currentStep: stepIndex, totalSteps: totalSteps)

            DFPermissionRequestBlock(
                iconName: permissionMeta.icon,
                title: permissionMeta.title,
                benefit: permissionMeta.benefit,
                allowLabel: "Allow",
                skipLabel: "Not now",
                isLoading: isLoading,
                onAllow: {
                    Task { @MainActor in
                        isLoading = true
                        await config.onPermissionRequest(permission)
                        isLoading = false
                        onAllow()
                    }
                },
                onSkip: onSkip
            )
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                DFButton(icon: "chevron.left", style: .ghost, action: onBack)
            }
        }
    }
}

#Preview("Notifications — Light") {
    NavigationStack {
        DFOnboardingPermissionsScreen(
            permission: .notifications,
            config: .preview,
            stepIndex: 5,
            totalSteps: 7,
            onBack: {},
            onAllow: {},
            onSkip: {}
        )
    }
}

#Preview("Notifications — Dark") {
    NavigationStack {
        DFOnboardingPermissionsScreen(
            permission: .notifications,
            config: .preview,
            stepIndex: 5,
            totalSteps: 7,
            onBack: {},
            onAllow: {},
            onSkip: {}
        )
    }
    .preferredColorScheme(.dark)
}
```

---

## Task 12 — `DFOnboardingPlanScreen.swift`

Wraps `DFPlanSelectionBlock`. "Start free" always present. Skip link for apps that handle billing separately.

```swift
// Sources/DesignFoundationScreens/Onboarding/Screens/DFOnboardingPlanScreen.swift

import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

struct DFOnboardingPlanScreen: View {
    let config: DFOnboardingConfiguration
    let stepIndex: Int
    let totalSteps: Int

    let onBack: @MainActor () -> Void
    let onPlanSelected: @MainActor (String?) -> Void  // nil = start free
    let onSkip: @MainActor () -> Void

    var body: some View {
        VStack(spacing: 0) {
            DFOnboardingProgressBar(currentStep: stepIndex, totalSteps: totalSteps)

            DFPlanSelectionBlock(
                onSelect: { planID in
                    config.onPlanSelected(planID)
                    onPlanSelected(planID)
                },
                onStartFree: {
                    config.onPlanSelected(nil)
                    onPlanSelected(nil)
                }
            )
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                DFButton(icon: "chevron.left", style: .ghost, action: onBack)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                DFButton(label: "Skip", style: .ghost, action: onSkip)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        DFOnboardingPlanScreen(
            config: .preview,
            stepIndex: 6,
            totalSteps: 7,
            onBack: {},
            onPlanSelected: { _ in },
            onSkip: {}
        )
    }
}

#Preview("Dark") {
    NavigationStack {
        DFOnboardingPlanScreen(
            config: .preview,
            stepIndex: 6,
            totalSteps: 7,
            onBack: {},
            onPlanSelected: { _ in },
            onSkip: {}
        )
    }
    .preferredColorScheme(.dark)
}
```

---

## Task 13 — `DFOnboardingPersonalisationScreen.swift`

`DFTagPickerBlock` multi-select. Continue activates after ≥1 selection.

```swift
// Sources/DesignFoundationScreens/Onboarding/Screens/DFOnboardingPersonalisationScreen.swift

import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

struct DFOnboardingPersonalisationScreen: View {
    let config: DFOnboardingConfiguration
    let stepIndex: Int
    let totalSteps: Int
    @Environment(\.dfTheme) private var theme

    @State private var selectedIDs: Set<String> = []

    let onBack: @MainActor () -> Void
    let onContinue: @MainActor ([String]) -> Void

    private var canContinue: Bool { !selectedIDs.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            DFOnboardingProgressBar(currentStep: stepIndex, totalSteps: totalSteps)

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        DFText("What will you use \(config.appName) for?", style: .title2)
                        DFText("Pick everything that applies.", style: .body, color: .secondary)
                    }
                    .padding(.horizontal)

                    DFTagPickerBlock(
                        tags: config.personalisationTags.map {
                            DFTag(id: $0.id, label: $0.label)
                        },
                        selectedIDs: $selectedIDs,
                        selectionMode: .multiple
                    )

                    DFButton(
                        label: "Continue",
                        style: .primary,
                        isEnabled: canContinue
                    ) {
                        let ids = Array(selectedIDs)
                        config.onPersonalisationComplete(ids)
                        onContinue(ids)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .padding(.top)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                DFButton(icon: "chevron.left", style: .ghost, action: onBack)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        DFOnboardingPersonalisationScreen(
            config: .preview,
            stepIndex: 7,
            totalSteps: 7,
            onBack: {},
            onContinue: { _ in }
        )
    }
}

#Preview("Dark") {
    NavigationStack {
        DFOnboardingPersonalisationScreen(
            config: .preview,
            stepIndex: 7,
            totalSteps: 7,
            onBack: {},
            onContinue: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}
```

---

## Task 14 — `DFOnboardingSuccessScreen.swift`

Personalised using the display name collected in the Profile step. Scale + fade in on appear. Optional confetti controlled by config flag.

```swift
// Sources/DesignFoundationScreens/Onboarding/Screens/DFOnboardingSuccessScreen.swift

import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

struct DFOnboardingSuccessScreen: View {
    let config: DFOnboardingConfiguration
    let displayName: String
    @Environment(\.dfTheme) private var theme

    @State private var appeared = false

    let onComplete: @MainActor () -> Void

    var body: some View {
        DFSuccessBlock(
            title: "You're all set, \(displayName.isEmpty ? "there" : displayName)!",
            body: "Welcome to \(config.appName). Everything is ready — let's go.",
            ctaLabel: "Take me to \(config.appName)",
            showConfetti: config.showConfetti,
            onCTA: {
                onComplete()
            }
        )
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: appeared)
        .onAppear { appeared = true }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        // No toolbar — success is terminal
    }
}

#Preview("Light") {
    DFOnboardingSuccessScreen(
        config: .preview,
        displayName: "Alex",
        onComplete: {}
    )
}

#Preview("Dark") {
    DFOnboardingSuccessScreen(
        config: .preview,
        displayName: "Alex",
        onComplete: {}
    )
    .preferredColorScheme(.dark)
}
```

---

## Task 15 — `DFOnboardingFlow.swift` (Coordinator)

The main deliverable. Owns the `NavigationStack`, drives all transitions, persists step, and wires every screen together. Developer drops this in and passes a `DFOnboardingConfiguration`.

```swift
// Sources/DesignFoundationScreens/Onboarding/DFOnboardingFlow.swift

import SwiftUI
import DesignFoundation
import DesignFoundationBlocks

/// Drop-in onboarding coordinator.
///
/// Usage:
/// ```swift
/// DFOnboardingFlow(config: DFOnboardingConfiguration(
///     appName: "Acme",
///     welcomeTagline: "Work smarter.",
///     welcomeHeadline: "The team tool that gets out of your way.",
///     onSignUp: { name, email, pass in … return true },
///     onSignIn: { email, pass in … return true },
///     onOTPVerify: { code in … return true },
///     onOTPResend: { … },
///     onProfileSave: { name, title in … },
///     onPermissionRequest: { permission in … },
///     onPlanSelected: { planID in … },
///     onPersonalisationComplete: { tagIDs in … },
///     onComplete: { … }
/// ))
/// ```
public struct DFOnboardingFlow: View {

    private let config: DFOnboardingConfiguration
    @State private var state: DFOnboardingState
    @State private var path: [DFOnboardingStep] = []

    // Collected across steps
    @State private var signUpEmail = ""
    @State private var displayName = ""
    @State private var currentPermissionIndex = 0

    public init(config: DFOnboardingConfiguration) {
        self.config = config
        self._state = State(initialValue: DFOnboardingState(persistenceKey: config.persistenceKey))
    }

    // MARK: — Step helpers

    private var totalSteps: Int { state.totalSteps(config: config) }

    private func stepIndex(for step: DFOnboardingStep) -> Int {
        state.currentStep = step
        return state.currentStepIndex(config: config)
    }

    // MARK: — Navigation

    private func advance(to step: DFOnboardingStep) {
        state.currentStep = step
        state.persistStep()
        path.append(step)
    }

    private func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
        state.currentStep = path.last ?? .welcome
        state.persistStep()
    }

    // MARK: — Sign-up path entry point

    private func startSignUp() {
        advance(to: .signUp)
    }

    // MARK: — Sign-in branch

    private func startSignIn() {
        advance(to: .signIn)
    }

    // MARK: — After sign-up success

    private func afterSignUp(name: String, email: String) {
        displayName = name
        signUpEmail = email
        advance(to: .otp)
    }

    // MARK: — After OTP verified

    private func afterOTP() {
        advance(to: .profile)
    }

    // MARK: — After profile saved

    private func afterProfile(name: String) {
        displayName = name
        if config.featureHighlights.isEmpty {
            advanceAfterFeatures()
        } else {
            advance(to: .features)
        }
    }

    // MARK: — After features

    private func advanceAfterFeatures() {
        currentPermissionIndex = 0
        if config.requestedPermissions.isEmpty {
            advanceAfterPermissions()
        } else {
            advance(to: .permissions)
        }
    }

    // MARK: — After each permission

    private func advancePermission() {
        currentPermissionIndex += 1
        if currentPermissionIndex >= config.requestedPermissions.count {
            advanceAfterPermissions()
        } else {
            // Stay on .permissions step but re-render with new index
            // Force a view refresh by popping and re-pushing
            path.removeLast()
            path.append(.permissions)
        }
    }

    private func advanceAfterPermissions() {
        if config.showPlanSelection {
            advance(to: .plan)
        } else {
            advanceAfterPlan()
        }
    }

    // MARK: — After plan

    private func advanceAfterPlan() {
        if config.personalisationTags.isEmpty {
            advance(to: .success)
        } else {
            advance(to: .personalisation)
        }
    }

    // MARK: — After personalisation

    private func afterPersonalisation() {
        advance(to: .success)
    }

    // MARK: — Completion

    private func complete() {
        state.clearPersistedStep()
        config.onComplete()
    }

    // MARK: — View

    public var body: some View {
        NavigationStack(path: $path) {
            // Root: Welcome
            DFOnboardingWelcomeScreen(
                config: config,
                onGetStarted: startSignUp,
                onSignIn: startSignIn
            )
            .navigationDestination(for: DFOnboardingStep.self) { step in
                destination(for: step)
            }
        }
        .onAppear { resumeIfNeeded() }
    }

    // MARK: — Resume

    /// If the user quit mid-flow, rebuild the path to their saved step.
    private func resumeIfNeeded() {
        let saved = state.currentStep
        guard saved != .welcome else { return }

        // Rebuild path from sign-up path up to the saved step
        let fullPath = DFOnboardingStep.signUpPath.filter { $0 != .welcome && $0 != .success }
        var rebuilt: [DFOnboardingStep] = []
        for s in fullPath {
            rebuilt.append(s)
            if s == saved { break }
        }
        path = rebuilt
    }

    // MARK: — Destination builder

    @ViewBuilder
    private func destination(for step: DFOnboardingStep) -> some View {
        switch step {

        case .welcome:
            DFOnboardingWelcomeScreen(
                config: config,
                onGetStarted: startSignUp,
                onSignIn: startSignIn
            )

        case .signUp:
            DFOnboardingSignUpScreen(
                config: config,
                stepIndex: 1,
                totalSteps: totalSteps,
                state: state,
                onBack: pop,
                onSuccess: afterSignUp,
                onAppleSignIn: { advance(to: .success) },   // social auth skips to success
                onGoogleSignIn: { advance(to: .success) }
            )

        case .signIn:
            DFOnboardingSignInScreen(
                config: config,
                onBack: pop,
                onSuccess: { advance(to: .success) },
                onForgotPassword: { /* developer handles externally */ }
            )

        case .otp:
            DFOnboardingOTPScreen(
                config: config,
                email: signUpEmail,
                stepIndex: 2,
                totalSteps: totalSteps,
                onBack: pop,
                onVerified: afterOTP
            )

        case .profile:
            DFOnboardingProfileScreen(
                config: config,
                suggestedName: displayName,
                stepIndex: 3,
                totalSteps: totalSteps,
                onBack: pop,
                onContinue: { name, _ in afterProfile(name: name) }
            )

        case .features:
            DFOnboardingFeaturesScreen(
                config: config,
                stepIndex: 4,
                totalSteps: totalSteps,
                onBack: pop,
                onContinue: advanceAfterFeatures
            )

        case .permissions:
            let idx = currentPermissionIndex
            let perm = config.requestedPermissions[safe: idx] ?? config.requestedPermissions[0]
            let stepIdx = 4
                + (config.featureHighlights.isEmpty ? 0 : 1)
                + idx + 1
            DFOnboardingPermissionsScreen(
                permission: perm,
                config: config,
                stepIndex: stepIdx,
                totalSteps: totalSteps,
                onBack: pop,
                onAllow: advancePermission,
                onSkip: advancePermission
            )

        case .plan:
            let stepIdx = 4
                + (config.featureHighlights.isEmpty ? 0 : 1)
                + config.requestedPermissions.count + 1
            DFOnboardingPlanScreen(
                config: config,
                stepIndex: stepIdx,
                totalSteps: totalSteps,
                onBack: pop,
                onPlanSelected: { _ in advanceAfterPlan() },
                onSkip: advanceAfterPlan
            )

        case .personalisation:
            let stepIdx = 4
                + (config.featureHighlights.isEmpty ? 0 : 1)
                + config.requestedPermissions.count
                + (config.showPlanSelection ? 1 : 0) + 1
            DFOnboardingPersonalisationScreen(
                config: config,
                stepIndex: stepIdx,
                totalSteps: totalSteps,
                onBack: pop,
                onContinue: { _ in afterPersonalisation() }
            )

        case .success:
            DFOnboardingSuccessScreen(
                config: config,
                displayName: displayName,
                onComplete: complete
            )
        }
    }
}
```

---

## Safe Collection Extension

Add this internal helper to the package (or inline where needed):

```swift
// Sources/DesignFoundationScreens/Internal/Collection+Safe.swift

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
```

---

## Preview Configuration

Every screen preview needs a `DFOnboardingConfiguration`. Add this internal extension:

```swift
// Sources/DesignFoundationScreens/Onboarding/DFOnboardingConfiguration+Preview.swift

#if DEBUG
extension DFOnboardingConfiguration {
    static var preview: DFOnboardingConfiguration {
        DFOnboardingConfiguration(
            appName: "Acme",
            welcomeTagline: "Work smarter.",
            welcomeHeadline: "The team tool that gets out of your way.",
            featureHighlights: [
                DFFeatureHighlight(title: "Stay organised", body: "Everything in one place, always up to date.", iconName: "checkmark.circle.fill"),
                DFFeatureHighlight(title: "Work together", body: "Real-time collaboration with your whole team.", iconName: "person.2.fill"),
                DFFeatureHighlight(title: "Move fast", body: "Keyboard-first. No friction. No waiting.", iconName: "bolt.fill"),
            ],
            requestedPermissions: [.notifications],
            showPlanSelection: true,
            personalisationTags: [
                DFPersonalisationTag(id: "pm", label: "Project management"),
                DFPersonalisationTag(id: "crm", label: "CRM / Sales"),
                DFPersonalisationTag(id: "docs", label: "Docs & notes"),
                DFPersonalisationTag(id: "dev", label: "Engineering"),
            ],
            showConfetti: true,
            persistenceKey: "df_preview_onboarding",
            onSignUp: { _, _, _ in true },
            onSignIn: { _, _ in true },
            onOTPVerify: { _ in true },
            onOTPResend: {},
            onProfileSave: { _, _ in },
            onPermissionRequest: { _ in },
            onPlanSelected: { _ in },
            onPersonalisationComplete: { _ in },
            onComplete: {}
        )
    }
}
#endif
```

---

## Task 16 — Tests

```swift
// Tests/DesignFoundationScreensTests/Onboarding/DFOnboardingStepTests.swift

import Testing
@testable import DesignFoundationScreens

@Suite("DFOnboardingStep")
struct DFOnboardingStepTests {

    @Test("Welcome and Success disallow back navigation")
    func backNavigationGating() {
        #expect(DFOnboardingStep.welcome.allowsBack == false)
        #expect(DFOnboardingStep.success.allowsBack == false)
    }

    @Test("All intermediate steps allow back navigation")
    func intermediateStepsAllowBack() {
        let intermediate: [DFOnboardingStep] = [
            .signUp, .otp, .profile, .features, .permissions, .plan, .personalisation
        ]
        for step in intermediate {
            #expect(step.allowsBack, "Expected \(step) to allow back navigation")
        }
    }

    @Test("Progress bar visibility rules")
    func progressBarVisibility() {
        #expect(DFOnboardingStep.welcome.showsProgress == false)
        #expect(DFOnboardingStep.signIn.showsProgress == false)
        #expect(DFOnboardingStep.success.showsProgress == false)
        #expect(DFOnboardingStep.signUp.showsProgress == true)
        #expect(DFOnboardingStep.otp.showsProgress == true)
    }

    @Test("Sign-up path starts at welcome and ends at success")
    func signUpPathBoundaries() {
        #expect(DFOnboardingStep.signUpPath.first == .welcome)
        #expect(DFOnboardingStep.signUpPath.last == .success)
    }

    @Test("Sign-in path skips OTP and profile")
    func signInPathIsAbbreviated() {
        let path = DFOnboardingStep.signInPath
        #expect(!path.contains(.otp))
        #expect(!path.contains(.profile))
        #expect(!path.contains(.features))
    }
}
```

```swift
// Tests/DesignFoundationScreensTests/Onboarding/DFOnboardingStateTests.swift

import Testing
@testable import DesignFoundationScreens

@MainActor
@Suite("DFOnboardingState")
struct DFOnboardingStateTests {

    private let testKey = "df_test_onboarding_\(UUID().uuidString)"

    @Test("Initialises to welcome step when no persisted value")
    func freshInit() {
        let state = DFOnboardingState(persistenceKey: testKey)
        #expect(state.currentStep == .welcome)
    }

    @Test("Persists and restores step")
    func persistAndRestore() {
        let state = DFOnboardingState(persistenceKey: testKey)
        state.currentStep = .otp
        state.persistStep()

        let restored = DFOnboardingState(persistenceKey: testKey)
        #expect(restored.currentStep == .otp)

        // Cleanup
        restored.clearPersistedStep()
    }

    @Test("Does not restore success step — clears it instead")
    func doesNotRestoreSuccess() {
        UserDefaults.standard.set(DFOnboardingStep.success.rawValue, forKey: testKey)

        let state = DFOnboardingState(persistenceKey: testKey)
        #expect(state.currentStep == .welcome)
        #expect(UserDefaults.standard.string(forKey: testKey) == nil)
    }

    @Test("Clear removes persisted step")
    func clearPersistence() {
        let state = DFOnboardingState(persistenceKey: testKey)
        state.currentStep = .profile
        state.persistStep()
        state.clearPersistedStep()

        let fresh = DFOnboardingState(persistenceKey: testKey)
        #expect(fresh.currentStep == .welcome)
    }
}
```

```swift
// Tests/DesignFoundationScreensTests/Onboarding/DFOnboardingConfigurationTests.swift

import Testing
@testable import DesignFoundationScreens

@Suite("DFOnboardingConfiguration")
struct DFOnboardingConfigurationTests {

    @Test("Preview config has non-empty app name")
    func previewAppName() {
        #expect(!DFOnboardingConfiguration.preview.appName.isEmpty)
    }

    @Test("Preview config has feature highlights")
    func previewHighlights() {
        #expect(DFOnboardingConfiguration.preview.featureHighlights.count >= 3)
    }

    @Test("Feature highlights respect 3–5 item guideline")
    func highlightCountGuideline() {
        let config = DFOnboardingConfiguration.preview
        #expect(config.featureHighlights.count >= 3)
        #expect(config.featureHighlights.count <= 5)
    }

    @Test("Personalisation tags have unique IDs")
    func personalisationTagsUnique() {
        let tags = DFOnboardingConfiguration.preview.personalisationTags
        let ids = tags.map(\.id)
        #expect(ids.count == Set(ids).count)
    }
}
```

---

## Wiring Notes

### Block API assumptions

The plan references `DFFeatureCarouselBlock`, `DFPermissionRequestBlock`, `DFSuccessBlock`, `DFSignUpBlock`, `DFSignInBlock`, and `DFOTPBlock` with initialiser signatures that reflect their expected contracts. When wiring, read the actual block source and adjust parameter names — **do not guess**. If a block's API differs from what this plan shows, update the screen to match the block, not the other way around.

### `DFProgressBar` style parameter

The plan uses a hypothetical `.stepped(current:total:)` style. If `DFProgressBar` only accepts `value: Double`, pass `Double(stepIndex) / Double(totalSteps)` instead. Adjust `DFOnboardingProgressBar.swift` accordingly.

### `DFFeatureCarouselItem` and `DFTag`

These intermediate types are used in the screen wiring. If `DFFeatureCarouselBlock` and `DFTagPickerBlock` take different input types, map at the call site in the screen file, not in `DFOnboardingConfiguration`.

### Social auth flow

The plan routes social sign-in (`onAppleSignIn`, `onGoogleSignIn`) directly to `.success`. In practice the developer may want to also collect a profile or verify an email — they can do so inside their `onSignUp` callback and control the outcome by returning `true`/`false`. If the flow needs to branch differently (e.g., show profile setup after Apple Sign In for new users), add a `SocialAuthResult` enum to `DFOnboardingConfiguration` and update the coordinator's `destination(for:)` switch.

### Permissions re-render trick

When advancing through permission screens, the coordinator pops and re-pushes the `.permissions` step to force SwiftUI to re-render with the new `currentPermissionIndex`. This is intentional and avoids storing per-permission sub-paths in the navigation stack. If this causes a visual glitch on some iOS versions, replace with a per-permission step enum variant (`.permissions(index: Int)`).

---

## Commit Sequence

```
feat(screens): add DFOnboardingStep enum and state machine helpers
feat(screens): add DFOnboardingConfiguration with callbacks
feat(screens): add DFOnboardingState observable object with persistence
feat(screens): add DFOnboardingProgressBar wrapper
feat(screens): add DFOnboardingWelcomeScreen
feat(screens): add DFOnboardingSignUpScreen
feat(screens): add DFOnboardingSignInScreen
feat(screens): add DFOnboardingOTPScreen with resend timer
feat(screens): add DFOnboardingProfileScreen
feat(screens): add DFOnboardingFeaturesScreen
feat(screens): add DFOnboardingPermissionsScreen
feat(screens): add DFOnboardingPlanScreen
feat(screens): add DFOnboardingPersonalisationScreen
feat(screens): add DFOnboardingSuccessScreen with entrance animation
feat(screens): add DFOnboardingFlow coordinator
feat(screens): add onboarding flow tests
```
