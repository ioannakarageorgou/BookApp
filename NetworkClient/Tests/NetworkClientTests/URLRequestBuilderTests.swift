import XCTest
@testable import NetworkClient

final class URLRequestBuilderTests: XCTestCase {
    func testBuild_validURLRequest() throws {
        let request = MockRequest()
        let apiKey = "test-key"
        let urlRequest = try URLRequestBuilder.build(from: request, apiKey: apiKey)

        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.url?.absoluteString.contains("/mock"), true)
        XCTAssertEqual(urlRequest.url?.query?.contains("key=test-key"), true)
    }

    func testBuild_invalidURL() {
        struct InvalidRequest: Request {
            typealias Response = MockResponse
            var path: String { "   " }
            var queryItems: [URLQueryItem] { [] }
            var method: String { "GET" }
            var headers: [String: String]? { nil }
        }

        XCTAssertThrowsError(try URLRequestBuilder.build(from: InvalidRequest(), apiKey: "key")) {
            XCTAssertEqual($0 as? NetworkError, .invalidURL)
        }
    }
}
