import BookAPIClient
import ComposableArchitecture
import Foundation
import NetworkClient
import RealmSwift
import Testing
@testable import BookApp

/// Serialized because each test swaps Realm's global default configuration.
@Suite(.serialized)
struct BooksRepositoryTests {
    /// Keeps the in-memory Realm alive for the whole test; it is discarded once no instance is open.
    let realm: Realm

    init() throws {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(inMemoryIdentifier: UUID().uuidString)
        realm = try Realm()
    }

    // MARK: - Network

    @Test
    func fetchBooksMapsVolumesAndTotal() async throws {
        let repository = makeRepository { _ in
            GoogleBooksResponse(totalItems: 5, items: [Self.volume(id: "book1", title: "Test Driven Development")])
        }

        let paged = try await repository.fetchBooks(query: "tdd", page: 0)

        #expect(paged.totalItems == 5)
        #expect(paged.books.map(\.id) == ["book1"])
        #expect(paged.books.first?.title == "Test Driven Development")
    }

    @Test
    func fetchBooksRequestsPageOffsetOfTwenty() async throws {
        let sent = LockIsolated<FetchBooksRequest?>(nil)
        let repository = makeRepository { request in
            sent.setValue(request as? FetchBooksRequest)
            return GoogleBooksResponse(totalItems: 0, items: nil)
        }

        _ = try await repository.fetchBooks(query: "swift", page: 2)

        let request = try #require(sent.value)
        #expect(request.query == "swift")
        #expect(request.startIndex == 40)
        #expect(request.maxResults == 20)
    }

    @Test
    func fetchBooksReturnsNoBooksWhenItemsAreMissing() async throws {
        let repository = makeRepository { _ in GoogleBooksResponse(totalItems: 0, items: nil) }

        let paged = try await repository.fetchBooks(query: "nothing", page: 0)

        #expect(paged == PagedBooks(books: [], totalItems: 0))
    }

    @Test
    func fetchBooksPropagatesNetworkErrors() async {
        let repository = makeRepository { _ in throw NetworkError.httpError(404) }

        let error = await #expect(throws: NetworkError.self) {
            try await repository.fetchBooks(query: "swift", page: 0)
        }

        guard case .httpError(404) = error else {
            Issue.record("Expected .httpError(404), got \(String(describing: error))")
            return
        }
    }

    @Test
    func fetchBookDetailsRequestsVolumeAndMapsIt() async throws {
        let sent = LockIsolated<FetchBookDetailsRequest?>(nil)
        let repository = makeRepository { request in
            sent.setValue(request as? FetchBookDetailsRequest)
            return Self.volume(id: "book1", title: "Refactoring", authors: ["Martin Fowler"], publisher: "Addison-Wesley")
        }

        let details = try await repository.fetchBookDetails(id: "book1")

        #expect(sent.value?.bookID == "book1")
        #expect(details.core.id == "book1")
        #expect(details.authors == ["Martin Fowler"])
        #expect(details.publisher == "Addison-Wesley")
    }

    // MARK: - Mapping

    @Test
    func subtitleListsAuthors() {
        let book = makeRepository().mapVolumeToBook(Self.volume(authors: ["Kent Beck", "Erich Gamma"], publisher: "Addison-Wesley"))

        #expect(book.subtitle == "Kent Beck, Erich Gamma")
    }

    @Test
    func subtitleFallsBackToPublisherThenDate() {
        let repository = makeRepository()

        #expect(repository.mapVolumeToBook(Self.volume(publisher: "O'Reilly", publishedDate: "2020")).subtitle == "O'Reilly")
        #expect(repository.mapVolumeToBook(Self.volume(publishedDate: "2020")).subtitle == "2020")
        #expect(repository.mapVolumeToBook(Self.volume()).subtitle == nil)
    }

    @Test
    func thumbnailIsUpgradedToHTTPS() {
        let book = makeRepository().mapVolumeToBook(Self.volume(thumbnail: "http://books.google.com/cover.jpg?id=1"))

        #expect(book.thumbnailURL == URL(string: "https://books.google.com/cover.jpg?id=1"))
    }

    @Test
    @MainActor
    func detailsStripHTMLFromDescriptionAndDefaultAuthors() {
        let details = makeRepository().mapVolumeToBookDetails(Self.volume(description: "<b>Bold</b> claims"))

        #expect(details.description == "Bold claims")
        #expect(details.authors == [])
    }

    // MARK: - Favorites

    @Test
    func addedFavoriteIsReturnedWithAllFields() throws {
        let repository = makeRepository()
        let book = Book.fixture(id: "fav1")

        try repository.addToFavorites(book)

        #expect(try repository.getFavoriteBooks() == [book])
        #expect(repository.isFavorite(book))
    }

    @Test
    func addingTheSameFavoriteTwiceKeepsOneCopy() throws {
        let repository = makeRepository()
        let book = Book.fixture(id: "fav1")

        try repository.addToFavorites(book)
        try repository.addToFavorites(book)

        #expect(try repository.getFavoriteBooks() == [book])
    }

    @Test
    func unknownBookIsNotFavorite() {
        #expect(!makeRepository().isFavorite(Book.fixture(id: "nonexistent")))
    }

    @Test
    func removedFavoriteIsGone() throws {
        let repository = makeRepository()
        let book = Book.fixture(id: "toDelete")
        try repository.addToFavorites(book)

        try repository.removeFromFavorites(book)

        #expect(!repository.isFavorite(book))
        #expect(try repository.getFavoriteBooks().isEmpty)
    }

    @Test
    func removingUnknownFavoriteDoesNotThrow() throws {
        try makeRepository().removeFromFavorites(Book.fixture(id: "ghost"))
    }

    // MARK: - Helpers

    private func makeRepository(handler: ((any Request) throws -> Any)? = nil) -> BooksRepository {
        BooksRepository(networkClient: StubNetworkClient(handler: handler))
    }

    private static func volume(
        id: String = "id",
        title: String = "Title",
        authors: [String]? = nil,
        publisher: String? = nil,
        publishedDate: String? = nil,
        description: String? = nil,
        thumbnail: String? = nil
    ) -> Volume {
        Volume(
            id: id,
            volumeInfo: VolumeInfo(
                title: title,
                authors: authors,
                publisher: publisher,
                publishedDate: publishedDate,
                description: description,
                imageLinks: thumbnail.map { ImageLinks(thumbnail: $0) }
            )
        )
    }
}

/// Temporary local stub. The shared `MockNetworkClient` (NetworkClientTestSupport) can't be
/// linked into this app-hosted test bundle: Xcode would turn NetworkClient into a dynamic
/// framework and its coverage would be lost. Deleted with `BooksRepository` in M3.
private struct StubNetworkClient: NetworkClient {
    let handler: ((any Request) throws -> Any)?

    func send<T: Request>(_ request: T) async throws -> T.Response {
        guard let response = try handler?(request) as? T.Response else {
            throw TestError.someError
        }
        return response
    }
}
