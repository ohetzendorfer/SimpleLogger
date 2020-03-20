// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleLogger",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "SimpleLogger",
            targets: ["SimpleLogger"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SimpleLogger",
            dependencies: []),
        .testTarget(
            name: "SimpleLoggerTests",
            dependencies: ["SimpleLogger"]),
    ]
)
