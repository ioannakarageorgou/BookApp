import Foundation
import Synchronization
import Testing
@testable import NetworkClient

extension StubbedNetworkTests {
    @Suite
    struct LiveNetworkClientTests {
        let client = LiveNetworkClient(apiKey: "dummy", dispatcher: NetworkDispatcher(session: .stubbed()))

        @Test
        func decodesSuccessfulResponse() async throws {
            URLProtocolStub.handler = { _ in (.stub(statusCode: 200), Data(#"{"message":"success"}"#.utf8)) }

            let response = try await client.send(MockRequest())

            #expect(response == MockResponse(message: "success"))
        }

        @Test
        func sendsBuiltRequestWithAPIKey() async throws {
            let sentRequest = Mutex<URLRequest?>(nil)
            URLProtocolStub.handler = { request in
                sentRequest.withLock { $0 = request }
                return (.stub(statusCode: 200), Data(#"{"message":"success"}"#.utf8))
            }

            _ = try await client.send(MockRequest())

            let url = try #require(sentRequest.withLock { $0?.url })
            #expect(url.path == "/mock")
            #expect(url.query?.contains("key=dummy") == true)
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
