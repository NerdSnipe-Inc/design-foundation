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
        )
    ]
)
