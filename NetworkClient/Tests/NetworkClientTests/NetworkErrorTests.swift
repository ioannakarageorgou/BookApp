import Foundation
import Testing
@testable import NetworkClient

@Suite
struct NetworkErrorTests {
    @Test(arguments: [
        (NetworkError.invalidURL, "The URL is invalid."),
        (.httpError(404), "Server returned error code: 404."),
        (.decodingError(TestFailure()), "Failed to decode the response."),
        (.transportError(URLError(.notConnectedToInternet)), "Network error: \(URLError(.notConnectedToInternet).localizedDescription)"),
        (.unknown(TestFailure()), "An unknown error occurred: \(TestFailure().localizedDescription)"),
    ])
    func describesEachCase(error: NetworkError, message: String) {
        #expect(error.errorDescription == message)
        #expect(error.localizedDescription == message)
    }

    @Test
    func liveClientFactoryReturnsLiveClient() {
        #expect(makeLiveNetworkClient(configuration: .test) is LiveNetworkClient)
    }

    private struct TestFailure: Error {}
}
