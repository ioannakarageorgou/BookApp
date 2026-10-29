// swift-tools-version: 6.2

import PackageDescription

/// App-specific modules. Each module is its own target with explicit dependencies;
/// reusable infrastructure (NetworkClient) lives in its own package.
///
/// Clients are split into an interface (`BooksClient`) and a live implementation
/// (`BooksClientLive`), so features depend only on interfaces and never compile Realm or
/// networking code.
let package = Package(
    name: "Modules",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "Models", targets: ["Models"]),
        .library(name: "BooksClient", targets: ["BooksClient"]),
        .library(name: "BooksClientLive", targets: ["BooksClientLive"]),
        .library(name: "FavoritesClient", targets: ["FavoritesClient"]),
        .library(name: "FavoritesClientLive", targets: ["FavoritesClientLive"]),
        .library(name: "BookAPIClient", targets: ["BookAPIClient"]),
        .library(name: "SharedUI", targets: ["SharedUI"]),
    ],
    dependencies: [
        .package(path: "../NetworkClient"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.0"),
        .package(url: "https://github.com/realm/realm-swift", from: "20.0.6"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.0"),
    ],
    targets: [
        // MARK: - Models

        .target(name: "Models"),
        .testTarget(name: "ModelsTests", dependencies: ["Models"]),

        // MARK: - Books

        .target(
            name: "BooksClient",
            dependencies: [
                "Models",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
            ]
        ),
        .testTarget(
            name: "BooksClientTests",
            dependencies: [
                "BooksClient",
                "Models",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "BooksClientLive",
            dependencies: [
                "BookAPIClient",
                "BooksClient",
                "Models",
                .product(name: "NetworkClient", package: "NetworkClient"),
            ]
        ),
        .testTarget(
            name: "BooksClientLiveTests",
            dependencies: [
                "BookAPIClient",
                "BooksClient",
                "BooksClientLive",
                "Models",
                .product(name: "NetworkClient", package: "NetworkClient"),
                .product(name: "NetworkClientTestSupport", package: "NetworkClient"),
            ]
        ),

        // MARK: - Favorites

        .target(
            name: "FavoritesClient",
            dependencies: [
                "Models",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
            ]
        ),
        .testTarget(
            name: "FavoritesClientTests",
            dependencies: [
                "FavoritesClient",
                "Models",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "FavoritesClientLive",
            dependencies: [
                "FavoritesClient",
                "Models",
                .product(name: "RealmSwift", package: "realm-swift"),
            ]
        ),
        .testTarget(
            name: "FavoritesClientLiveTests",
            dependencies: [
                "FavoritesClient",
                "FavoritesClientLive",
                "Models",
                .product(name: "RealmSwift", package: "realm-swift"),
            ]
        ),

        // MARK: - Google Books API

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

        // MARK: - Design system

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
