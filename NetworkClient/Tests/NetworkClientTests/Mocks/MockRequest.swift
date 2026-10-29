import Foundation
import NetworkClient

struct MockRequest: Request {
    typealias Response = MockResponse

    var path = "/mock"
    var queryItems: [URLQueryItem] = []
    var method = "GET"
    var headers: [String: String]? = nil
}

struct MockResponse: Decodable, Equatable {
    let message: String
}
