import Foundation
import Testing
@testable import NetworkClient

@Suite
struct URLRequestBuilderTests {
    @Test
    func appendsPathToBaseURL() throws {
        let urlRequest = try URLRequestBuilder.build(from: MockRequest(), configuration: .test)

        #expect(urlRequest.url == URL(string: "https://api.example.com/mock"))
        #expect(urlRequest.httpMethod == "GET")
        #expect(urlRequest.httpBody == nil)
    }

    @Test(arguments: ["https://api.example.com/v1", "https://api.example.com/v1/"])
    func keepsBaseURLPathPrefix(baseURL: String) throws {
        let configuration = NetworkClientConfiguration(baseURL: URL(string: baseURL)!)

        let urlRequest = try URLRequestBuilder.build(from: MockRequest(path: "/books"), configuration: configuration)

        #expect(urlRequest.url == URL(string: "https://api.example.com/v1/books"))
    }

    @Test
    func appendsDefaultQueryItemsAfterRequestQueryItems() throws {
        let configuration = NetworkClientConfiguration(
            baseURL: URL(string: "https://api.example.com")!,
            defaultQueryItems: [URLQueryItem(name: "key", value: "secret")]
        )
        let request = MockRequest(queryItems: [URLQueryItem(name: "q", value: "swift")])

        let urlRequest = try URLRequestBuilder.build(from: request, configuration: configuration)

        #expect(try queryItems(of: urlRequest) == [
            URLQueryItem(name: "q", value: "swift"),
            URLQueryItem(name: "key", value: "secret"),
        ])
    }

    @Test
    func omitsQueryStringWhenThereAreNoQueryItems() throws {
        let urlRequest = try URLRequestBuilder.build(from: MockRequest(), configuration: .test)

        #expect(urlRequest.url?.query == nil)
    }

    @Test
    func mergesHeadersWithRequestHeadersWinning() throws {
        let configuration = NetworkClientConfiguration(
            baseURL: URL(string: "https://api.example.com")!,
            defaultHeaders: ["Accept": "application/json", "Authorization": "Bearer default"]
        )
        let request = MockRequest(headers: ["Authorization": "Bearer request"])

        let urlRequest = try URLRequestBuilder.build(from: request, configuration: configuration)

        #expect(urlRequest.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == "Bearer request")
    }

    @Test
    func setsMethodAndBody() throws {
        let body = Data(#"{"title":"Swift"}"#.utf8)

        let urlRequest = try URLRequestBuilder.build(from: MockRequest(method: .post, body: body), configuration: .test)

        #expect(urlRequest.httpMethod == "POST")
        #expect(urlRequest.httpBody == body)
    }

    @Test
    func throwsInvalidURLForPathWithoutLeadingSlash() {
        let error = #expect(throws: NetworkError.self) {
            try URLRequestBuilder.build(from: MockRequest(path: "mock"), configuration: .test)
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
