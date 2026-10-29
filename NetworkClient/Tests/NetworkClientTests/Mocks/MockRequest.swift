import Foundation
import NetworkClient

struct MockRequest: Request {
    typealias Response = MockResponse

    var path = "/mock"
    var method = HTTPMethod.get
    var queryItems: [URLQueryItem] = []
    var headers: [String: String] = [:]
    var body: Data? = nil
}

struct MockResponse: Decodable, Equatable {
    let message: String
}

extension NetworkClientConfiguration {
    static let test = NetworkClientConfiguration(baseURL: URL(string: "https://api.example.com")!)
}
