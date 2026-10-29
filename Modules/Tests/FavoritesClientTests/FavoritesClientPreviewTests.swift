import FavoritesClient
import Models
import Testing

@Suite
struct FavoritesClientPreviewTests {
    let client = FavoritesClient.previewValue

    @Test
    func startsEmpty() async throws {
        #expect(try await client.favorites().isEmpty)
        #expect(await client.isFavorite(id: "1") == false)
    }

    @Test
    func addAndRemoveUpdateTheShelf() async throws {
        let book = Book.fixture(id: "1")

        try await client.add(book: book)
        #expect(try await client.favorites() == [book])
        #expect(await client.isFavorite(id: "1"))

        try await client.remove(id: "1")
        #expect(try await client.favorites().isEmpty)
        #expect(await client.isFavorite(id: "1") == false)
    }

    @Test
    func addingTheSameBookTwiceKeepsOneCopy() async throws {
        let book = Book.fixture(id: "1")

        try await client.add(book: book)
        try await client.add(book: book)

        #expect(try await client.favorites() == [book])
    }

    @Test
    func eachPreviewValueHasItsOwnShelf() async throws {
        try await client.add(book: Book.fixture(id: "1"))

        #expect(try await FavoritesClient.previewValue.favorites().isEmpty)
    }
}
