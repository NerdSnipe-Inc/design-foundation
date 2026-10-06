import SwiftUI

#if DEBUG

private struct DFAccordionControlledPreview: View {
    @State private var isExpanded = true

    var body: some View {
        VStack(spacing: 0) {
            DFAccordion("Shipping", subtitle: "2-4 business days", icon: "shippingbox", isExpanded: $isExpanded) {
                DFText("Free standard shipping on orders over $50.")
            }
            DFAccordion("Returns") {
                DFText("Return any item within 30 days.")
            }
        }
        .padding()
    }
}

#Preview("Controlled and uncontrolled") {
    DFAccordionControlledPreview()
}

#Preview("Exclusive group") {
    DFAccordionGroup(initiallyExpanded: ["a"]) {
        DFAccordion("What is DesignFoundation?", id: "a") {
            DFText("A SwiftUI design system with themeable components.")
        }
        DFAccordion("Does it support dark mode?", id: "b") {
            DFText("Yes, every preset ships a light and a dark theme.")
        }
        DFAccordion("Is it accessible?", id: "c") {
            DFText("Yes: Dynamic Type, VoiceOver and Reduce Motion are handled.")
        }
    }
    .padding()
}

#Preview("Multi-open group") {
    DFAccordionGroup(allowsMultipleExpanded: true, initiallyExpanded: ["a", "b"]) {
        DFAccordion("First", id: "a", icon: "1.circle") {
            DFText("First body.")
        }
        DFAccordion("Second", id: "b", icon: "2.circle") {
            DFText("Second body.")
        }
        DFAccordion("Third", id: "c", icon: "3.circle") {
            DFText("Third body.")
        }
    }
    .padding()
}

#Preview("Card style") {
    DFAccordionGroup {
        DFAccordion("Billing", id: "billing", subtitle: "Plans and invoices") {
            DFText("Manage your plan and download invoices.")
        }
        DFAccordion("Security", id: "security") {
            DFText("Two-factor authentication and active sessions.")
        }
    }
    .dfAccordionStyle(.card)
    .padding()
}

#Preview("Plain style") {
    DFAccordionGroup(allowsMultipleExpanded: true, initiallyExpanded: ["a"]) {
        DFAccordion("Details", id: "a") {
            DFText("Plain style has no divider or surface.")
        }
        DFAccordion("More", id: "b") {
            DFText("Hidden until expanded.")
        }
    }
    .dfAccordionStyle(.plain)
    .padding()
}

#Preview("Dark mode") {
    DFAccordionGroup(initiallyExpanded: ["a"]) {
        DFAccordion("Dark accordion", id: "a", subtitle: "Subtitle") {
            DFText("Body copy.")
        }
        DFAccordion("Another", id: "b") {
            DFText("More body copy.")
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}

#endif
