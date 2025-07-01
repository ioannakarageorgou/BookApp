import Foundation
import NetworkClient

public struct FetchBookDetailsRequest: Request {
    public typealias Response = Volume

    public let bookID: String

    public var path: String { "/books/v1/volumes/\(bookID)" }
    public var queryItems: [URLQueryItem] { [] }
    public var method: String { "GET" }
    public var headers: [String: String]? { nil }

    public init(bookID: String) {
        self.bookID = bookID
    }
}
