// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedUI",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SharedUI",
            targets: ["SharedUI"]),
    ],
    targets: [
        .target(
            name: "SharedUI",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SharedUITests",
            dependencies: ["SharedUI"]
        ),
    ]
)
