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
        return response.items.map {
            Book(id: $0.id, title: $0.volumeInfo.title)
        }
    }
}
