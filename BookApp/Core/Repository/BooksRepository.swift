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
}

final class BooksRepository: BooksRepositoryProviding {
    private let networkClient: NetworkClient
    private let pageSize = 20
    private let realm: Realm

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
        do {
            self.realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error.localizedDescription)")
        }
    }

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

    func addToFavorites(_ book: Book) throws {
        let bookObject = toBookObject(book)
        try realm.write {
            realm.add(bookObject, update: .modified)
        }
    }

    func removeFromFavorites(_ book: Book) throws {
        if let objectToDelete = realm.object(ofType: BookObject.self, forPrimaryKey: book.id) {
            try realm.write {
                realm.delete(objectToDelete)
            }
        }
    }

    func getFavoriteBooks() throws -> [Book] {
        let results = realm.objects(BookObject.self)
        return results.map(toBook)
    }
}

// todo new file for mappers
// api domain
private extension BooksRepository {
    func mapToBooks(_ volumes: [Volume]?) -> [Book] {
        guard let volumes else { return [] }
        return volumes.map { mapVolumeToBook($0) }
    }

    func mapVolumeToBook(_ volume: Volume) -> Book {
        Book(
            id: volume.id,
            title: volume.volumeInfo.title,
            subtitle: extractSubtitle(from: volume.volumeInfo),
            thumbnailURL:  extractThumbnailURL(from: volume.volumeInfo)
        )
    }

    func mapVolumeToBookDetails(_ volume: Volume) -> Details {
        Details(
            id: volume.id,
            title: volume.volumeInfo.title,
            subtitle: extractSubtitle(from: volume.volumeInfo),
            description: volume.volumeInfo.description?.htmlToPlainString,
            authors: volume.volumeInfo.authors ?? [],
            publisher: volume.volumeInfo.publisher,
            publishedDate: volume.volumeInfo.publishedDate,
            thumbnailURL:  extractThumbnailURL(from: volume.volumeInfo)
        )
    }

    func extractSubtitle(from info: VolumeInfo) -> String? {
        info.authors?.joined(separator: ", ")
        ?? info.publisher
        ?? info.publishedDate
    }

    func extractThumbnailURL(from info: VolumeInfo) -> URL? {
        guard let urlString = info.imageLinks?.thumbnail else { return nil }
        return URL(string: urlString)?.usingHTTPS
    }
}

// realm domain
private extension BooksRepository {
    func toBookObject(_ book: Book) -> BookObject {
        let obj = BookObject()
        obj.id = book.id
        obj.title = book.title
        obj.subtitle = book.subtitle
        obj.thumbnailURL = book.thumbnailURL?.absoluteString
        return obj
    }

    func toBook(_ object: BookObject) -> Book {
        Book(
            id: object.id,
            title: object.title,
            subtitle: object.subtitle,
            thumbnailURL: object.thumbnailURL.flatMap { URL(string: $0) }
        )
    }
}
