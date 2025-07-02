import Foundation
import NetworkClient
import BookAPIClient

public protocol BooksRepositoryProviding {
    func fetchBooks(query: String, page: Int) async throws -> PagedBooks
    func fetchBookDetails(id: String) async throws -> Details
}

public final class BooksRepository: BooksRepositoryProviding {
    private let networkClient: NetworkClient
    private let pageSize = 20
    
    public init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    public func fetchBooks(query: String, page: Int) async throws -> PagedBooks {
        let startIndex = page * pageSize
        let request = FetchBooksRequest(query: query, startIndex: startIndex, maxResults: pageSize)
        let response = try await networkClient.send(request)
        
        let books = mapToBooks(response.items)
        return PagedBooks(books: books, totalItems: response.totalItems)
    }
    
    public func fetchBookDetails(id: String) async throws -> Details {
        let request = FetchBookDetailsRequest(bookID: id)
        let item = try await networkClient.send(request)
        return mapVolumeToBookDetails(item)
    }
}

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
