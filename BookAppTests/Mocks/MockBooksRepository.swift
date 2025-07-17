@testable import BookApp

final class MockBooksRepository: BooksRepositoryProviding {
    var fetchBooksResult: Result<PagedBooks, Error>?
    var fetchBookDetailsResult: Result<Details, Error>?
    var addToFavoritesError: Error?
    var removeFromFavoritesError: Error?
    var getFavoriteBooksResult: Result<[Book], Error>?
    var isFavoriteResult: Bool?

    func fetchBooks(query: String, page: Int) async throws -> PagedBooks {
        guard let result = fetchBooksResult else {
            fatalError("fetchBooksResult not set in MockBooksRepository")
        }
        switch result {
        case .success(let pagedBooks): return pagedBooks
        case .failure(let error): throw error
        }
    }

    func fetchBookDetails(id: String) async throws -> Details {
        guard let result = fetchBookDetailsResult else {
            fatalError("fetchBookDetailsResult not set in MockBooksRepository")
        }
        switch result {
        case .success(let details): return details
        case .failure(let error): throw error
        }
    }

    func addToFavorites(_ book: Book) throws {
        if let error = addToFavoritesError {
            throw error
        } else {
            fatalError("addToFavorites not implemented in MockBooksRepository")
        }
    }

    func removeFromFavorites(_ book: Book) throws {
        if let error = removeFromFavoritesError {
            throw error
        } else {
            fatalError("removeFromFavorites not implemented in MockBooksRepository")
        }
    }

    func getFavoriteBooks() throws -> [Book] {
        guard let result = getFavoriteBooksResult else {
            fatalError("getFavoriteBooksResult not set in MockBooksRepository")
        }
        switch result {
        case .success(let books): return books
        case .failure(let error): throw error
        }
    }

    func isFavorite(_ book: Book) -> Bool {
        guard let isFav = isFavoriteResult else {
            fatalError("isFavoriteResult not set in MockBooksRepository")
        }
        return isFav
    }
}
