import XCTest
import NetworkClient
@testable import BookAPIClient

final class FetchBooksRequestTests: XCTestCase {
    let validMockResponse = GoogleBooksResponse(items: [
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

    func testFetchBooksRequest_properties() {
        let request = FetchBooksRequest(query: "Swift")

        XCTAssertEqual(request.path, "/books/v1/volumes")
        XCTAssertEqual(request.method, "GET")
        XCTAssertEqual(request.headers, nil)
        XCTAssertEqual(request.queryItems, [URLQueryItem(name: "q", value: "Swift")])
    }

    func testFetchBooksRequest_returnsExpectedBooks() async throws {
        let mockClient = MockNetworkClient { request in
            XCTAssertTrue(request is FetchBooksRequest)
            return self.validMockResponse
        }

        let request = FetchBooksRequest(query: "Swift")
        let response = try await mockClient.send(request)

        XCTAssertEqual(response.items.count, 2)
        XCTAssertEqual(response.items[0].id, "abc123")
        XCTAssertEqual(response.items[0].volumeInfo.title, "Swift for Realists")
    }

    func testFetchBooksRequest_decodingSucceedsWithValidJSON() throws {
        let json = """
        {
            "items": [
                {
                    "id": "abc123",
                    "volumeInfo": {
                        "title": "Swift for Realists",
                        "authors": ["Jane Doe"],
                        "publisher": "Awesome Press",
                        "publishedDate": "2022-06-01",
                        "description": "A serious look at Swift.",
                        "imageLinks": {
                            "thumbnail": "http://example.com/image.jpg"
                        }
                    }
                }
            ]
        }
        """

        let data = Data(json.utf8)
        let decoded = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)

        XCTAssertEqual(decoded.items.count, 1)
        XCTAssertEqual(decoded.items[0].id, "abc123")
        XCTAssertEqual(decoded.items[0].volumeInfo.title, "Swift for Realists")
    }

    func testFetchBooksRequest_decodingFailsWithInvalidJSON() throws {
        let invalidJSON = """
        {
            "invalidKey": "invalidValue"
        }
        """

        let data = Data(invalidJSON.utf8)

        XCTAssertThrowsError(
            try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
        ) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testFetchBooksRequest_handlesEmptyItemsArray() throws {
        let emptyItemsJSON = """
        {
            "items": []
        }
        """

        let data = Data(emptyItemsJSON.utf8)
        let decoded = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)

        XCTAssertTrue(decoded.items.isEmpty)
    }
}
