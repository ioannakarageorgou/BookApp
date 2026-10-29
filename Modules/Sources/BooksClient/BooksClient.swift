import Dependencies
import DependenciesMacros
import Models

/// Searches and loads books. The live implementation is in `BooksClientLive`.
@DependencyClient
public struct BooksClient: Sendable {
    /// `page` is zero-based.
    public var fetchBooks: @Sendable (_ query: String, _ page: Int) async throws -> PagedBooks
    public var fetchBookDetails: @Sendable (_ id: Book.ID) async throws -> Details
}

extension BooksClient: TestDependencyKey {
    public static let testValue = BooksClient()

    #if DEBUG
    public static let previewValue = BooksClient(
        fetchBooks: { _, _ in PagedBooks(books: Book.fixtures, totalItems: Book.fixtures.count) },
        fetchBookDetails: { id in .fixture(core: Book.fixtures.first { $0.id == id } ?? .fixture(id: id)) }
    )
    #endif
}

extension DependencyValues {
    public var booksClient: BooksClient {
        get { self[BooksClient.self] }
        set { self[BooksClient.self] = newValue }
    }
}
