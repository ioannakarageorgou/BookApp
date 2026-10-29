import FavoritesClient
import Foundation
import Models
import RealmSwift
import Testing
@testable import FavoritesClientLive

@Suite
struct FavoritesClientLiveTests {
    let configuration = Realm.Configuration(inMemoryIdentifier: UUID().uuidString)
    /// Keeps the in-memory Realm alive for the whole test; it is discarded once no instance is open.
    let realm: Realm
    let client: FavoritesClient

    init() throws {
        realm = try Realm(configuration: configuration)
        client = .live(configuration: configuration)
    }

    @Test
    func addedFavoriteIsReturnedWithAllFields() async throws {
        let book = Book.fixture(id: "fav1")

        try await client.add(book: book)

        #expect(try await client.favorites() == [book])
        #expect(await client.isFavorite(id: book.id))
    }

    @Test
    func addingTheSameFavoriteTwiceKeepsOneCopy() async throws {
        let book = Book.fixture(id: "fav1")

        try await client.add(book: book)
        try await client.add(book: book)

        #expect(try await client.favorites() == [book])
    }

    @Test
    func unknownBookIsNotFavorite() async {
        #expect(await client.isFavorite(id: "nonexistent") == false)
    }

    @Test
    func removedFavoriteIsGone() async throws {
        let book = Book.fixture(id: "toDelete")
        try await client.add(book: book)

        try await client.remove(id: book.id)

        #expect(await client.isFavorite(id: book.id) == false)
        #expect(try await client.favorites().isEmpty)
    }

    @Test
    func removingUnknownFavoriteDoesNotThrow() async throws {
        try await client.remove(id: "ghost")
    }

    @Test
    func favoritesAreIsolatedPerConfiguration() async throws {
        try await client.add(book: Book.fixture(id: "fav1"))

        let otherConfiguration = Realm.Configuration(inMemoryIdentifier: UUID().uuidString)
        // `queue: nil` selects Realm's synchronous init; in an async context Swift would
        // otherwise pick the async, main-actor one.
        let otherRealm = try Realm(configuration: otherConfiguration, queue: nil)

        #expect(try await FavoritesClient.live(configuration: otherConfiguration).favorites().isEmpty)
        _ = otherRealm
    }
}
