import FavoritesClient
import Models
import Testing

@Suite
struct FavoritesClientPreviewTests {
    let client = FavoritesClient.previewValue

    @Test
    func startsEmpty() throws {
        #expect(try client.favorites().isEmpty)
        #expect(!client.isFavorite(id: "1"))
    }

    @Test
    func addAndRemoveUpdateTheShelf() throws {
        let book = Book.fixture(id: "1")

        try client.add(book: book)
        #expect(try client.favorites() == [book])
        #expect(client.isFavorite(id: "1"))

        try client.remove(id: "1")
        #expect(try client.favorites().isEmpty)
        #expect(!client.isFavorite(id: "1"))
    }

    @Test
    func addingTheSameBookTwiceKeepsOneCopy() throws {
        let book = Book.fixture(id: "1")

        try client.add(book: book)
        try client.add(book: book)

        #expect(try client.favorites() == [book])
    }

    @Test
    func eachPreviewValueHasItsOwnShelf() throws {
        try client.add(book: Book.fixture(id: "1"))

        #expect(try FavoritesClient.previewValue.favorites().isEmpty)
    }
}
