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
    func addedFavoriteIsReturnedWithAllFields() throws {
        let book = Book.fixture(id: "fav1")

        try client.add(book: book)

        #expect(try client.favorites() == [book])
        #expect(client.isFavorite(id: book.id))
    }

    @Test
    func addingTheSameFavoriteTwiceKeepsOneCopy() throws {
        let book = Book.fixture(id: "fav1")

        try client.add(book: book)
        try client.add(book: book)

        #expect(try client.favorites() == [book])
    }

    @Test
    func unknownBookIsNotFavorite() {
        #expect(!client.isFavorite(id: "nonexistent"))
    }

    @Test
    func removedFavoriteIsGone() throws {
        let book = Book.fixture(id: "toDelete")
        try client.add(book: book)

        try client.remove(id: book.id)

        #expect(!client.isFavorite(id: book.id))
        #expect(try client.favorites().isEmpty)
    }

    @Test
    func removingUnknownFavoriteDoesNotThrow() throws {
        try client.remove(id: "ghost")
    }

    @Test
    func favoritesAreIsolatedPerConfiguration() throws {
        try client.add(book: Book.fixture(id: "fav1"))

        let otherConfiguration = Realm.Configuration(inMemoryIdentifier: UUID().uuidString)
        let otherRealm = try Realm(configuration: otherConfiguration)

        #expect(try FavoritesClient.live(configuration: otherConfiguration).favorites().isEmpty)
        _ = otherRealm
    }
}
