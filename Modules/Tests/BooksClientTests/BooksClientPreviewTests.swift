import BooksClient
import Models
import Testing

@Suite
struct BooksClientPreviewTests {
    let client = BooksClient.previewValue

    @Test
    func fetchBooksReturnsFixtures() async throws {
        let paged = try await client.fetchBooks(query: "anything", page: 0)

        #expect(paged == PagedBooks(books: Book.fixtures, totalItems: Book.fixtures.count))
    }

    @Test
    func fetchBookDetailsReturnsTheMatchingFixture() async throws {
        let details = try await client.fetchBookDetails(id: "2")

        #expect(details.core == Book.fixtures[1])
    }

    @Test
    func fetchBookDetailsInventsABookForUnknownIDs() async throws {
        let details = try await client.fetchBookDetails(id: "unknown")

        #expect(details.core.id == "unknown")
    }
}
