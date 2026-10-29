import Foundation
import Testing
@testable import BookAPIClient

@Suite
struct FetchBooksRequestTests {
    @Test
    func targetsVolumesEndpointWithGET() {
        let request = FetchBooksRequest(query: "Swift")

        #expect(request.path == "/books/v1/volumes")
        #expect(request.method == "GET")
        #expect(request.headers == nil)
    }

    @Test
    func defaultsToFirstPageOfTwenty() {
        let request = FetchBooksRequest(query: "Swift")

        #expect(request.queryItems == [
            URLQueryItem(name: "q", value: "Swift"),
            URLQueryItem(name: "startIndex", value: "0"),
            URLQueryItem(name: "maxResults", value: "20"),
        ])
    }

    @Test
    func passesPaginationParameters() {
        let request = FetchBooksRequest(query: "Swift", startIndex: 40, maxResults: 10)

        #expect(request.queryItems == [
            URLQueryItem(name: "q", value: "Swift"),
            URLQueryItem(name: "startIndex", value: "40"),
            URLQueryItem(name: "maxResults", value: "10"),
        ])
    }
}
