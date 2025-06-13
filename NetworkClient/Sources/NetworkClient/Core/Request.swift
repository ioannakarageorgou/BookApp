import Foundation

/// Represents a generic network request.
/// Each request defines:
/// - The API path (endpoint),
/// - Query parameters,
/// - HTTP method,
/// - Optional headers,
/// and has an associated Response type conforming to Decodable.
public protocol Request {
    associatedtype Response: Decodable

    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var method: String { get }
    var headers: [String: String]? { get }
}
