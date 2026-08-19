// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DesignFoundation",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .visionOS(.v2)
    ],
    products: [
        .library(name: "DesignFoundation", targets: ["DesignFoundation"])
    ],
    targets: [
        .target(
            name: "DesignFoundation",
            path: "Sources/DesignFoundation",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "DesignFoundationTests",
            dependencies: ["DesignFoundation"],
            path: "Tests/DesignFoundationTests"
        ),
        // Compiles every ```swift fence in CLAUDE.md/AGENTS.md/.cursor rules/docs against the
        // real package — see scripts/check_doc_snippets.py. Not part of the public library
        // product; only built by that script (locally or in CI) to catch doc/code drift.
        // A plain library target, not executable — the generated snippet files only need
        // to *compile* (function declarations), there's nothing to run.
        .target(
            name: "DocSnippetCheck",
            dependencies: ["DesignFoundation"],
            path: "scripts/DocSnippetCheck/Generated"
        )
    ]
)
