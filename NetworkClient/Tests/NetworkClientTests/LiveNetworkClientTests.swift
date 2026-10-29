import Foundation
import Synchronization
import Testing
@testable import NetworkClient

extension StubbedNetworkTests {
    @Suite
    struct LiveNetworkClientTests {
        let client = LiveNetworkClient(
            configuration: NetworkClientConfiguration(
                baseURL: URL(string: "https://api.example.com")!,
                defaultQueryItems: [URLQueryItem(name: "key", value: "dummy")]
            ),
            dispatcher: NetworkDispatcher(session: .stubbed())
        )

        @Test
        func decodesSuccessfulResponse() async throws {
            URLProtocolStub.handler = { _ in (.stub(statusCode: 200), Data(#"{"message":"success"}"#.utf8)) }

            let response = try await client.send(MockRequest())

            #expect(response == MockResponse(message: "success"))
        }

        @Test
        func sendsRequestBuiltFromConfiguration() async throws {
            let sentRequest = Mutex<URLRequest?>(nil)
            URLProtocolStub.handler = { request in
                sentRequest.withLock { $0 = request }
                return (.stub(statusCode: 200), Data(#"{"message":"success"}"#.utf8))
            }

            _ = try await client.send(MockRequest())

            let url = try #require(sentRequest.withLock { $0?.url })
            #expect(url == URL(string: "https://api.example.com/mock?key=dummy"))
        }

        @Test
        func throwsDecodingErrorForUnexpectedPayload() async {
            URLProtocolStub.handler = { _ in (.stub(statusCode: 200), Data(#"{"unexpected":"format"}"#.utf8)) }

            let error = await #expect(throws: NetworkError.self) {
                try await client.send(MockRequest())
            }

            guard case .decodingError = error else {
                Issue.record("Expected .decodingError, got \(String(describing: error))")
                return
            }
        }
    }
}
