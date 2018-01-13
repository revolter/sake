// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sake",
    products: [
        .library(name: "SakefileDescriptionV1", type: .dynamic, targets: ["SakefileDescriptionV1"]),
        .executable(name: "sake", targets: ["sake"])
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit.git", .upToNextMajor(from: "0.9.0")),
        .package(url: "https://github.com/xcodeswift/xcproj.git", .upToNextMajor(from: "1.7.0")),
        .package(url: "https://github.com/kylef/Commander.git", .upToNextMajor(from: "0.8.0")),
        .package(url: "https://github.com/xcodeswift/SwiftShell.git", .revision("12d47f0ed2f9a8dc11b4bb6a0d9ba3d0cb053a56"))
    ],
    targets: [
        .target(name: "SakeKit", dependencies: ["xcproj", "PathKit", "SakefileDescriptionV1"]),
        .target(name: "SakefileDescriptionV1", dependencies: ["SwiftShell"]),
        .target(name: "sake", dependencies: ["Commander", "SakeKit"]),
        .testTarget(name: "SakeKitTests", dependencies: ["SakeKit"]),
        .testTarget(name: "SakefileDescriptionV1Tests", dependencies: ["SakefileDescriptionV1"]),
    ],
    swiftLanguageVersions: [4]
)
