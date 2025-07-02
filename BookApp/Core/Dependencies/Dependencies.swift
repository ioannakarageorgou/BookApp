import ComposableArchitecture
import NetworkClient

struct NetworkClientKey: DependencyKey {
    static let liveValue: NetworkClient = makeLiveNetworkClient(apiKey: Secrets.googleBooksAPIKey)
    // add testValue too for testing
}

struct BooksRepositoryKey: DependencyKey {
    static var liveValue: BooksRepositoryProviding {
        BooksRepository(networkClient: DependencyValues().networkClient)
    }
    //    static let testValue: BooksRepositoryProviding = BooksRepositoryMock() // your mock for tests todo
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
