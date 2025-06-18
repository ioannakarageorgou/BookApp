import Foundation
import NetworkClient
import BookAPIClient

public protocol BooksRepositoryProviding {
    func fetchBooks(query: String) async throws -> [Book]
}

public final class BooksRepository: BooksRepositoryProviding {
    private let networkClient: NetworkClient

    public init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func fetchBooks(query: String) async throws -> [Book] {
        let request = FetchBooksRequest(query: query)
        let response = try await networkClient.send(request)
        return mapToBooks(response.items)
    }
}

private extension BooksRepository {
    func mapToBooks(_ volumes: [Volume]) -> [Book] {
        volumes.map { volume in
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
}
