/// Sends `Request`s and decodes their responses, throwing `NetworkError` on failure.
///
/// The client knows nothing about a specific API: the base URL and anything added to every
/// request, such as an API key, come from a `NetworkClientConfiguration`.
public protocol NetworkClient {
    func send<T: Request>(_ request: T) async throws -> T.Response
}

/// A `URLSession`-backed client that requires a 2xx status code and decodes JSON responses.
public func makeLiveNetworkClient(configuration: NetworkClientConfiguration) -> NetworkClient {
    LiveNetworkClient(configuration: configuration)
}
