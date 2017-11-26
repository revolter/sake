// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sake",
    products: [
        .library(name: "SakefileDescription", type: .dynamic, targets: ["SakefileDescription"]),
        .executable(name: "sake", targets: ["sake"])
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.8.0"),
        .package(url: "https://github.com/yonaskolb/XcodeGen.git", from: "1.4.0"),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.6.1"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "4.0.0")
    ],
    targets: [
        .target(name: "SakeKit", dependencies: ["XcodeGenKit","PathKit", "SwiftShell"]),
        .target(name: "SakefileDescription", dependencies: []),
        .target(name: "sake", dependencies: ["Commander", "SakefileDescription", "SakeKit"]),
        .testTarget(name: "SakeKitTests", dependencies: ["SakeKit"])
    ],
    swiftLanguageVersions: [4]
)
