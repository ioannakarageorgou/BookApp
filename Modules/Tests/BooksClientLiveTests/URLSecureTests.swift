import Foundation
import Testing
@testable import BooksClientLive

@Suite
struct URLSecureTests {
    @Test
    func upgradesHTTPAndKeepsPathAndQuery() {
        let url = URL(string: "http://books.google.com/books/content?id=abc&zoom=1")!

        #expect(url.usingHTTPS == URL(string: "https://books.google.com/books/content?id=abc&zoom=1"))
    }

    @Test
    func leavesHTTPSUnchanged() {
        let url = URL(string: "https://example.com/cover.jpg")!

        #expect(url.usingHTTPS == url)
    }
}
