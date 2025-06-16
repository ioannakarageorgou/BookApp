public struct GoogleBooksResponse: Decodable, Equatable {
    public let items: [Volume]
}

public struct Volume: Decodable, Equatable {
    public let id: String
    public let volumeInfo: VolumeInfo
}

public struct VolumeInfo: Decodable, Equatable {
    public let title: String
    public let authors: [String]?
    public let publisher: String?
    public let publishedDate: String?
    public let description: String?
    public let imageLinks: ImageLinks?
}

public struct ImageLinks: Decodable, Equatable {
    public let thumbnail: String?
}
