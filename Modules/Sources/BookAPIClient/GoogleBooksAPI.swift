import Foundation
import NetworkClient

/// Google Books API settings for a `NetworkClient`.
package enum GoogleBooksAPI {
    package static let baseURL = URL(string: "https://www.googleapis.com")!

    /// Without an API key, requests use Google's shared anonymous quota.
    package static func configuration(apiKey: String?) -> NetworkClientConfiguration {
        NetworkClientConfiguration(
            baseURL: baseURL,
            defaultQueryItems: apiKey.map { [URLQueryItem(name: "key", value: $0)] } ?? []
        )
    }
}
