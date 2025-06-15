import Foundation

/// Main interface to send network requests.
/// Holds the API key for authentication.
/// Uses URLRequestBuilder and NetworkDispatcher internally to:
/// - Build URLRequest (injecting API key),
/// - Perform network call,
/// - Decode JSON response to Request.Response type,
/// - Throw unified NetworkError on failure.
struct LiveNetworkClient: NetworkClient {
    private let dispatcher: NetworkDispatcher
    private let apiKey: String?

    public init(apiKey: String? = nil, dispatcher: NetworkDispatcher = NetworkDispatcher()) {
        self.apiKey = apiKey
        self.dispatcher = dispatcher
    }

    public func send<T: Request>(_ request: T) async throws -> T.Response {
        let urlRequest = try URLRequestBuilder.build(from: request, apiKey: apiKey)
        let data = try await dispatcher.send(urlRequest)

        do {
            return try JSONDecoder().decode(T.Response.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
