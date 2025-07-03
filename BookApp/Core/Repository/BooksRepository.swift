import Foundation
import NetworkClient
import BookAPIClient
import RealmSwift

protocol BooksRepositoryProviding {
    func fetchBooks(query: String, page: Int) async throws -> PagedBooks
    func fetchBookDetails(id: String) async throws -> Details

    func addToFavorites(_ book: Book) throws
    func removeFromFavorites(_ book: Book) throws
    func getFavoriteBooks() throws -> [Book]
    func isFavorite(_ book: Book) -> Bool
}

final class BooksRepository: BooksRepositoryProviding {
    private let networkClient: NetworkClient
    private let pageSize = 20

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - Network requests
    func fetchBooks(query: String, page: Int) async throws -> PagedBooks {
        let startIndex = page * pageSize
        let request = FetchBooksRequest(query: query, startIndex: startIndex, maxResults: pageSize)
        let response = try await networkClient.send(request)

        let books = mapToBooks(response.items)
        return PagedBooks(books: books, totalItems: response.totalItems)
    }

    func fetchBookDetails(id: String) async throws -> Details {
        let request = FetchBookDetailsRequest(bookID: id)
        let item = try await networkClient.send(request)
        return mapVolumeToBookDetails(item)
    }

    // MARK: - Cache
    func addToFavorites(_ book: Book) throws {
        let realm = try Realm()
        let bookObject = toBookObject(book)
        try realm.write {
            realm.add(bookObject, update: .modified)
        }
    }

    func removeFromFavorites(_ book: Book) throws {
        let realm = try Realm()
        if let objectToDelete = realm.object(ofType: BookObject.self, forPrimaryKey: book.id) {
            try realm.write {
                realm.delete(objectToDelete)
            }
        }
    }

    func getFavoriteBooks() throws -> [Book] {
        let realm = try Realm()
        let results = realm.objects(BookObject.self)
        return results.map(toBook)
    }

    func isFavorite(_ book: Book) -> Bool {
        do {
            let realm = try Realm()
            return realm.object(ofType: BookObject.self, forPrimaryKey: book.id) != nil
        } catch {
            // todo Optionally log
            print("Realm error when checking favorite: \(error)")
            return false // fallback: not favorite
        }
    }
}
