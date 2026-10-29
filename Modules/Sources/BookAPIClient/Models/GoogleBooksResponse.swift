package struct GoogleBooksResponse: Decodable, Equatable {
    package let totalItems: Int
    package let items: [Volume]?

    package init(totalItems: Int, items: [Volume]?) {
        self.totalItems = totalItems
        self.items = items
    }
}

package struct Volume: Decodable, Equatable {
    package let id: String
    package let volumeInfo: VolumeInfo

    package init(id: String, volumeInfo: VolumeInfo) {
        self.id = id
        self.volumeInfo = volumeInfo
    }
}
