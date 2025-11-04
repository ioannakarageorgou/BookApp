import Foundation

extension Details {
    static func fixture(
        core: Book = .fixture(),
        description: String? = "This is a good description because it tells you about the book",
        authors: [String] = ["Author One", "Author Two"],
        publisher: String? = "Great Publisher",
        publishedDate: String? = "2024-01-01"
    ) -> Self {
        Details(
            core: core,
            description: description,
            authors: authors,
            publisher: publisher,
            publishedDate: publishedDate
        )
    }
}
