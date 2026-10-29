import Foundation

/// Describes the API a `NetworkClient` talks to.
///
/// Default query items and headers are added to every request, which covers API keys and
/// static authorization headers. Request headers win when both define the same field.
public struct NetworkClientConfiguration: Sendable {
    public var baseURL: URL
    public var defaultQueryItems: [URLQueryItem]
    public var defaultHeaders: [String: String]

    public init(
        baseURL: URL,
        defaultQueryItems: [URLQueryItem] = [],
        defaultHeaders: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.defaultQueryItems = defaultQueryItems
        self.defaultHeaders = defaultHeaders
    }
}
