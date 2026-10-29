// swift-tools-version: 6.2

import PackageDescription

/// App-specific modules. Each module is its own target with explicit dependencies;
/// reusable infrastructure (NetworkClient) lives in its own package.
let package = Package(
    name: "Modules",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "BookAPIClient", targets: ["BookAPIClient"]),
        .library(name: "SharedUI", targets: ["SharedUI"]),
    ],
    dependencies: [
        .package(path: "../NetworkClient"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.0"),
    ],
    targets: [
        .target(
            name: "BookAPIClient",
            dependencies: [
                .product(name: "NetworkClient", package: "NetworkClient"),
            ]
        ),
        .testTarget(
            name: "BookAPIClientTests",
            dependencies: [
                "BookAPIClient",
                .product(name: "NetworkClient", package: "NetworkClient"),
            ]
        ),

        .target(
            name: "SharedUI",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "SharedUITests",
            dependencies: [
                "SharedUI",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
