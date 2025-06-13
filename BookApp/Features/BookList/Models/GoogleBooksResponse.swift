struct GoogleBooksResponse: Decodable {
    let items: [Volume]

    struct Volume: Decodable {
        let id: String
        let volumeInfo: VolumeInfo

        struct VolumeInfo: Decodable {
            let title: String
        }
    }
}
