import Foundation
import NetworkClient

struct MockRequest: Request {
    typealias Response = MockResponse

    var path: String { "/mock" }
    var queryItems: [URLQueryItem] { [] }
    var method: String { "GET" }
    var headers: [String : String]? { nil }
}

struct MockResponse: Decodable, Equatable {
    let message: String
}
