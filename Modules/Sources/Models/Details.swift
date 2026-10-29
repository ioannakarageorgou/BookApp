import Foundation

public struct Details: Equatable, Sendable {
    public let core: Book
    public let description: String?
    public let authors: [String]
    public let publisher: String?
    public let publishedDate: String?

    public init(
        core: Book,
        description: String?,
        authors: [String],
        publisher: String?,
        publishedDate: String?
    ) {
        self.core = core
        self.description = description
        self.authors = authors
        self.publisher = publisher
        self.publishedDate = publishedDate
    }
}
