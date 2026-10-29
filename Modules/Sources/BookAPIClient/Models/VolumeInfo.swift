import Foundation

package struct VolumeInfo: Decodable, Equatable {
    package let title: String
    package let authors: [String]?
    package let publisher: String?
    package let publishedDate: String?
    package let description: String?
    package let imageLinks: ImageLinks?

    package init(
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

package struct ImageLinks: Decodable, Equatable {
    package let thumbnail: String?

    package init(thumbnail: String?) {
        self.thumbnail = thumbnail
    }
}
