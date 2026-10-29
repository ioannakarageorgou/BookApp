import Testing
@testable import BookAPIClient

@Suite
struct FetchBookDetailsRequestTests {
    @Test
    func targetsVolumeByID() {
        let request = FetchBookDetailsRequest(bookID: "abc123")

        #expect(request.path == "/books/v1/volumes/abc123")
        #expect(request.method == "GET")
        #expect(request.queryItems.isEmpty)
        #expect(request.headers == nil)
    }
}
