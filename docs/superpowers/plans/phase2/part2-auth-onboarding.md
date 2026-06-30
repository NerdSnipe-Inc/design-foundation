# Phase 2 Auth & Onboarding Blocks — Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development to implement task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Build 6 auth and onboarding blocks: DFOTPBlock, DFWelcomeBlock, DFFeatureCarouselBlock, DFPermissionRequestBlock, DFPlanSelectionBlock, DFSuccessBlock.

**Architecture:** Each block is a self-contained SwiftUI view with a typed Configuration struct. All styling via DFTheme. No hardcoded values.

**Tech Stack:** Swift 6, SwiftUI, DesignFoundation, Swift Testing

## Preview Pattern — REQUIRED FOR ALL PREVIEWS

Every `#Preview` block MUST:
1. Wrap content in `ScrollView { ... }`
2. Apply `.frame(width: 390)` on the ScrollView
3. Apply `.preferredColorScheme(.light)` or `.preferredColorScheme(.dark)` at the end

```swift
#Preview("Default — Light") {
    ScrollView {
        MyBlock(configuration: .init(...))
            .padding()
    }
    .frame(width: 390)
    .preferredColorScheme(.light)
}
```

## Global Constraints

- Swift 6, `StrictConcurrency` enabled on all targets
- Platforms: iOS 18, macOS 15, visionOS 2
- All action closures typed `(@MainActor () -> Void)?`
- Bridge @MainActor calls with `Task { @MainActor in action() }` — NEVER `MainActor.assumeIsolated`
- All colors/typography/spacing from `@Environment(\.dfTheme)` — zero hardcoded values
- Color tokens: `.primary`, `.textPrimary`, `.textSecondary`, `.surface`, `.surfaceElevated`, `.border`, `.destructive`, `.success`
- Tests: Swift Testing only — `import Testing`, `@Suite`, `@Test`, `#expect` — NEVER XCTest
- **Minimum 4 previews per block + block-specific states**
- Configuration pattern: `public struct Configuration` with typed properties
- `@_exported import DesignFoundation` is in the package entry point

**DFButton API:** `DFButton(_ label: String, role: DFButtonRole? = nil, action: @escaping () -> Void)`

**DFTextField API:** `DFTextField(_ label: String, text: Binding<String>)`

**Existing DFSocialAuthProvider (already built):**
```swift
public enum DFSocialAuthProvider: Sendable {
    case apple(action: @MainActor () -> Void)
    case google(action: @MainActor () -> Void)
    case custom(icon: String, title: String, action: @MainActor () -> Void)
}
```

---

## Task 5: DFOTPBlock

### Files

- Create: `Sources/DesignFoundationBlocks/Auth/DFOTPBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Auth/DFOTPBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Auth/DFOTPBlockTests.swift`

### Interfaces

```swift
public struct DFOTPBlock: View {
    public struct Configuration {
        public var digitCount: Int
        public var maskedEntry: Bool
        public var title: String
        public var subtitle: String?
        public var submitTitle: String
        public var resendTitle: String?
        public var onSubmit: @MainActor (String) -> Void
        public var onResend: (@MainActor () -> Void)?
    }
}
```

### Steps

- [ ] **5.1** Create `Sources/DesignFoundationBlocks/Auth/DFOTPBlock.swift`:

```swift
import SwiftUI
import DesignFoundation

public struct DFOTPBlock: View {
    public struct Configuration: Sendable {
        public var digitCount: Int
        public var maskedEntry: Bool
        public var title: String
        public var subtitle: String?
        public var submitTitle: String
        public var resendTitle: String?
        public var onSubmit: @MainActor (String) -> Void
        public var onResend: (@MainActor () -> Void)?

        public init(
            digitCount: Int = 6,
            maskedEntry: Bool = false,
            title: String = "Enter code",
            subtitle: String? = nil,
            submitTitle: String = "Verify",
            resendTitle: String? = "Resend code",
            onSubmit: @escaping @MainActor (String) -> Void,
            onResend: (@MainActor () -> Void)? = nil
        ) {
            self.digitCount = digitCount
            self.maskedEntry = maskedEntry
            self.title = title
            self.subtitle = subtitle
            self.submitTitle = submitTitle
            self.resendTitle = resendTitle
            self.onSubmit = onSubmit
            self.onResend = onResend
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme
    @State private var code: String = ""
    @FocusState private var isFocused: Bool

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(spacing: theme.spacing.lg) {
            VStack(spacing: theme.spacing.sm) {
                Text(configuration.title)
                    .font(theme.typography.title2)
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)

                if let subtitle = configuration.subtitle {
                    Text(subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            ZStack {
                // Hidden text field captures input
                Group {
                    if configuration.maskedEntry {
                        SecureField("", text: $code)
                    } else {
                        TextField("", text: $code)
                            .keyboardType(.numberPad)
                    }
                }
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .onChange(of: code) { _, newValue in
                    let filtered = String(newValue.filter(\.isNumber).prefix(configuration.digitCount))
                    if filtered != newValue {
                        code = filtered
                    }
                    if filtered.count == configuration.digitCount {
                        Task { @MainActor in
                            configuration.onSubmit(filtered)
                        }
                    }
                }

                // Visual digit boxes
                HStack(spacing: theme.spacing.sm) {
                    ForEach(0..<configuration.digitCount, id: \.self) { index in
                        digitBox(at: index)
                    }
                }
            }
            .onTapGesture {
                isFocused = true
            }
            .onAppear {
                isFocused = true
            }

            DFButton(configuration.submitTitle) {
                Task { @MainActor in
                    configuration.onSubmit(code)
                }
            }
            .disabled(code.count != configuration.digitCount)

            if let resendTitle = configuration.resendTitle,
               let onResend = configuration.onResend {
                Button(resendTitle) {
                    Task { @MainActor in onResend() }
                }
                .font(theme.typography.callout)
                .foregroundStyle(theme.colors.primary)
            }
        }
        .padding(theme.spacing.xl)
    }

    @ViewBuilder
    private func digitBox(at index: Int) -> some View {
        let codeArray = Array(code)
        let hasDigit = index < codeArray.count
        let isActive = index == codeArray.count && index < configuration.digitCount

        ZStack {
            RoundedRectangle(cornerRadius: theme.radius.md)
                .stroke(isActive ? theme.colors.primary : theme.colors.border, lineWidth: isActive ? 2 : 1)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.md)
                        .fill(theme.colors.surfaceElevated)
                )

            if hasDigit {
                if configuration.maskedEntry {
                    Circle()
                        .fill(theme.colors.textPrimary)
                        .frame(width: 10, height: 10)
                } else {
                    Text(String(codeArray[index]))
                        .font(theme.typography.title2)
                        .foregroundStyle(theme.colors.textPrimary)
                }
            }
        }
        .frame(width: 44, height: 56)
    }
}
```

- [ ] **5.2** Create `Sources/DesignFoundationBlocks/Auth/DFOTPBlock+Previews.swift`:

```swift
#if DEBUG
import SwiftUI
import DesignFoundation

#Preview("Default — Light", traits: .sizeThatFitsLayout) {
    DFOTPBlock(configuration: .init(
        onSubmit: { code in print("Submitted: \(code)") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
    .padding()
}

#Preview("Default — Dark", traits: .sizeThatFitsLayout) {
    DFOTPBlock(configuration: .init(
        onSubmit: { code in print("Submitted: \(code)") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.dark)
    .padding()
}

#Preview("With Subtitle — Light", traits: .sizeThatFitsLayout) {
    DFOTPBlock(configuration: .init(
        title: "Check your email",
        subtitle: "We sent a 6-digit code to hello@example.com",
        onSubmit: { code in print("Submitted: \(code)") },
        onResend: { print("Resend tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
    .padding()
}

#Preview("Masked Entry — Light", traits: .sizeThatFitsLayout) {
    DFOTPBlock(configuration: .init(
        maskedEntry: true,
        title: "Enter PIN",
        subtitle: "Your 6-digit security PIN",
        onSubmit: { code in print("Submitted: \(code)") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
    .padding()
}

#Preview("Masked Entry — Dark", traits: .sizeThatFitsLayout) {
    DFOTPBlock(configuration: .init(
        maskedEntry: true,
        title: "Enter PIN",
        onSubmit: { code in print("Submitted: \(code)") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.dark)
    .padding()
}

#Preview("4 Digit — Light", traits: .sizeThatFitsLayout) {
    DFOTPBlock(configuration: .init(
        digitCount: 4,
        title: "Enter code",
        subtitle: "We sent a 4-digit code to your phone",
        submitTitle: "Confirm",
        resendTitle: "Send again",
        onSubmit: { code in print("Submitted: \(code)") },
        onResend: { print("Resend tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
    .padding()
}
#endif
```

- [ ] **5.3** Create `Tests/DesignFoundationBlocksTests/Auth/DFOTPBlockTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFOTPBlock")
struct DFOTPBlockTests {

    @Test("Configuration defaults to 6 digits")
    func defaultDigitCount() {
        let config = DFOTPBlock.Configuration(onSubmit: { _ in })
        #expect(config.digitCount == 6)
    }

    @Test("Configuration custom digit count")
    func customDigitCount() {
        let config = DFOTPBlock.Configuration(digitCount: 4, onSubmit: { _ in })
        #expect(config.digitCount == 4)
    }

    @Test("Configuration maskedEntry defaults false")
    func maskedEntryDefault() {
        let config = DFOTPBlock.Configuration(onSubmit: { _ in })
        #expect(config.maskedEntry == false)
    }

    @Test("Configuration maskedEntry can be set true")
    func maskedEntryTrue() {
        let config = DFOTPBlock.Configuration(maskedEntry: true, onSubmit: { _ in })
        #expect(config.maskedEntry == true)
    }

    @Test("onSubmit closure is called with correct code")
    @MainActor
    func onSubmitFires() async {
        var received: String?
        let config = DFOTPBlock.Configuration(
            onSubmit: { code in received = code }
        )
        config.onSubmit("123456")
        #expect(received == "123456")
    }

    @Test("onResend closure fires when called")
    @MainActor
    func onResendFires() async {
        var fired = false
        let config = DFOTPBlock.Configuration(
            onSubmit: { _ in },
            onResend: { fired = true }
        )
        config.onResend?()
        #expect(fired == true)
    }

    @Test("onResend is nil by default")
    func onResendNilByDefault() {
        let config = DFOTPBlock.Configuration(onSubmit: { _ in })
        #expect(config.onResend == nil)
    }

    @Test("subtitle is nil by default")
    func subtitleNilByDefault() {
        let config = DFOTPBlock.Configuration(onSubmit: { _ in })
        #expect(config.subtitle == nil)
    }
}
```

- [ ] **5.4** Commit:
```bash
git add Sources/DesignFoundationBlocks/Auth/DFOTPBlock.swift \
        Sources/DesignFoundationBlocks/Auth/DFOTPBlock+Previews.swift \
        Tests/DesignFoundationBlocksTests/Auth/DFOTPBlockTests.swift
git commit -m "feat(otp): add DFOTPBlock with digit boxes, masked entry, and auto-submit"
```

---

## Task 6: DFWelcomeBlock

### Files

- Create: `Sources/DesignFoundationBlocks/Auth/DFWelcomeBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Auth/DFWelcomeBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Auth/DFWelcomeBlockTests.swift`

### Interfaces

```swift
public struct DFWelcomeBlock: View {
    public struct Configuration {
        public var logo: String?
        public var title: String
        public var subtitle: String?
        public var primaryActionTitle: String
        public var secondaryActionTitle: String?
        public var footnote: String?
        public var onPrimary: @MainActor () -> Void
        public var onSecondary: (@MainActor () -> Void)?
    }
}
```

### Steps

- [ ] **6.1** Create `Sources/DesignFoundationBlocks/Auth/DFWelcomeBlock.swift`:

```swift
import SwiftUI
import DesignFoundation

public struct DFWelcomeBlock: View {
    public struct Configuration: Sendable {
        public var logo: String?
        public var title: String
        public var subtitle: String?
        public var primaryActionTitle: String
        public var secondaryActionTitle: String?
        public var footnote: String?
        public var onPrimary: @MainActor () -> Void
        public var onSecondary: (@MainActor () -> Void)?

        public init(
            logo: String? = nil,
            title: String,
            subtitle: String? = nil,
            primaryActionTitle: String,
            secondaryActionTitle: String? = nil,
            footnote: String? = nil,
            onPrimary: @escaping @MainActor () -> Void,
            onSecondary: (@MainActor () -> Void)? = nil
        ) {
            self.logo = logo
            self.title = title
            self.subtitle = subtitle
            self.primaryActionTitle = primaryActionTitle
            self.secondaryActionTitle = secondaryActionTitle
            self.footnote = footnote
            self.onPrimary = onPrimary
            self.onSecondary = onSecondary
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(spacing: theme.spacing.lg) {
            Spacer()

            VStack(spacing: theme.spacing.md) {
                if let logo = configuration.logo {
                    Image(systemName: logo)
                        .font(.system(size: 72))
                        .foregroundStyle(theme.colors.primary)
                }

                Text(configuration.title)
                    .font(theme.typography.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)

                if let subtitle = configuration.subtitle {
                    Text(subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            VStack(spacing: theme.spacing.sm) {
                DFButton(configuration.primaryActionTitle) {
                    Task { @MainActor in configuration.onPrimary() }
                }

                if let secondaryTitle = configuration.secondaryActionTitle,
                   let onSecondary = configuration.onSecondary {
                    Button(secondaryTitle) {
                        Task { @MainActor in onSecondary() }
                    }
                    .font(theme.typography.callout)
                    .foregroundStyle(theme.colors.textSecondary)
                }

                if let footnote = configuration.footnote {
                    Text(footnote)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, theme.spacing.xs)
                }
            }
        }
        .padding(theme.spacing.xl)
    }
}
```

- [ ] **6.2** Create `Sources/DesignFoundationBlocks/Auth/DFWelcomeBlock+Previews.swift`:

```swift
#if DEBUG
import SwiftUI
import DesignFoundation

#Preview("Default — Light") {
    DFWelcomeBlock(configuration: .init(
        title: "Welcome Back",
        primaryActionTitle: "Sign In",
        onPrimary: { print("Primary tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("Default — Dark") {
    DFWelcomeBlock(configuration: .init(
        title: "Welcome Back",
        primaryActionTitle: "Sign In",
        onPrimary: { print("Primary tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.dark)
}

#Preview("With Logo — Light") {
    DFWelcomeBlock(configuration: .init(
        logo: "sparkles",
        title: "Welcome",
        primaryActionTitle: "Get Started",
        onPrimary: { print("Primary tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("With Logo — Dark") {
    DFWelcomeBlock(configuration: .init(
        logo: "sparkles",
        title: "Welcome",
        primaryActionTitle: "Get Started",
        onPrimary: { print("Primary tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.dark)
}

#Preview("Full — Light") {
    DFWelcomeBlock(configuration: .init(
        logo: "star.fill",
        title: "Meet Your App",
        subtitle: "Everything you need, all in one place. Start your free trial today.",
        primaryActionTitle: "Create Account",
        secondaryActionTitle: "I already have an account",
        footnote: "By continuing, you agree to our Terms of Service and Privacy Policy.",
        onPrimary: { print("Primary tapped") },
        onSecondary: { print("Secondary tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("Full — Dark") {
    DFWelcomeBlock(configuration: .init(
        logo: "star.fill",
        title: "Meet Your App",
        subtitle: "Everything you need, all in one place. Start your free trial today.",
        primaryActionTitle: "Create Account",
        secondaryActionTitle: "I already have an account",
        footnote: "By continuing, you agree to our Terms of Service and Privacy Policy.",
        onPrimary: { print("Primary tapped") },
        onSecondary: { print("Secondary tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.dark)
}
#endif
```

- [ ] **6.3** Create `Tests/DesignFoundationBlocksTests/Auth/DFWelcomeBlockTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFWelcomeBlock")
struct DFWelcomeBlockTests {

    @Test("Primary action fires")
    @MainActor
    func primaryFires() {
        var fired = false
        let config = DFWelcomeBlock.Configuration(
            title: "Welcome",
            primaryActionTitle: "Sign In",
            onPrimary: { fired = true }
        )
        config.onPrimary()
        #expect(fired == true)
    }

    @Test("Secondary action fires")
    @MainActor
    func secondaryFires() {
        var fired = false
        let config = DFWelcomeBlock.Configuration(
            title: "Welcome",
            primaryActionTitle: "Sign In",
            onPrimary: {},
            onSecondary: { fired = true }
        )
        config.onSecondary?()
        #expect(fired == true)
    }

    @Test("Logo is nil by default")
    func logoNilByDefault() {
        let config = DFWelcomeBlock.Configuration(
            title: "Welcome",
            primaryActionTitle: "Sign In",
            onPrimary: {}
        )
        #expect(config.logo == nil)
    }

    @Test("Logo can be set")
    func logoCanBeSet() {
        let config = DFWelcomeBlock.Configuration(
            logo: "sparkles",
            title: "Welcome",
            primaryActionTitle: "Sign In",
            onPrimary: {}
        )
        #expect(config.logo == "sparkles")
    }

    @Test("Subtitle is nil by default")
    func subtitleNilByDefault() {
        let config = DFWelcomeBlock.Configuration(
            title: "Welcome",
            primaryActionTitle: "Sign In",
            onPrimary: {}
        )
        #expect(config.subtitle == nil)
    }

    @Test("Footnote is nil by default")
    func footnoteNilByDefault() {
        let config = DFWelcomeBlock.Configuration(
            title: "Welcome",
            primaryActionTitle: "Sign In",
            onPrimary: {}
        )
        #expect(config.footnote == nil)
    }

    @Test("Secondary action is nil by default")
    func secondaryNilByDefault() {
        let config = DFWelcomeBlock.Configuration(
            title: "Welcome",
            primaryActionTitle: "Sign In",
            onPrimary: {}
        )
        #expect(config.onSecondary == nil)
    }
}
```

- [ ] **6.4** Commit:
```bash
git add Sources/DesignFoundationBlocks/Auth/DFWelcomeBlock.swift \
        Sources/DesignFoundationBlocks/Auth/DFWelcomeBlock+Previews.swift \
        Tests/DesignFoundationBlocksTests/Auth/DFWelcomeBlockTests.swift
git commit -m "feat(welcome): add DFWelcomeBlock with logo, subtitle, primary/secondary actions, and footnote"
```

---

## Task 7: DFFeatureCarouselBlock

### Files

- Create: `Sources/DesignFoundationBlocks/Onboarding/DFFeatureCarouselBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Onboarding/DFFeatureCarouselBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Onboarding/DFFeatureCarouselBlockTests.swift`

### Interfaces

```swift
public struct DFFeatureHighlight: Identifiable, Sendable { ... }

public struct DFFeatureCarouselBlock: View {
    public struct Configuration {
        public var features: [DFFeatureHighlight]
        public var continueTitle: String
        public var skipTitle: String?
        public var onContinue: @MainActor () -> Void
        public var onSkip: (@MainActor () -> Void)?
    }
    @State private var currentPage: Int = 0
}
```

### Steps

- [ ] **7.1** Create `Sources/DesignFoundationBlocks/Onboarding/DFFeatureCarouselBlock.swift`:

```swift
import SwiftUI
import DesignFoundation

public struct DFFeatureHighlight: Identifiable, Sendable {
    public let id: UUID
    public var icon: String
    public var title: String
    public var description: String
    public var accentColor: Color?

    public init(
        icon: String,
        title: String,
        description: String,
        accentColor: Color? = nil
    ) {
        self.id = UUID()
        self.icon = icon
        self.title = title
        self.description = description
        self.accentColor = accentColor
    }
}

public struct DFFeatureCarouselBlock: View {
    public struct Configuration: Sendable {
        public var features: [DFFeatureHighlight]
        public var continueTitle: String
        public var skipTitle: String?
        public var onContinue: @MainActor () -> Void
        public var onSkip: (@MainActor () -> Void)?

        public init(
            features: [DFFeatureHighlight],
            continueTitle: String = "Continue",
            skipTitle: String? = "Skip",
            onContinue: @escaping @MainActor () -> Void,
            onSkip: (@MainActor () -> Void)? = nil
        ) {
            self.features = features
            self.continueTitle = continueTitle
            self.skipTitle = skipTitle
            self.onContinue = onContinue
            self.onSkip = onSkip
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme
    @State private var currentPage: Int = 0

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(spacing: theme.spacing.lg) {
            TabView(selection: $currentPage) {
                ForEach(Array(configuration.features.enumerated()), id: \.element.id) { index, feature in
                    featurePage(feature)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: .infinity)

            // Manual page dots
            HStack(spacing: theme.spacing.xs) {
                ForEach(0..<configuration.features.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? theme.colors.primary : theme.colors.border)
                        .frame(width: index == currentPage ? 10 : 7, height: index == currentPage ? 10 : 7)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
            }
            .padding(.bottom, theme.spacing.sm)

            VStack(spacing: theme.spacing.sm) {
                DFButton(configuration.continueTitle) {
                    Task { @MainActor in configuration.onContinue() }
                }

                if let skipTitle = configuration.skipTitle,
                   let onSkip = configuration.onSkip {
                    Button(skipTitle) {
                        Task { @MainActor in onSkip() }
                    }
                    .font(theme.typography.callout)
                    .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .padding(.bottom, theme.spacing.xl)
        }
        .padding(.horizontal, theme.spacing.xl)
    }

    @ViewBuilder
    private func featurePage(_ feature: DFFeatureHighlight) -> some View {
        VStack(spacing: theme.spacing.lg) {
            Spacer()

            Image(systemName: feature.icon)
                .font(.system(size: 72))
                .foregroundStyle(feature.accentColor ?? theme.colors.primary)

            VStack(spacing: theme.spacing.sm) {
                Text(feature.title)
                    .font(theme.typography.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(feature.description)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, theme.spacing.md)
    }
}
```

- [ ] **7.2** Create `Sources/DesignFoundationBlocks/Onboarding/DFFeatureCarouselBlock+Previews.swift`:

```swift
#if DEBUG
import SwiftUI
import DesignFoundation

private let sampleFeatures: [DFFeatureHighlight] = [
    .init(icon: "bolt.fill", title: "Lightning Fast", description: "Everything loads instantly. No waiting, no delays."),
    .init(icon: "shield.fill", title: "Private & Secure", description: "Your data is encrypted end-to-end. Only you have access."),
    .init(icon: "heart.fill", title: "Made With Care", description: "Every detail crafted for the best possible experience.")
]

#Preview("Default — Light") {
    DFFeatureCarouselBlock(configuration: .init(
        features: sampleFeatures,
        onContinue: { print("Continue tapped") },
        onSkip: { print("Skip tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("Default — Dark") {
    DFFeatureCarouselBlock(configuration: .init(
        features: sampleFeatures,
        onContinue: { print("Continue tapped") },
        onSkip: { print("Skip tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.dark)
}

#Preview("Single Feature — Light") {
    DFFeatureCarouselBlock(configuration: .init(
        features: [
            .init(icon: "checkmark.seal.fill", title: "You're All Set", description: "Everything is configured and ready to go.")
        ],
        continueTitle: "Get Started",
        skipTitle: nil,
        onContinue: { print("Continue tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("No Skip — Light") {
    DFFeatureCarouselBlock(configuration: .init(
        features: sampleFeatures,
        skipTitle: nil,
        onContinue: { print("Continue tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("No Skip — Dark") {
    DFFeatureCarouselBlock(configuration: .init(
        features: sampleFeatures,
        skipTitle: nil,
        onContinue: { print("Continue tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.dark)
}

#Preview("Custom Accent — Light") {
    DFFeatureCarouselBlock(configuration: .init(
        features: [
            .init(icon: "flame.fill", title: "On Fire", description: "This feature is blazing fast.", accentColor: .orange),
            .init(icon: "leaf.fill", title: "Eco Friendly", description: "Designed with sustainability in mind.", accentColor: .green),
            .init(icon: "drop.fill", title: "Fluid", description: "Smooth as water in every interaction.", accentColor: .blue)
        ],
        onContinue: { print("Continue tapped") },
        onSkip: { print("Skip tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}
#endif
```

- [ ] **7.3** Create `Tests/DesignFoundationBlocksTests/Onboarding/DFFeatureCarouselBlockTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFFeatureCarouselBlock")
struct DFFeatureCarouselBlockTests {

    @Test("Feature count is preserved in configuration")
    func featureCount() {
        let features = [
            DFFeatureHighlight(icon: "bolt", title: "Fast", description: "Very fast"),
            DFFeatureHighlight(icon: "shield", title: "Safe", description: "Very safe")
        ]
        let config = DFFeatureCarouselBlock.Configuration(
            features: features,
            onContinue: {}
        )
        #expect(config.features.count == 2)
    }

    @Test("onContinue fires")
    @MainActor
    func onContinueFires() {
        var fired = false
        let config = DFFeatureCarouselBlock.Configuration(
            features: [.init(icon: "star", title: "Title", description: "Desc")],
            onContinue: { fired = true }
        )
        config.onContinue()
        #expect(fired == true)
    }

    @Test("onSkip fires")
    @MainActor
    func onSkipFires() {
        var fired = false
        let config = DFFeatureCarouselBlock.Configuration(
            features: [.init(icon: "star", title: "Title", description: "Desc")],
            onContinue: {},
            onSkip: { fired = true }
        )
        config.onSkip?()
        #expect(fired == true)
    }

    @Test("onSkip is nil when not provided")
    func onSkipNilByDefault() {
        let config = DFFeatureCarouselBlock.Configuration(
            features: [.init(icon: "star", title: "Title", description: "Desc")],
            skipTitle: nil,
            onContinue: {}
        )
        #expect(config.onSkip == nil)
    }

    @Test("DFFeatureHighlight has unique IDs")
    func featureHighlightUniqueIDs() {
        let a = DFFeatureHighlight(icon: "bolt", title: "A", description: "Desc A")
        let b = DFFeatureHighlight(icon: "star", title: "B", description: "Desc B")
        #expect(a.id != b.id)
    }

    @Test("DFFeatureHighlight accentColor defaults to nil")
    func accentColorDefaultsNil() {
        let feature = DFFeatureHighlight(icon: "bolt", title: "Title", description: "Desc")
        #expect(feature.accentColor == nil)
    }

    @Test("DFFeatureHighlight custom accentColor is preserved")
    func accentColorPreserved() {
        let feature = DFFeatureHighlight(icon: "bolt", title: "Title", description: "Desc", accentColor: .orange)
        #expect(feature.accentColor == .orange)
    }
}
```

- [ ] **7.4** Commit:
```bash
git add Sources/DesignFoundationBlocks/Onboarding/DFFeatureCarouselBlock.swift \
        Sources/DesignFoundationBlocks/Onboarding/DFFeatureCarouselBlock+Previews.swift \
        Tests/DesignFoundationBlocksTests/Onboarding/DFFeatureCarouselBlockTests.swift
git commit -m "feat(onboarding): add DFFeatureCarouselBlock with page dots and themed accent colors"
```

---

## Task 8: DFPermissionRequestBlock

### Files

- Create: `Sources/DesignFoundationBlocks/Onboarding/DFPermissionRequestBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Onboarding/DFPermissionRequestBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Onboarding/DFPermissionRequestBlockTests.swift`

### Interfaces

```swift
public enum DFPermissionType: Sendable { ... }

public struct DFPermissionRequestBlock: View {
    public struct Configuration {
        public var permissionType: DFPermissionType
        public var icon: String?
        public var title: String?
        public var description: String?
        public var allowTitle: String
        public var denyTitle: String?
        public var onAllow: @MainActor () -> Void
        public var onDeny: (@MainActor () -> Void)?
    }
}
```

### Steps

- [ ] **8.1** Create `Sources/DesignFoundationBlocks/Onboarding/DFPermissionRequestBlock.swift`:

```swift
import SwiftUI
import DesignFoundation

public enum DFPermissionType: Sendable {
    case camera
    case notifications
    case location
    case microphone
    case photos

    public var defaultIcon: String {
        switch self {
        case .camera: return "camera.fill"
        case .notifications: return "bell.fill"
        case .location: return "location.fill"
        case .microphone: return "mic.fill"
        case .photos: return "photo.fill"
        }
    }

    public var defaultTitle: String {
        switch self {
        case .camera: return "Allow Camera Access"
        case .notifications: return "Enable Notifications"
        case .location: return "Allow Location Access"
        case .microphone: return "Allow Microphone Access"
        case .photos: return "Allow Photo Access"
        }
    }

    public var defaultDescription: String {
        switch self {
        case .camera:
            return "We need access to your camera to let you scan documents and take photos within the app."
        case .notifications:
            return "Stay up to date with important updates, reminders, and messages by enabling notifications."
        case .location:
            return "Your location helps us show you relevant content and services near you."
        case .microphone:
            return "Microphone access lets you record voice notes and use voice commands within the app."
        case .photos:
            return "Photo access lets you select images from your library to use within the app."
        }
    }
}

public struct DFPermissionRequestBlock: View {
    public struct Configuration: Sendable {
        public var permissionType: DFPermissionType
        public var icon: String?
        public var title: String?
        public var description: String?
        public var allowTitle: String
        public var denyTitle: String?
        public var onAllow: @MainActor () -> Void
        public var onDeny: (@MainActor () -> Void)?

        public init(
            permissionType: DFPermissionType,
            icon: String? = nil,
            title: String? = nil,
            description: String? = nil,
            allowTitle: String = "Allow Access",
            denyTitle: String? = "Not Now",
            onAllow: @escaping @MainActor () -> Void,
            onDeny: (@MainActor () -> Void)? = nil
        ) {
            self.permissionType = permissionType
            self.icon = icon
            self.title = title
            self.description = description
            self.allowTitle = allowTitle
            self.denyTitle = denyTitle
            self.onAllow = onAllow
            self.onDeny = onDeny
        }

        var resolvedIcon: String { icon ?? permissionType.defaultIcon }
        var resolvedTitle: String { title ?? permissionType.defaultTitle }
        var resolvedDescription: String { description ?? permissionType.defaultDescription }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(spacing: theme.spacing.xl) {
            Spacer()

            VStack(spacing: theme.spacing.lg) {
                Image(systemName: configuration.resolvedIcon)
                    .font(.system(size: 56))
                    .foregroundStyle(theme.colors.primary)

                VStack(spacing: theme.spacing.sm) {
                    Text(configuration.resolvedTitle)
                        .font(theme.typography.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(configuration.resolvedDescription)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            VStack(spacing: theme.spacing.sm) {
                DFButton(configuration.allowTitle) {
                    Task { @MainActor in configuration.onAllow() }
                }

                if let denyTitle = configuration.denyTitle,
                   let onDeny = configuration.onDeny {
                    Button(denyTitle) {
                        Task { @MainActor in onDeny() }
                    }
                    .font(theme.typography.callout)
                    .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .padding(.bottom, theme.spacing.xl)
        }
        .padding(.horizontal, theme.spacing.xl)
    }
}
```

- [ ] **8.2** Create `Sources/DesignFoundationBlocks/Onboarding/DFPermissionRequestBlock+Previews.swift`:

```swift
#if DEBUG
import SwiftUI
import DesignFoundation

#Preview("Camera — Light") {
    DFPermissionRequestBlock(configuration: .init(
        permissionType: .camera,
        onAllow: { print("Allow tapped") },
        onDeny: { print("Deny tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("Camera — Dark") {
    DFPermissionRequestBlock(configuration: .init(
        permissionType: .camera,
        onAllow: { print("Allow tapped") },
        onDeny: { print("Deny tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.dark)
}

#Preview("Notifications — Light") {
    DFPermissionRequestBlock(configuration: .init(
        permissionType: .notifications,
        onAllow: { print("Allow tapped") },
        onDeny: { print("Deny tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("Notifications — Dark") {
    DFPermissionRequestBlock(configuration: .init(
        permissionType: .notifications,
        onAllow: { print("Allow tapped") },
        onDeny: { print("Deny tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.dark)
}

#Preview("Location — Light") {
    DFPermissionRequestBlock(configuration: .init(
        permissionType: .location,
        onAllow: { print("Allow tapped") },
        onDeny: { print("Deny tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("Custom Override — Light") {
    DFPermissionRequestBlock(configuration: .init(
        permissionType: .camera,
        icon: "qrcode.viewfinder",
        title: "Scan QR Codes",
        description: "Point your camera at a QR code to instantly join groups, add contacts, and more.",
        allowTitle: "Enable Camera",
        denyTitle: "Maybe Later",
        onAllow: { print("Allow tapped") },
        onDeny: { print("Deny tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}
#endif
```

- [ ] **8.3** Create `Tests/DesignFoundationBlocksTests/Onboarding/DFPermissionRequestBlockTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFPermissionRequestBlock")
struct DFPermissionRequestBlockTests {

    @Test("Camera uses default icon")
    func cameraDefaultIcon() {
        #expect(DFPermissionType.camera.defaultIcon == "camera.fill")
    }

    @Test("Notifications uses default icon")
    func notificationsDefaultIcon() {
        #expect(DFPermissionType.notifications.defaultIcon == "bell.fill")
    }

    @Test("Location uses default icon")
    func locationDefaultIcon() {
        #expect(DFPermissionType.location.defaultIcon == "location.fill")
    }

    @Test("Microphone uses default icon")
    func microphoneDefaultIcon() {
        #expect(DFPermissionType.microphone.defaultIcon == "mic.fill")
    }

    @Test("Photos uses default icon")
    func photosDefaultIcon() {
        #expect(DFPermissionType.photos.defaultIcon == "photo.fill")
    }

    @Test("Custom icon overrides default")
    func customIconOverridesDefault() {
        let config = DFPermissionRequestBlock.Configuration(
            permissionType: .camera,
            icon: "qrcode.viewfinder",
            onAllow: {}
        )
        #expect(config.resolvedIcon == "qrcode.viewfinder")
    }

    @Test("Custom title overrides default")
    func customTitleOverridesDefault() {
        let config = DFPermissionRequestBlock.Configuration(
            permissionType: .camera,
            title: "Scan Documents",
            onAllow: {}
        )
        #expect(config.resolvedTitle == "Scan Documents")
    }

    @Test("Custom description overrides default")
    func customDescriptionOverridesDefault() {
        let config = DFPermissionRequestBlock.Configuration(
            permissionType: .notifications,
            description: "Custom description here.",
            onAllow: {}
        )
        #expect(config.resolvedDescription == "Custom description here.")
    }

    @Test("onAllow fires")
    @MainActor
    func onAllowFires() {
        var fired = false
        let config = DFPermissionRequestBlock.Configuration(
            permissionType: .notifications,
            onAllow: { fired = true }
        )
        config.onAllow()
        #expect(fired == true)
    }

    @Test("onDeny fires")
    @MainActor
    func onDenyFires() {
        var fired = false
        let config = DFPermissionRequestBlock.Configuration(
            permissionType: .location,
            onAllow: {},
            onDeny: { fired = true }
        )
        config.onDeny?()
        #expect(fired == true)
    }
}
```

- [ ] **8.4** Commit:
```bash
git add Sources/DesignFoundationBlocks/Onboarding/DFPermissionRequestBlock.swift \
        Sources/DesignFoundationBlocks/Onboarding/DFPermissionRequestBlock+Previews.swift \
        Tests/DesignFoundationBlocksTests/Onboarding/DFPermissionRequestBlockTests.swift
git commit -m "feat(onboarding): add DFPermissionRequestBlock with permission type defaults and overrides"
```

---

## Task 9: DFPlanSelectionBlock

### Files

- Create: `Sources/DesignFoundationBlocks/Onboarding/DFPlanSelectionBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Onboarding/DFPlanSelectionBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Onboarding/DFPlanSelectionBlockTests.swift`

### Interfaces

```swift
public struct DFPricingTier: Identifiable, Sendable { ... }

public struct DFPlanSelectionBlock: View {
    public struct Configuration {
        public var title: String
        public var tiers: [DFPricingTier]
        public var selectTitle: String
        public var onSelect: @MainActor (DFPricingTier) -> Void
    }
    @State private var selectedID: UUID?
}
```

### Steps

- [ ] **9.1** Create `Sources/DesignFoundationBlocks/Onboarding/DFPlanSelectionBlock.swift`:

```swift
import SwiftUI
import DesignFoundation

public struct DFPricingTier: Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var price: String
    public var period: String
    public var features: [String]
    public var isPopular: Bool
    public var badge: String?

    public init(
        name: String,
        price: String,
        period: String,
        features: [String],
        isPopular: Bool = false,
        badge: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.price = price
        self.period = period
        self.features = features
        self.isPopular = isPopular
        self.badge = badge
    }
}

public struct DFPlanSelectionBlock: View {
    public struct Configuration: Sendable {
        public var title: String
        public var tiers: [DFPricingTier]
        public var selectTitle: String
        public var onSelect: @MainActor (DFPricingTier) -> Void

        public init(
            title: String = "Choose your plan",
            tiers: [DFPricingTier],
            selectTitle: String = "Get Started",
            onSelect: @escaping @MainActor (DFPricingTier) -> Void
        ) {
            self.title = title
            self.tiers = tiers
            self.selectTitle = selectTitle
            self.onSelect = onSelect
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme
    @State private var selectedID: UUID?

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                Text(configuration.title)
                    .font(theme.typography.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top, theme.spacing.xl)

                VStack(spacing: theme.spacing.md) {
                    ForEach(configuration.tiers) { tier in
                        tierCard(tier)
                    }
                }

                DFButton(configuration.selectTitle) {
                    guard let selectedID,
                          let tier = configuration.tiers.first(where: { $0.id == selectedID }) else { return }
                    Task { @MainActor in configuration.onSelect(tier) }
                }
                .disabled(selectedID == nil)
                .padding(.bottom, theme.spacing.xl)
            }
            .padding(.horizontal, theme.spacing.xl)
        }
    }

    @ViewBuilder
    private func tierCard(_ tier: DFPricingTier) -> some View {
        let isSelected = selectedID == tier.id

        Button {
            selectedID = tier.id
        } label: {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        HStack(alignment: .center, spacing: theme.spacing.sm) {
                            Text(tier.name)
                                .font(theme.typography.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(theme.colors.textPrimary)

                            if let badge = tier.badge ?? (tier.isPopular ? "Most Popular" : nil) {
                                Text(badge)
                                    .font(theme.typography.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(theme.colors.surface)
                                    .padding(.horizontal, theme.spacing.sm)
                                    .padding(.vertical, theme.spacing.xs)
                                    .background(theme.colors.primary)
                                    .clipShape(Capsule())
                            }
                        }

                        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                            Text(tier.price)
                                .font(theme.typography.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(tier.period)
                                .font(theme.typography.callout)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(isSelected ? theme.colors.primary : theme.colors.border)
                }

                if !tier.features.isEmpty {
                    Divider()
                        .background(theme.colors.border)

                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        ForEach(tier.features, id: \.self) { feature in
                            HStack(alignment: .top, spacing: theme.spacing.sm) {
                                Image(systemName: "checkmark")
                                    .font(theme.typography.footnote)
                                    .foregroundStyle(theme.colors.primary)
                                Text(feature)
                                    .font(theme.typography.callout)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                        }
                    }
                }
            }
            .padding(theme.spacing.lg)
            .background(theme.colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.lg)
                    .stroke(isSelected ? theme.colors.primary : theme.colors.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
```

- [ ] **9.2** Create `Sources/DesignFoundationBlocks/Onboarding/DFPlanSelectionBlock+Previews.swift`:

```swift
#if DEBUG
import SwiftUI
import DesignFoundation

private let freeTier = DFPricingTier(
    name: "Free",
    price: "$0",
    period: "forever",
    features: ["Up to 3 projects", "5 GB storage", "Community support"]
)

private let proTier = DFPricingTier(
    name: "Pro",
    price: "$12",
    period: "/ month",
    features: ["Unlimited projects", "100 GB storage", "Priority support", "Advanced analytics", "Custom integrations"],
    isPopular: true
)

private let enterpriseTier = DFPricingTier(
    name: "Enterprise",
    price: "$49",
    period: "/ month",
    features: ["Everything in Pro", "1 TB storage", "Dedicated support", "SSO & SAML", "SLA guarantee"],
    badge: "Best Value"
)

#Preview("Default — Light (2 tiers, 1 popular)") {
    DFPlanSelectionBlock(configuration: .init(
        tiers: [freeTier, proTier],
        onSelect: { tier in print("Selected: \(tier.name)") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("Default — Dark") {
    DFPlanSelectionBlock(configuration: .init(
        tiers: [freeTier, proTier],
        onSelect: { tier in print("Selected: \(tier.name)") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.dark)
}

#Preview("Three Tiers — Light") {
    DFPlanSelectionBlock(configuration: .init(
        tiers: [freeTier, proTier, enterpriseTier],
        onSelect: { tier in print("Selected: \(tier.name)") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("Three Tiers — Dark") {
    DFPlanSelectionBlock(configuration: .init(
        tiers: [freeTier, proTier, enterpriseTier],
        onSelect: { tier in print("Selected: \(tier.name)") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.dark)
}

#Preview("Selected State — Light") {
    // Demonstrates the selected border highlight
    DFPlanSelectionBlock(configuration: .init(
        title: "Upgrade your plan",
        tiers: [freeTier, proTier],
        selectTitle: "Upgrade Now",
        onSelect: { tier in print("Selected: \(tier.name)") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("Single Tier — Light") {
    DFPlanSelectionBlock(configuration: .init(
        title: "Start your trial",
        tiers: [proTier],
        selectTitle: "Start Free Trial",
        onSelect: { tier in print("Selected: \(tier.name)") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}
#endif
```

- [ ] **9.3** Create `Tests/DesignFoundationBlocksTests/Onboarding/DFPlanSelectionBlockTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFPlanSelectionBlock")
struct DFPlanSelectionBlockTests {

    private func makeTier(name: String = "Pro", isPopular: Bool = false) -> DFPricingTier {
        DFPricingTier(
            name: name,
            price: "$9",
            period: "/ month",
            features: ["Feature A", "Feature B"],
            isPopular: isPopular
        )
    }

    @Test("DFPricingTier has unique IDs")
    func uniqueIDs() {
        let a = makeTier(name: "Free")
        let b = makeTier(name: "Pro")
        #expect(a.id != b.id)
    }

    @Test("isPopular defaults to false")
    func isPopularDefault() {
        let tier = makeTier()
        #expect(tier.isPopular == false)
    }

    @Test("badge defaults to nil")
    func badgeDefault() {
        let tier = makeTier()
        #expect(tier.badge == nil)
    }

    @Test("Configuration preserves tier count")
    func tierCount() {
        let tiers = [makeTier(name: "Free"), makeTier(name: "Pro")]
        let config = DFPlanSelectionBlock.Configuration(
            tiers: tiers,
            onSelect: { _ in }
        )
        #expect(config.tiers.count == 2)
    }

    @Test("onSelect fires with correct tier")
    @MainActor
    func onSelectFires() {
        let tier = makeTier(name: "Pro")
        var received: DFPricingTier?
        let config = DFPlanSelectionBlock.Configuration(
            tiers: [tier],
            onSelect: { received = $0 }
        )
        config.onSelect(tier)
        #expect(received?.name == "Pro")
    }

    @Test("onSelect passes correct tier ID")
    @MainActor
    func onSelectPassesCorrectID() {
        let tier = makeTier(name: "Enterprise")
        var receivedID: UUID?
        let config = DFPlanSelectionBlock.Configuration(
            tiers: [tier],
            onSelect: { receivedID = $0.id }
        )
        config.onSelect(tier)
        #expect(receivedID == tier.id)
    }

    @Test("Default title is 'Choose your plan'")
    func defaultTitle() {
        let config = DFPlanSelectionBlock.Configuration(
            tiers: [makeTier()],
            onSelect: { _ in }
        )
        #expect(config.title == "Choose your plan")
    }

    @Test("Default selectTitle is 'Get Started'")
    func defaultSelectTitle() {
        let config = DFPlanSelectionBlock.Configuration(
            tiers: [makeTier()],
            onSelect: { _ in }
        )
        #expect(config.selectTitle == "Get Started")
    }
}
```

- [ ] **9.4** Commit:
```bash
git add Sources/DesignFoundationBlocks/Onboarding/DFPlanSelectionBlock.swift \
        Sources/DesignFoundationBlocks/Onboarding/DFPlanSelectionBlock+Previews.swift \
        Tests/DesignFoundationBlocksTests/Onboarding/DFPlanSelectionBlockTests.swift
git commit -m "feat(onboarding): add DFPlanSelectionBlock with tier cards, popular badge, and selection state"
```

---

## Task 10: DFSuccessBlock

### Files

- Create: `Sources/DesignFoundationBlocks/Onboarding/DFSuccessBlock.swift`
- Create: `Sources/DesignFoundationBlocks/Onboarding/DFSuccessBlock+Previews.swift`
- Create: `Tests/DesignFoundationBlocksTests/Onboarding/DFSuccessBlockTests.swift`

### Interfaces

```swift
public struct DFSuccessBlock: View {
    public struct Configuration {
        public var icon: String
        public var iconColor: Color?
        public var title: String
        public var message: String?
        public var primaryActionTitle: String?
        public var secondaryActionTitle: String?
        public var animated: Bool
        public var onPrimary: (@MainActor () -> Void)?
        public var onSecondary: (@MainActor () -> Void)?
    }
    @State private var appeared = false
}
```

### Steps

- [ ] **10.1** Create `Sources/DesignFoundationBlocks/Onboarding/DFSuccessBlock.swift`:

```swift
import SwiftUI
import DesignFoundation

public struct DFSuccessBlock: View {
    public struct Configuration: Sendable {
        public var icon: String
        public var iconColor: Color?
        public var title: String
        public var message: String?
        public var primaryActionTitle: String?
        public var secondaryActionTitle: String?
        public var animated: Bool
        public var onPrimary: (@MainActor () -> Void)?
        public var onSecondary: (@MainActor () -> Void)?

        public init(
            icon: String = "checkmark.circle.fill",
            iconColor: Color? = nil,
            title: String,
            message: String? = nil,
            primaryActionTitle: String? = nil,
            secondaryActionTitle: String? = nil,
            animated: Bool = true,
            onPrimary: (@MainActor () -> Void)? = nil,
            onSecondary: (@MainActor () -> Void)? = nil
        ) {
            self.icon = icon
            self.iconColor = iconColor
            self.title = title
            self.message = message
            self.primaryActionTitle = primaryActionTitle
            self.secondaryActionTitle = secondaryActionTitle
            self.animated = animated
            self.onPrimary = onPrimary
            self.onSecondary = onSecondary
        }
    }

    private let configuration: Configuration
    @Environment(\.dfTheme) private var theme
    @State private var appeared = false

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(spacing: theme.spacing.xl) {
            Spacer()

            VStack(spacing: theme.spacing.lg) {
                Image(systemName: configuration.icon)
                    .font(.system(size: 72))
                    .foregroundStyle(configuration.iconColor ?? theme.colors.success)
                    .scaleEffect(configuration.animated ? (appeared ? 1.0 : 0.5) : 1.0)
                    .opacity(configuration.animated ? (appeared ? 1.0 : 0.0) : 1.0)

                VStack(spacing: theme.spacing.sm) {
                    Text(configuration.title)
                        .font(theme.typography.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.colors.textPrimary)
                        .multilineTextAlignment(.center)

                    if let message = configuration.message {
                        Text(message)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }

            Spacer()

            if configuration.onPrimary != nil || configuration.onSecondary != nil {
                VStack(spacing: theme.spacing.sm) {
                    if let primaryTitle = configuration.primaryActionTitle,
                       let onPrimary = configuration.onPrimary {
                        DFButton(primaryTitle) {
                            Task { @MainActor in onPrimary() }
                        }
                    }

                    if let secondaryTitle = configuration.secondaryActionTitle,
                       let onSecondary = configuration.onSecondary {
                        Button(secondaryTitle) {
                            Task { @MainActor in onSecondary() }
                        }
                        .font(theme.typography.callout)
                        .foregroundStyle(theme.colors.textSecondary)
                    }
                }
                .padding(.bottom, theme.spacing.xl)
            }
        }
        .padding(.horizontal, theme.spacing.xl)
        .onAppear {
            guard configuration.animated else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                appeared = true
            }
        }
    }
}
```

- [ ] **10.2** Create `Sources/DesignFoundationBlocks/Onboarding/DFSuccessBlock+Previews.swift`:

```swift
#if DEBUG
import SwiftUI
import DesignFoundation

#Preview("Default — Light") {
    DFSuccessBlock(configuration: .init(
        title: "You're all set!"
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("Default — Dark") {
    DFSuccessBlock(configuration: .init(
        title: "You're all set!"
    ))
    .dfTheme(.default)
    .preferredColorScheme(.dark)
}

#Preview("Animated — Light") {
    DFSuccessBlock(configuration: .init(
        title: "Account Created",
        message: "Welcome aboard! Your account is ready to use.",
        animated: true
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("No Animation — Light") {
    DFSuccessBlock(configuration: .init(
        title: "Payment Confirmed",
        message: "Your payment was processed successfully.",
        animated: false
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("With Actions — Light") {
    DFSuccessBlock(configuration: .init(
        title: "Order Placed!",
        message: "We'll send you a confirmation email shortly.",
        primaryActionTitle: "Track Order",
        secondaryActionTitle: "Continue Shopping",
        animated: true,
        onPrimary: { print("Track tapped") },
        onSecondary: { print("Continue tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}

#Preview("With Actions — Dark") {
    DFSuccessBlock(configuration: .init(
        title: "Order Placed!",
        message: "We'll send you a confirmation email shortly.",
        primaryActionTitle: "Track Order",
        secondaryActionTitle: "Continue Shopping",
        animated: true,
        onPrimary: { print("Track tapped") },
        onSecondary: { print("Continue tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.dark)
}

#Preview("Custom Icon Color — Light") {
    DFSuccessBlock(configuration: .init(
        icon: "star.fill",
        iconColor: .yellow,
        title: "Achievement Unlocked",
        message: "You've completed your first project. Keep it up!",
        primaryActionTitle: "View Achievements",
        animated: true,
        onPrimary: { print("View tapped") }
    ))
    .dfTheme(.default)
    .preferredColorScheme(.light)
}
#endif
```

- [ ] **10.3** Create `Tests/DesignFoundationBlocksTests/Onboarding/DFSuccessBlockTests.swift`:

```swift
import Testing
import SwiftUI
@testable import DesignFoundationBlocks

@Suite("DFSuccessBlock")
struct DFSuccessBlockTests {

    @Test("Default icon is checkmark.circle.fill")
    func defaultIcon() {
        let config = DFSuccessBlock.Configuration(title: "Done")
        #expect(config.icon == "checkmark.circle.fill")
    }

    @Test("Custom icon is preserved")
    func customIcon() {
        let config = DFSuccessBlock.Configuration(icon: "star.fill", title: "Done")
        #expect(config.icon == "star.fill")
    }

    @Test("iconColor defaults to nil")
    func iconColorDefaultsNil() {
        let config = DFSuccessBlock.Configuration(title: "Done")
        #expect(config.iconColor == nil)
    }

    @Test("iconColor can be set")
    func iconColorSet() {
        let config = DFSuccessBlock.Configuration(icon: "star.fill", iconColor: .yellow, title: "Done")
        #expect(config.iconColor == .yellow)
    }

    @Test("animated defaults to true")
    func animatedDefault() {
        let config = DFSuccessBlock.Configuration(title: "Done")
        #expect(config.animated == true)
    }

    @Test("animated can be disabled")
    func animatedDisabled() {
        let config = DFSuccessBlock.Configuration(title: "Done", animated: false)
        #expect(config.animated == false)
    }

    @Test("message defaults to nil")
    func messageDefaultNil() {
        let config = DFSuccessBlock.Configuration(title: "Done")
        #expect(config.message == nil)
    }

    @Test("onPrimary fires")
    @MainActor
    func onPrimaryFires() {
        var fired = false
        let config = DFSuccessBlock.Configuration(
            title: "Done",
            primaryActionTitle: "Continue",
            onPrimary: { fired = true }
        )
        config.onPrimary?()
        #expect(fired == true)
    }

    @Test("onSecondary fires")
    @MainActor
    func onSecondaryFires() {
        var fired = false
        let config = DFSuccessBlock.Configuration(
            title: "Done",
            secondaryActionTitle: "Go Back",
            onSecondary: { fired = true }
        )
        config.onSecondary?()
        #expect(fired == true)
    }

    @Test("onPrimary is nil by default")
    func onPrimaryNilDefault() {
        let config = DFSuccessBlock.Configuration(title: "Done")
        #expect(config.onPrimary == nil)
    }

    @Test("onSecondary is nil by default")
    func onSecondaryNilDefault() {
        let config = DFSuccessBlock.Configuration(title: "Done")
        #expect(config.onSecondary == nil)
    }
}
```

- [ ] **10.4** Commit:
```bash
git add Sources/DesignFoundationBlocks/Onboarding/DFSuccessBlock.swift \
        Sources/DesignFoundationBlocks/Onboarding/DFSuccessBlock+Previews.swift \
        Tests/DesignFoundationBlocksTests/Onboarding/DFSuccessBlockTests.swift
git commit -m "feat(onboarding): add DFSuccessBlock with spring animation, custom icon color, and optional actions"
```

---

## Summary

| Task | Block | Files | Tests |
|------|-------|-------|-------|
| 5 | DFOTPBlock | Auth/DFOTPBlock.swift + Previews | 8 tests |
| 6 | DFWelcomeBlock | Auth/DFWelcomeBlock.swift + Previews | 7 tests |
| 7 | DFFeatureCarouselBlock | Onboarding/DFFeatureCarouselBlock.swift + Previews | 7 tests |
| 8 | DFPermissionRequestBlock | Onboarding/DFPermissionRequestBlock.swift + Previews | 9 tests |
| 9 | DFPlanSelectionBlock | Onboarding/DFPlanSelectionBlock.swift + Previews | 8 tests |
| 10 | DFSuccessBlock | Onboarding/DFSuccessBlock.swift + Previews | 11 tests |

**Total:** 18 source files, 50 tests, 36 previews (6 per block minimum).
