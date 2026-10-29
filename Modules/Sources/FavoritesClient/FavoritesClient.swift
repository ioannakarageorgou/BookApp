import Dependencies
import DependenciesMacros
import Models

/// The user's shelf of favorite books. The live implementation is in `FavoritesClientLive`.
@DependencyClient
public struct FavoritesClient: Sendable {
    public var favorites: @Sendable () throws -> [Book]
    public var isFavorite: @Sendable (_ id: Book.ID) -> Bool = { _ in false }
    public var add: @Sendable (_ book: Book) throws -> Void
    public var remove: @Sendable (_ id: Book.ID) throws -> Void
}

extension FavoritesClient: TestDependencyKey {
    public static let testValue = FavoritesClient()

    /// An in-memory shelf, so previews can add and remove favorites.
    public static var previewValue: FavoritesClient {
        let shelf = LockIsolated<[Book]>([])
        return FavoritesClient(
            favorites: { shelf.value },
            isFavorite: { id in shelf.value.contains { $0.id == id } },
            add: { book in shelf.withValue { $0.removeAll { $0.id == book.id }; $0.append(book) } },
            remove: { id in shelf.withValue { $0.removeAll { $0.id == id } } }
        )
    }
}

extension DependencyValues {
    public var favoritesClient: FavoritesClient {
        get { self[FavoritesClient.self] }
        set { self[FavoritesClient.self] = newValue }
    }
}
