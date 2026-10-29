import ComposableArchitecture
@testable import BookApp

/// Returns the configured results and records every call.
/// Calling a method whose result isn't configured reports a test issue instead of crashing.
final class MockBooksRepository: BooksRepositoryProviding, @unchecked Sendable {
    struct FetchBooksCall: Equatable {
        let query: String
        let page: Int
    }

    var fetchBooksResult: Result<PagedBooks, Error>?
    var fetchBookDetailsResult: Result<Details, Error>?
    var addToFavoritesResult: Result<Void, Error>?
    var removeFromFavoritesResult: Result<Void, Error>?
    var getFavoriteBooksResult: Result<[Book], Error>?
    var isFavoriteResult: Bool?

    let fetchBooksCalls = LockIsolated<[FetchBooksCall]>([])
    let fetchBookDetailsCalls = LockIsolated<[String]>([])
    let addedToFavorites = LockIsolated<[Book]>([])
    let removedFromFavorites = LockIsolated<[Book]>([])

    func fetchBooks(query: String, page: Int) async throws -> PagedBooks {
        fetchBooksCalls.withValue { $0.append(FetchBooksCall(query: query, page: page)) }
        return try value(of: fetchBooksResult, for: "fetchBooks")
    }

    func fetchBookDetails(id: String) async throws -> Details {
        fetchBookDetailsCalls.withValue { $0.append(id) }
        return try value(of: fetchBookDetailsResult, for: "fetchBookDetails")
    }

    func addToFavorites(_ book: Book) throws {
        addedToFavorites.withValue { $0.append(book) }
        try value(of: addToFavoritesResult, for: "addToFavorites")
    }

    func removeFromFavorites(_ book: Book) throws {
        removedFromFavorites.withValue { $0.append(book) }
        try value(of: removeFromFavoritesResult, for: "removeFromFavorites")
    }

    func getFavoriteBooks() throws -> [Book] {
        try value(of: getFavoriteBooksResult, for: "getFavoriteBooks")
    }

    func isFavorite(_ book: Book) -> Bool {
        guard let isFavoriteResult else {
            reportIssue("MockBooksRepository.isFavorite called without isFavoriteResult")
            return false
        }
        return isFavoriteResult
    }

    private func value<T>(of result: Result<T, Error>?, for method: String) throws -> T {
        guard let result else {
            reportIssue("MockBooksRepository.\(method) called without a configured result")
            throw TestError.someError
        }
        return try result.get()
    }
}
