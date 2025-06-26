import Foundation

public struct Book: Equatable, Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let thumbnailURL: URL?

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        thumbnailURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.thumbnailURL = thumbnailURL
    }
}

/*
 This error:
 NSURLErrorDomain Code=-1022 "The resource could not be loaded because the App Transport Security policy requires the use of a secure connection."
 means that one of the image URLs is using http instead of https, and iOS blocks that by default due to App Transport Security (ATS).

 🧠 What's happening?
 When you scroll down and load more books, some of them have a thumbnail URL like this: http://books.google.com/books/content?id=...
 Because this URL is http and not secure, iOS blocks the request unless you've explicitly allowed it in your app's security settings.
 */
public extension Book {
    var secureThumbnailURL: URL? {
        guard let url = thumbnailURL else { return nil }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.scheme = "https"
        return components?.url
    }
}
