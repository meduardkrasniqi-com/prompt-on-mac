// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PromptOnMac",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "PromptOnMac",
            path: "Sources/PromptOnMac"
        )
    ],
    swiftLanguageModes: [.v5]
)
