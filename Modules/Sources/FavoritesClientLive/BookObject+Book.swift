import Foundation
import Models

extension BookObject {
    convenience init(book: Book) {
        self.init()
        id = book.id
        title = book.title
        subtitle = book.subtitle
        thumbnailURL = book.thumbnailURL?.absoluteString
    }
}

extension Book {
    init(object: BookObject) {
        self.init(
            id: object.id,
            title: object.title,
            subtitle: object.subtitle,
            thumbnailURL: object.thumbnailURL.flatMap { URL(string: $0) }
        )
    }
}
