// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkClient",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "NetworkClient",
            targets: ["NetworkClient"]),
    ],
    targets: [
        .target(
            name: "NetworkClient"),
        .testTarget(
            name: "NetworkClientTests",
            dependencies: ["NetworkClient"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
