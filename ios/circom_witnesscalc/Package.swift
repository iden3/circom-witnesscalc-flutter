// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "circom_witnesscalc",
    platforms: [
        .iOS("12.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "circom-witnesscalc", targets: ["circom_witnesscalc"])
    ],
    dependencies: [
        .package(url: "https://github.com/iden3/circom-witnesscalc-swift.git", from: "0.0.1-alpha.3")
    ],
    targets: [
        .target(
            name: "circom_witnesscalc",
            dependencies: [
                .product(name: "CircomWitnesscalc", package: "circom-witnesscalc-swift")
            ],
            resources: []
        )
    ]
)
