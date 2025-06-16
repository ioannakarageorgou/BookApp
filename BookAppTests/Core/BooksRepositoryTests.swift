import XCTest
import BookAPIClient
import NetworkClient
@testable import BookApp

final class BooksRepositoryTests: XCTestCase {
    func testFetchBooks_success_returnsMappedBooks() async throws {
        let mockResponse = GoogleBooksResponse(items: [
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
        let books = try await repository.fetchBooks(query: "tdd")

        XCTAssertEqual(books.count, 1)
        XCTAssertEqual(books[0].id, "book1")
        XCTAssertEqual(books[0].title, "Test Driven Development")
    }

    func testFetchBooks_networkError_throws() async {
        let mockClient = MockNetworkClient { _ in
            throw NetworkError.httpError(404)
        }

        let repository = BooksRepository(networkClient: mockClient)

        do {
            _ = try await repository.fetchBooks(query: "invalid")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .httpError(404))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchBooks_emptyResponse_returnsEmptyArray() async throws {
        let mockResponse = GoogleBooksResponse(items: [])

        let mockClient = MockNetworkClient { _ in
            return mockResponse
        }

        let repository = BooksRepository(networkClient: mockClient)
        let books = try await repository.fetchBooks(query: "empty")

        XCTAssertTrue(books.isEmpty)
    }
}
