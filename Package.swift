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
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0")
    ],
    targets: [
        .target(name: "SakefileDescription", dependencies: []),
        .target(name: "sake", dependencies: ["SakefileDescription", "Commander"]),
        .testTarget(name: "sakeTests", dependencies: ["sake"])
    ],
    swiftLanguageVersions: [4]
)
