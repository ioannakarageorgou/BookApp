import Foundation

public struct Book: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let thumbnailURL: URL?

    public init(
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
