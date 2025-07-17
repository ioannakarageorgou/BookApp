import XCTest
import BookAPIClient
import NetworkClient
import RealmSwift
@testable import BookApp

final class BooksRepositoryTests: XCTestCase {
    override func setUp() {
        super.setUp()
        var config = Realm.Configuration()
        config.inMemoryIdentifier = self.name // isolates by test method
        Realm.Configuration.defaultConfiguration = config
    }

    // MARK: - Network

    func testFetchBooks_success_returnsMappedBooks() async throws {
        let mockResponse = GoogleBooksResponse(totalItems: 5, items: [
            Volume(
                id: "book1",
                volumeInfo: VolumeInfo(
                    title: "Test Driven Development",
                    authors: ["Kent Beck"],
                    publisher: "Addison-Wesley",
                    publishedDate: "2002",
                    description: "A book about TDD.",
                    imageLinks: ImageLinks(thumbnail: nil)
                )
            )
        ])
        let mockClient = MockNetworkClient { request in
            XCTAssertTrue(request is FetchBooksRequest)
            return mockResponse
        }
        let repository = BooksRepository(networkClient: mockClient)

        let paged = try await repository.fetchBooks(query: "Swift", page: 0)

        XCTAssertEqual(paged.books.count, 1)
        XCTAssertEqual(paged.totalItems, 5)
        XCTAssertEqual(paged.books.first?.id, "book1")
        XCTAssertEqual(paged.books.first?.title, "Test Driven Development")
    }

    func testFetchBooks_networkError_throws() async {
        let mockClient = MockNetworkClient { _ in
            throw NetworkError.httpError(404)
        }
        let repository = BooksRepository(networkClient: mockClient)

        do {
            _ = try await repository.fetchBooks(query: "invalid", page: 0)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            switch error {
            case .httpError(let code):
                XCTAssertEqual(code, 404)
            default:
                XCTFail("Expected .httpError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchBooks_emptyResponse_returnsEmptyArray() async throws {
        let mockResponse = GoogleBooksResponse(totalItems: 0, items: [])
        let mockClient = MockNetworkClient { _ in
            return mockResponse
        }
        let repository = BooksRepository(networkClient: mockClient)

        let result = try await repository.fetchBooks(query: "Swift", page: 0)

        XCTAssertTrue(result.books.isEmpty)
        XCTAssertEqual(result.totalItems, 0)
    }

    func testFetchBookDetails_success_returnsDetails() async throws {
        let mockVolume = Volume(
            id: "book1",
            volumeInfo: VolumeInfo(
                title: "Test Driven Development",
                authors: ["Kent Beck"],
                publisher: "Addison-Wesley",
                publishedDate: "2002",
                description: "A book about TDD.",
                imageLinks: ImageLinks(thumbnail: nil)
            )
        )
        let mockClient = MockNetworkClient { request in
            XCTAssertTrue(request is FetchBookDetailsRequest)
            return mockVolume
        }
        let repository = BooksRepository(networkClient: mockClient)

        let details = try await repository.fetchBookDetails(id: "book1")

        XCTAssertEqual(details.core.id, "book1")
        XCTAssertEqual(details.publisher, "Addison-Wesley")
    }

    func testFetchBookDetails_networkError_throws() async {
        let mockClient = MockNetworkClient { _ in
            throw NetworkError.invalidURL
        }
        let repository = BooksRepository(networkClient: mockClient)

        do {
            _ = try await repository.fetchBookDetails(id: "fail")
            XCTFail("Expected error")
        } catch let error as NetworkError {
            switch error {
            case .invalidURL:
                // this is what we expected
                break
            default:
                XCTFail("Expected .invalidURL, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Favorites

    func testAddAndGetFavorites_success_roundTrip() throws {
        let repository = BooksRepository(networkClient: MockNetworkClient())
        let book = Book(id: "fav1", title: "Favorite Book")

        try repository.addToFavorites(book)
        let favorites = try repository.getFavoriteBooks()

        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites.first?.id, "fav1")
    }

    func testIsFavorite_returnsTrueIfExists() throws {
        let repository = BooksRepository(networkClient: MockNetworkClient())
        let book = Book(id: "123", title: "TDD Book")

        try repository.addToFavorites(book)
        XCTAssertTrue(repository.isFavorite(book))
    }

    func testIsFavorite_returnsFalseIfNotExists() throws {
        let repository = BooksRepository(networkClient: MockNetworkClient())
        let book = Book(id: "nonexistent", title: "Missing Book")

        XCTAssertFalse(repository.isFavorite(book))
    }

    func testRemoveFromFavorites_deletesCorrectly() throws {
        let repository = BooksRepository(networkClient: MockNetworkClient())
        let book = Book(id: "toDelete", title: "Remove Me")

        try repository.addToFavorites(book)
        try repository.removeFromFavorites(book)

        XCTAssertFalse(repository.isFavorite(book))
    }

    func testRemoveFromFavorites_doesNothingIfMissing() throws {
        let repository = BooksRepository(networkClient: MockNetworkClient())
        let book = Book(id: "ghost", title: "Ghost Book")

        XCTAssertNoThrow(try repository.removeFromFavorites(book))
    }

    func testGetFavoriteBooks_emptyRealm_returnsEmpty() throws {
        let repository = BooksRepository(networkClient: MockNetworkClient())

        let favorites = try repository.getFavoriteBooks()
        XCTAssertTrue(favorites.isEmpty)
    }
}
