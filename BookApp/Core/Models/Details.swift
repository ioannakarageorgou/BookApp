import Foundation

public struct Details: Equatable, Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let description: String?
    public let authors: [String]
    public let publisher: String?
    public let publishedDate: String?
    public let thumbnailURL: URL?
    
    public init(
        id: String,
        title: String,
        subtitle: String?,
        description: String?,
        authors: [String],
        publisher: String?,
        publishedDate: String?,
        thumbnailURL: URL?
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.authors = authors
        self.publisher = publisher
        self.publishedDate = publishedDate
        self.thumbnailURL = thumbnailURL
    }
}
