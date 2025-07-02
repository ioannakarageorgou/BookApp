import Foundation

struct Book: Equatable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let thumbnailURL: URL?

    init(
        id: String,
        title: String,
        subtitle: String? = nil,
        thumbnailURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.thumbnailURL = thumbnailURL
    }
}
