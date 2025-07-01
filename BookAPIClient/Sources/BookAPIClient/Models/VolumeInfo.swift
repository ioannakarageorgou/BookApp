import Foundation

public struct VolumeInfo: Decodable, Equatable {
    public let title: String
    public let authors: [String]?
    public let publisher: String?
    public let publishedDate: String?
    public let description: String?
    public let imageLinks: ImageLinks?

    public init(
        title: String,
        authors: [String]? = nil,
        publisher: String? = nil,
        publishedDate: String? = nil,
        description: String? = nil,
        imageLinks: ImageLinks? = nil
    ) {
        self.title = title
        self.authors = authors
        self.publisher = publisher
        self.publishedDate = publishedDate
        self.description = description
        self.imageLinks = imageLinks
    }

}

public struct ImageLinks: Decodable, Equatable {
    public let thumbnail: String?

    public init(thumbnail: String?) {
        self.thumbnail = thumbnail
    }
}
