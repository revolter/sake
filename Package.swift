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
    ],
    targets: [
        .target(name: "SakefileDescription", dependencies: []),
        .target(name: "sake", dependencies: ["SakefileDescription"])
        // .testTarget(name: "DangerTests", dependencies: ["Danger"]),
    ],
    swiftLanguageVersions: [4]
)
