import Foundation
import NetworkClient

package struct FetchBooksRequest: Request {
    package typealias Response = GoogleBooksResponse

    package let query: String
    package let startIndex: Int
    package let maxResults: Int

    package var path: String { "/books/v1/volumes" }
    package var queryItems: [URLQueryItem] {
        [
            .init(name: "q", value: query),
            .init(name: "startIndex", value: "\(startIndex)"),
            .init(name: "maxResults", value: "\(maxResults)")
        ]
    }

    package init(query: String, startIndex: Int = 0, maxResults: Int = 20) {
        self.query = query
        self.startIndex = startIndex
        self.maxResults = maxResults
    }
}
