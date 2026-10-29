import Testing
@testable import BooksClientLive

/// Main actor because the HTML importer behind `htmlToPlainString` must run on the main thread.
@MainActor
@Suite
struct StringHTMLTests {
    @Test(arguments: [
        ("<b>Bold</b> and <i>italic</i>", "Bold and italic"),
        ("Fish &amp; Chips", "Fish & Chips"),
        ("Plain text", "Plain text"),
    ])
    func convertsHTMLToPlainText(html: String, expected: String) {
        #expect(html.htmlToPlainString == expected)
    }
}
