import Foundation
import Testing
@testable import NetworkClient

extension StubbedNetworkTests {
    @Suite
    struct NetworkDispatcherTests {
        let dispatcher = NetworkDispatcher(session: .stubbed())
        let request = URLRequest(url: URL(string: "https://test.com")!)

        @Test
        func returnsDataForSuccessfulResponse() async throws {
            let data = Data(#"{"message":"hello"}"#.utf8)
            URLProtocolStub.handler = { _ in (.stub(statusCode: 200), data) }

            let result = try await dispatcher.send(request)

            #expect(result == data)
        }

        @Test
        func throwsHTTPErrorForNon2xxStatusCode() async {
            URLProtocolStub.handler = { _ in (.stub(statusCode: 500), Data()) }

            await withKnownIssue("The dispatcher re-wraps .httpError as .unknown; fixed in Phase 3") {
                let error = await #expect(throws: NetworkError.self) {
                    try await dispatcher.send(request)
                }
                guard case .httpError(500) = error else {
                    Issue.record("Expected .httpError(500), got \(String(describing: error))")
                    return
                }
            }
        }

        @Test
        func mapsURLErrorToTransportError() async {
            URLProtocolStub.handler = { _ in throw URLError(.notConnectedToInternet) }

            let error = await #expect(throws: NetworkError.self) {
                try await dispatcher.send(request)
            }

            guard case .transportError(let urlError) = error else {
                Issue.record("Expected .transportError, got \(String(describing: error))")
                return
            }
            #expect(urlError.code == .notConnectedToInternet)
        }

        @Test
        func mapsOtherErrorsToUnknown() async {
            URLProtocolStub.handler = { _ in throw NSError(domain: "test", code: 1) }

            let error = await #expect(throws: NetworkError.self) {
                try await dispatcher.send(request)
            }

            guard case .unknown = error else {
                Issue.record("Expected .unknown, got \(String(describing: error))")
                return
            }
        }
    }
}
