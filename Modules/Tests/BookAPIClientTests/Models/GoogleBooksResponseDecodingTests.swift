import Foundation
import Testing
@testable import BookAPIClient

@Suite
struct GoogleBooksResponseDecodingTests {
    @Test
    func decodesVolumesAndIgnoresUnknownKeys() throws {
        let json = """
        {
            "kind": "books#volumes",
            "totalItems": 1250,
            "items": [
                {
                    "kind": "books#volume",
                    "id": "abc123",
                    "etag": "x1y2z3",
                    "volumeInfo": {
                        "title": "Swift for Realists",
                        "authors": ["Jane Doe", "John Appleseed"],
                        "publisher": "Awesome Press",
                        "publishedDate": "2022-06-01",
                        "description": "A serious look at Swift.",
                        "pageCount": 320,
                        "imageLinks": {
                            "smallThumbnail": "http://books.google.com/small.jpg",
                            "thumbnail": "http://books.google.com/thumb.jpg"
                        }
                    },
                    "saleInfo": { "country": "GR", "saleability": "NOT_FOR_SALE" }
                }
            ]
        }
        """

        let response = try decode(GoogleBooksResponse.self, from: json)

        #expect(response == GoogleBooksResponse(totalItems: 1250, items: [
            Volume(
                id: "abc123",
                volumeInfo: VolumeInfo(
                    title: "Swift for Realists",
                    authors: ["Jane Doe", "John Appleseed"],
                    publisher: "Awesome Press",
                    publishedDate: "2022-06-01",
                    description: "A serious look at Swift.",
                    imageLinks: ImageLinks(thumbnail: "http://books.google.com/thumb.jpg")
                )
            ),
        ]))
    }

    @Test
    func decodesResponseWithoutItemsKey() throws {
        // Google omits "items" entirely when a query has no results.
        let response = try decode(GoogleBooksResponse.self, from: #"{ "kind": "books#volumes", "totalItems": 0 }"#)

        #expect(response == GoogleBooksResponse(totalItems: 0, items: nil))
    }

    @Test
    func decodesVolumeWithOnlyATitle() throws {
        let volume = try decode(Volume.self, from: #"{ "id": "min", "volumeInfo": { "title": "Untitled Draft" } }"#)

        #expect(volume == Volume(id: "min", volumeInfo: VolumeInfo(title: "Untitled Draft")))
    }

    @Test
    func failsWhenTotalItemsIsMissing() {
        #expect(throws: DecodingError.self) {
            try decode(GoogleBooksResponse.self, from: #"{ "items": [] }"#)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from json: String) throws -> T {
        try JSONDecoder().decode(type, from: Data(json.utf8))
    }
}
