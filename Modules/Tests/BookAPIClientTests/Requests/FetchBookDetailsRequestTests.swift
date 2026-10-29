import Testing
@testable import BookAPIClient

@Suite
struct FetchBookDetailsRequestTests {
    @Test
    func targetsVolumeByID() {
        let request = FetchBookDetailsRequest(bookID: "abc123")

        #expect(request.path == "/books/v1/volumes/abc123")
        #expect(request.method == .get)
        #expect(request.queryItems.isEmpty)
        #expect(request.headers.isEmpty)
    }
}
