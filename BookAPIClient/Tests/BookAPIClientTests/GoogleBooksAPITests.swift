import Foundation
import NetworkClient
import Testing
@testable import BookAPIClient

@Suite
struct GoogleBooksAPITests {
    @Test
    func targetsGoogleAPIsHost() {
        #expect(GoogleBooksAPI.configuration(apiKey: nil).baseURL == URL(string: "https://www.googleapis.com"))
    }

    @Test
    func sendsAPIKeyAsKeyQueryItem() {
        let configuration = GoogleBooksAPI.configuration(apiKey: "abc123")

        #expect(configuration.defaultQueryItems == [URLQueryItem(name: "key", value: "abc123")])
        #expect(configuration.defaultHeaders.isEmpty)
    }

    @Test
    func addsNoQueryItemsWithoutAPIKey() {
        #expect(GoogleBooksAPI.configuration(apiKey: nil).defaultQueryItems.isEmpty)
    }
}
