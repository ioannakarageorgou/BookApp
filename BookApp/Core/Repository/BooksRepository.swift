import Foundation
import NetworkClient
import BookAPIClient

public protocol BooksRepositoryProviding {
    func fetchBooks(query: String, page: Int) async throws -> PagedBooks
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
}

private extension BooksRepository {
    func mapToBooks(_ volumes: [Volume]?) -> [Book] {
        guard let volumes else { return [] }
        return volumes.map { mapVolumeToBook($0) }
    }

    func mapVolumeToBook(_ volume: Volume) -> Book {
        let subtitle = volume.volumeInfo.authors?.joined(separator: ", ")
        ?? volume.volumeInfo.publisher
        ?? volume.volumeInfo.publishedDate

        let thumbnailURL = URL(string: volume.volumeInfo.imageLinks?.thumbnail ?? "")

        return Book(
            id: volume.id,
            title: volume.volumeInfo.title,
            subtitle: subtitle,
            thumbnailURL: thumbnailURL
        )
    }
}
