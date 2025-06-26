public struct PagedBooks: Equatable {
    public let books: [Book]
    public let totalItems: Int

    public init(books: [Book], totalItems: Int) {
        self.books = books
        self.totalItems = totalItems
    }
}
