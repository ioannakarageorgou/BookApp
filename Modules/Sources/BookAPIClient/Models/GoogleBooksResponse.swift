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
