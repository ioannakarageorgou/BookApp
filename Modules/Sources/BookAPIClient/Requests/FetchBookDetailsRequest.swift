import Foundation
import NetworkClient

package struct FetchBookDetailsRequest: Request {
    package typealias Response = Volume

    package let bookID: String

    package var path: String { "/books/v1/volumes/\(bookID)" }

    package init(bookID: String) {
        self.bookID = bookID
    }
}
