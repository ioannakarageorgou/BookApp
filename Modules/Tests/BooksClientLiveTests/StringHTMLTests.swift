import Testing
@testable import BooksClientLive

/// Not main-actor isolated: the conversion must work on any thread, because book details
/// are mapped inside effects.
@Suite
struct StringHTMLTests {
    @Test(arguments: [
        ("<b>Bold</b> and <i>italic</i>", "Bold and italic"),
        ("Fish &amp; Chips", "Fish & Chips"),
        ("Plain text", "Plain text"),
        ("<p>First paragraph.</p><p>Second paragraph.</p>", "First paragraph.\n\nSecond paragraph."),
        ("Line one<br>Line two<BR/>Line three", "Line one\nLine two\nLine three"),
        ("It&#39;s &#x201C;quoted&#x201D; &lt;tag&gt;", "It's \u{201C}quoted\u{201D} <tag>"),
        ("&amp;lt;", "&lt;"),
        ("Unknown &bogus; entity", "Unknown &bogus; entity"),
        ("  <p>Padded</p>  ", "Padded"),
    ])
    func convertsHTMLToPlainText(html: String, expected: String) {
        #expect(html.htmlToPlainString == expected)
    }

    @Test
    func worksOffTheMainThread() async {
        let text = await Task.detached { "<p>Background</p>".htmlToPlainString }.value

        #expect(text == "Background")
    }
}
