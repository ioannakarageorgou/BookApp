// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BookAPIClient",
    platforms: [.iOS(.v26)],
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
    ],
    swiftLanguageModes: [.v5]
)
