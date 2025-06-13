import Foundation
import NetworkClient

struct FetchBooksRequest: Request {
    typealias Response = GoogleBooksResponse

    let query: String

    var path: String { "/books/v1/volumes" }
    var queryItems: [URLQueryItem] { [.init(name: "q", value: query)] }
    var method: String { "GET" }
    var headers: [String: String]? { nil }
}
