import Foundation
import NetworkClient

/// Google Books API settings for a `NetworkClient`.
public enum GoogleBooksAPI {
    public static let baseURL = URL(string: "https://www.googleapis.com")!

    /// Without an API key, requests use Google's shared anonymous quota.
    public static func configuration(apiKey: String?) -> NetworkClientConfiguration {
        NetworkClientConfiguration(
            baseURL: baseURL,
            defaultQueryItems: apiKey.map { [URLQueryItem(name: "key", value: $0)] } ?? []
        )
    }
}
