import Foundation

/*
 This error:
 NSURLErrorDomain Code=-1022 "The resource could not be loaded because the App Transport Security policy requires the use of a secure connection."
 means that one of the image URLs is using http instead of https, and iOS blocks that by default due to App Transport Security (ATS).

 🧠 What's happening?
 When you scroll down and load more books, some of them have a thumbnail URL like this: http://books.google.com/books/content?id=...
 Because this URL is http and not secure, iOS blocks the request unless you've explicitly allowed it in your app's security settings.
 */
public extension URL {
    var usingHTTPS: URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.scheme = "https"
        return components.url ?? self
    }
}
