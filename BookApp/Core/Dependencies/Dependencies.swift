import ComposableArchitecture
import NetworkClient

// For unit tests of your repository, keep the explicit initializer injection (BooksRepository(networkClient: mockClient)) for clarity
struct NetworkClientKey: DependencyKey {
    static let liveValue: NetworkClient = makeLiveNetworkClient(apiKey: Secrets.googleBooksAPIKey)
}

struct BooksRepositoryKey: DependencyKey {
    static var liveValue: BooksRepositoryProviding {
        @Dependency(\.networkClient) var networkClient
        return BooksRepository(networkClient: networkClient)
    }
}

extension DependencyValues {
    var networkClient: NetworkClient {
        get { self[NetworkClientKey.self] }
        set { self[NetworkClientKey.self] = newValue }
    }

    var booksRepository: BooksRepositoryProviding {
        get { self[BooksRepositoryKey.self] }
        set { self[BooksRepositoryKey.self] = newValue }
    }
}
