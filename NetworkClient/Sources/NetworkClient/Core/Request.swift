import Foundation

/// An endpoint of an API, with the type its JSON response decodes to.
///
/// Only `path` is required; everything else defaults to a plain GET request.
public protocol Request {
    associatedtype Response: Decodable

    /// Appended to the configuration's base URL. Must start with "/".
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

public extension Request {
    var method: HTTPMethod { .get }
    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    var body: Data? { nil }
}
