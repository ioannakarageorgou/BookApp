import Foundation
import NetworkClient

public struct FetchBooksRequest: Request {
    public typealias Response = GoogleBooksResponse

    public let query: String
    public let startIndex: Int
    public let maxResults: Int

    public var path: String { "/books/v1/volumes" }
    public var queryItems: [URLQueryItem] {
        [
            .init(name: "q", value: query),
            .init(name: "startIndex", value: "\(startIndex)"),
            .init(name: "maxResults", value: "\(maxResults)")
        ]
    }

    public init(query: String, startIndex: Int = 0, maxResults: Int = 20) {
        self.query = query
        self.startIndex = startIndex
        self.maxResults = maxResults
    }
}
