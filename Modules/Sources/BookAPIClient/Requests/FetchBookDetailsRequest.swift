import Foundation
import NetworkClient

public struct FetchBookDetailsRequest: Request {
    public typealias Response = Volume

    public let bookID: String

    public var path: String { "/books/v1/volumes/\(bookID)" }

    public init(bookID: String) {
        self.bookID = bookID
    }
}
