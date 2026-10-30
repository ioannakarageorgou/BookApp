/// Sends typed requests and decodes their responses. The base URL and per-request
/// defaults (API key, headers) come from `NetworkClientConfiguration`, not from here.
public protocol NetworkClient: Sendable {
    func send<T: Request>(_ request: T) async throws -> T.Response
}

/// A `URLSession`-backed client that requires a 2xx status code and decodes JSON.
public func makeLiveNetworkClient(configuration: NetworkClientConfiguration) -> NetworkClient {
    LiveNetworkClient(configuration: configuration)
}
