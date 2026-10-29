import Foundation

extension URL {
    /// Google Books returns some thumbnails over http, which App Transport Security blocks.
    var usingHTTPS: URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.scheme = "https"
        return components.url ?? self
    }
}
