import Foundation
import Testing
@testable import NetworkClient

@Suite
struct URLRequestBuilderTests {
    @Test
    func buildsHTTPSRequestForGoogleAPIs() throws {
        let urlRequest = try URLRequestBuilder.build(from: MockRequest())

        let url = try #require(urlRequest.url)
        #expect(url.scheme == "https")
        #expect(url.host == "www.googleapis.com")
        #expect(url.path == "/mock")
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test
    func appendsAPIKeyAfterRequestQueryItems() throws {
        let request = MockRequest(queryItems: [URLQueryItem(name: "q", value: "swift")])

        let urlRequest = try URLRequestBuilder.build(from: request, apiKey: "test-key")

        #expect(try queryItems(of: urlRequest) == [
            URLQueryItem(name: "q", value: "swift"),
            URLQueryItem(name: "key", value: "test-key"),
        ])
    }

    @Test
    func omitsAPIKeyWhenNil() throws {
        let request = MockRequest(queryItems: [URLQueryItem(name: "q", value: "swift")])

        let urlRequest = try URLRequestBuilder.build(from: request, apiKey: nil)

        #expect(try queryItems(of: urlRequest) == [URLQueryItem(name: "q", value: "swift")])
    }

    @Test
    func appliesMethodAndHeaders() throws {
        let request = MockRequest(method: "POST", headers: ["Accept": "application/json"])

        let urlRequest = try URLRequestBuilder.build(from: request)

        #expect(urlRequest.httpMethod == "POST")
        #expect(urlRequest.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test
    func throwsInvalidURLForPathWithoutLeadingSlash() {
        let error = #expect(throws: NetworkError.self) {
            try URLRequestBuilder.build(from: MockRequest(path: "mock"))
        }

        guard case .invalidURL = error else {
            Issue.record("Expected .invalidURL, got \(String(describing: error))")
            return
        }
    }

    private func queryItems(of urlRequest: URLRequest) throws -> [URLQueryItem] {
        let url = try #require(urlRequest.url)
        return URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
    }
}
