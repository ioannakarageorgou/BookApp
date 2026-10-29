import BookAPIClient
import BooksClient
import Models
import NetworkClient

extension BooksClient {
    static let pageSize = 20

    /// Google Books implementation. Without an API key, requests use Google's anonymous quota.
    public static func live(apiKey: String?) -> BooksClient {
        live(networkClient: makeLiveNetworkClient(configuration: GoogleBooksAPI.configuration(apiKey: apiKey)))
    }

    public static func live(networkClient: NetworkClient) -> BooksClient {
        BooksClient(
            fetchBooks: { query, page in
                let request = FetchBooksRequest(query: query, startIndex: page * pageSize, maxResults: pageSize)
                let response = try await networkClient.send(request)
                return PagedBooks(books: (response.items ?? []).map(Book.init(volume:)), totalItems: response.totalItems)
            },
            fetchBookDetails: { id in
                let volume = try await networkClient.send(FetchBookDetailsRequest(bookID: id))
                return Details(volume: volume)
            }
        )
    }
}
