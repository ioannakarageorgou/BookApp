public struct GoogleBooksResponse: Decodable, Equatable {
    public let totalItems: Int
    public let items: [Volume]?

    public init(totalItems: Int, items: [Volume]?) {
        self.totalItems = totalItems
        self.items = items
    }
}

public struct Volume: Decodable, Equatable {
    public let id: String
    public let volumeInfo: VolumeInfo

    public init(id: String, volumeInfo: VolumeInfo) {
        self.id = id
        self.volumeInfo = volumeInfo
    }
}

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
