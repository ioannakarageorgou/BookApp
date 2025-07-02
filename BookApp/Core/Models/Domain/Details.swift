import Foundation

struct Details: Equatable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let description: String?
    let authors: [String]
    let publisher: String?
    let publishedDate: String?
    let thumbnailURL: URL?
}
