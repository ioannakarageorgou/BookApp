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
        .library(
            name: "NetworkClientTestSupport",
            targets: ["NetworkClientTestSupport"]),
    ],
    targets: [
        .target(
            name: "NetworkClient"),
        .target(
            name: "NetworkClientTestSupport",
            dependencies: ["NetworkClient"]
        ),
        .testTarget(
            name: "NetworkClientTests",
            dependencies: ["NetworkClient", "NetworkClientTestSupport"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
