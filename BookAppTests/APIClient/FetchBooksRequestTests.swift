import XCTest
import NetworkClient
@testable import BookApp

final class FetchBooksRequestTests: XCTestCase {
    func testFetchBooksRequest_returnsExpectedBooks() async throws {
        let mockResponse = GoogleBooksResponse(items: [
            Volume(
                id: "abc123",
                volumeInfo: VolumeInfo(
                    title: "Swift for Realists",
                    authors: ["Jane Doe"],
                    publisher: "Awesome Press",
                    publishedDate: "2022-06-01",
                    description: "A serious look at Swift.",
                    imageLinks: ImageLinks(thumbnail: "http://example.com/image.jpg")
                )
            ),
            Volume(
                id: "def456",
                volumeInfo: VolumeInfo(
                    title: "TCA Deep Dive",
                    authors: ["John Appleseed"],
                    publisher: "Combine Labs",
                    publishedDate: "2023-01-15",
                    description: "Understanding The Composable Architecture",
                    imageLinks: ImageLinks(thumbnail: nil)
                )
            )
        ])

        let mockClient = MockNetworkClient { request in
            XCTAssertTrue(request is FetchBooksRequest)
            return mockResponse
        }

        let request = FetchBooksRequest(query: "Swift")
        let response = try await mockClient.send(request)

        XCTAssertEqual(response.items.count, 2)
        XCTAssertEqual(response.items[0].id, "abc123")
        XCTAssertEqual(response.items[0].volumeInfo.title, "Swift for Realists")
    }
}
