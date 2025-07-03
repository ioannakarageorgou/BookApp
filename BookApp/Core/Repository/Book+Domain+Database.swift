import Foundation
import RealmSwift

extension BooksRepository {
    func toBookObject(_ book: Book) -> BookObject {
        let obj = BookObject()
        obj.id = book.id
        obj.title = book.title
        obj.subtitle = book.subtitle
        obj.thumbnailURL = book.thumbnailURL?.absoluteString
        return obj
    }

    func toBook(_ object: BookObject) -> Book {
        Book(
            id: object.id,
            title: object.title,
            subtitle: object.subtitle,
            thumbnailURL: object.thumbnailURL.flatMap { URL(string: $0) }
        )
    }
}
