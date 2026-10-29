import Testing
import NetworkClient
import NetworkClientTestSupport

@Suite
struct MockNetworkClientTests {
    @Test
    func returnsHandlerResponseAndPassesTheRequest() async throws {
        let client = MockNetworkClient { request in
            #expect((request as? MockRequest)?.path == "/books")
            return MockResponse(message: "stubbed")
        }

        let response = try await client.send(MockRequest(path: "/books"))

        #expect(response == MockResponse(message: "stubbed"))
    }

    @Test
    func rethrowsHandlerErrors() async {
        let client = MockNetworkClient { _ in throw NetworkError.invalidURL }

        let error = await #expect(throws: NetworkError.self) {
            try await client.send(MockRequest())
        }

        guard case .invalidURL = error else {
            Issue.record("Expected .invalidURL, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [false, true])
    func throwsWhenNoMatchingResponseIsConfigured(hasHandler: Bool) async {
        let client = MockNetworkClient(handler: hasHandler ? { _ in "wrong type" } : nil)

        let error = await #expect(throws: NetworkError.self) {
            try await client.send(MockRequest())
        }

        guard case .unknown = error else {
            Issue.record("Expected .unknown, got \(String(describing: error))")
            return
        }
    }
}
