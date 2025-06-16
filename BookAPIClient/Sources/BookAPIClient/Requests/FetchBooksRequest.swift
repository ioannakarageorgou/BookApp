import Foundation
import NetworkClient

public struct FetchBooksRequest: Request {
    public typealias Response = GoogleBooksResponse

    public let query: String

    public var path: String { "/books/v1/volumes" }
    public var queryItems: [URLQueryItem] { [.init(name: "q", value: query)] }
    public var method: String { "GET" }
    public var headers: [String: String]? { nil }

    public init(query: String) {
        self.query = query
    }
}
