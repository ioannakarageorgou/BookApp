// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BookAPIClient",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "BookAPIClient",
            targets: ["BookAPIClient"]),
    ],
    dependencies: [
        .package(path: "../NetworkClient")
    ],
    targets: [
        .target(
            name: "BookAPIClient",
            dependencies: ["NetworkClient"]
        ),
        .testTarget(
            name: "BookAPIClientTests",
            dependencies: ["BookAPIClient", "NetworkClient"]
        ),
    ]
)
