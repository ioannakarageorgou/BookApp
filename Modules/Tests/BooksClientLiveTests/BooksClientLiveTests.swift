import BookAPIClient
import BooksClient
import Foundation
import Models
import NetworkClient
import NetworkClientTestSupport
import Synchronization
import Testing
@testable import BooksClientLive

@Suite
struct BooksClientLiveTests {
    // MARK: - Fetching

    @Test
    func fetchBooksMapsVolumesAndTotal() async throws {
        let client = makeClient { _ in
            GoogleBooksResponse(totalItems: 5, items: [Self.volume(id: "book1", title: "Test Driven Development")])
        }

        let paged = try await client.fetchBooks(query: "tdd", page: 0)

        #expect(paged.totalItems == 5)
        #expect(paged.books.map(\.id) == ["book1"])
        #expect(paged.books.first?.title == "Test Driven Development")
    }

    @Test
    func fetchBooksRequestsPageOffsetOfTwenty() async throws {
        let sent = Mutex<FetchBooksRequest?>(nil)
        let client = makeClient { request in
            sent.withLock { $0 = request as? FetchBooksRequest }
            return GoogleBooksResponse(totalItems: 0, items: nil)
        }

        _ = try await client.fetchBooks(query: "swift", page: 2)

        let request = try #require(sent.withLock { $0 })
        #expect(request.query == "swift")
        #expect(request.startIndex == 40)
        #expect(request.maxResults == 20)
    }

    @Test
    func fetchBooksReturnsNoBooksWhenItemsAreMissing() async throws {
        let client = makeClient { _ in GoogleBooksResponse(totalItems: 0, items: nil) }

        let paged = try await client.fetchBooks(query: "nothing", page: 0)

        #expect(paged == PagedBooks(books: [], totalItems: 0))
    }

    @Test
    func fetchBooksPropagatesNetworkErrors() async {
        let client = makeClient { _ in throw NetworkError.httpError(404) }

        let error = await #expect(throws: NetworkError.self) {
            try await client.fetchBooks(query: "swift", page: 0)
        }

        guard case .httpError(404) = error else {
            Issue.record("Expected .httpError(404), got \(String(describing: error))")
            return
        }
    }

    @Test
    func fetchBookDetailsRequestsVolumeAndMapsIt() async throws {
        let sent = Mutex<FetchBookDetailsRequest?>(nil)
        let client = makeClient { request in
            sent.withLock { $0 = request as? FetchBookDetailsRequest }
            return Self.volume(id: "book1", title: "Refactoring", authors: ["Martin Fowler"], publisher: "Addison-Wesley")
        }

        let details = try await client.fetchBookDetails(id: "book1")

        #expect(sent.withLock { $0?.bookID } == "book1")
        #expect(details.core.id == "book1")
        #expect(details.authors == ["Martin Fowler"])
        #expect(details.publisher == "Addison-Wesley")
    }

    // MARK: - Mapping

    @Test
    func subtitleListsAuthors() {
        let book = Book(volume: Self.volume(authors: ["Kent Beck", "Erich Gamma"], publisher: "Addison-Wesley"))

        #expect(book.subtitle == "Kent Beck, Erich Gamma")
    }

    @Test
    func subtitleFallsBackToPublisherThenDate() {
        #expect(Book(volume: Self.volume(publisher: "O'Reilly", publishedDate: "2020")).subtitle == "O'Reilly")
        #expect(Book(volume: Self.volume(publishedDate: "2020")).subtitle == "2020")
        #expect(Book(volume: Self.volume()).subtitle == nil)
    }

    @Test
    func thumbnailIsUpgradedToHTTPS() {
        let book = Book(volume: Self.volume(thumbnail: "http://books.google.com/cover.jpg?id=1"))

        #expect(book.thumbnailURL == URL(string: "https://books.google.com/cover.jpg?id=1"))
    }

    @Test
    func detailsStripHTMLFromDescriptionAndDefaultAuthors() {
        let details = Details(volume: Self.volume(description: "<b>Bold</b> claims"))

        #expect(details.description == "Bold claims")
        #expect(details.authors == [])
    }

    // MARK: - Helpers

    private func makeClient(handler: @escaping @Sendable (any Request) throws -> Any) -> BooksClient {
        .live(networkClient: MockNetworkClient(handler: handler))
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
