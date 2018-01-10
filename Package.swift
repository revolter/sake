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
        .package(url: "https://github.com/kylef/PathKit.git", .upToNextMajor(from: "0.9.0")),
        .package(url: "https://github.com/xcodeswift/xcproj.git", .upToNextMajor(from: "1.7.0")),
        .package(url: "https://github.com/kylef/Commander.git", .upToNextMajor(from: "0.8.0")),
        .package(url: "https://github.com/kareman/SwiftShell.git", .upToNextMajor(from: "4.0.0"))
    ],
    targets: [
        .target(name: "SakeKit", dependencies: ["xcproj", "PathKit", "SwiftShell"]),
        .target(name: "SakefileDescription", dependencies: ["SwiftShell"]),
        .target(name: "sake", dependencies: ["Commander", "SakefileDescription", "SakeKit"]),
        .testTarget(name: "SakeKitTests", dependencies: ["SakeKit"]),
        .testTarget(name: "SakefileDescriptionTests", dependencies: ["SakefileDescription"]),
    ],
    swiftLanguageVersions: [4]
)
