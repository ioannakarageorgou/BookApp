import XCTest
import ComposableArchitecture
@testable import BookApp

final class BookListTests: XCTestCase {
    @MainActor
    func testFetchBooks_success() async {
        let sampleBooks = Book.fixtures
        let pagedBooks = PagedBooks(books: sampleBooks, totalItems: sampleBooks.count)

        let store = makeTestStore { repo in
            repo.fetchBooksResult = .success(pagedBooks)
        }

        await store.send(.fetchBooks(reset: true)) {
            $0.books = .loading
            $0.currentPage = 0
            $0.isLoadingNextPage = false
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(sampleBooks)
            $0.currentPage = 1
            $0.totalItems = 3
            $0.isLoadingNextPage = false
        }
    }

    @MainActor
    func testFetchBooks_failure() async {
        let store = makeTestStore { repo in
            repo.fetchBooksResult = .failure(TestError.someError)
        }

        await store.send(.fetchBooks(reset: true)) {
            $0.books = .loading
            $0.currentPage = 0
            $0.isLoadingNextPage = false
        }

        await store.receive(\.booksResponse) {
            $0.books = .error(TestError.someError.localizedDescription)
            $0.isLoadingNextPage = false
        }
    }

    @MainActor
    func testFetchBooks_appendsBooksWhenResetIsFalse() async {
        let existingBooks: [Book] = [
            .init(id: "1", title: "Book One", subtitle: "Subtitle", thumbnailURL: URL(string: "https://x.com/1")!)
        ]

        let newBooks: [Book] = [
            .init(id: "1", title: "Book One", subtitle: "Subtitle", thumbnailURL: URL(string: "https://x.com/1")!), // duplicate
            .init(id: "2", title: "Book Two", subtitle: "Subtitle", thumbnailURL: URL(string: "https://x.com/2")!)
        ]

        let store = makeTestStore(state: .init(books: .loaded(existingBooks))) { repo in
            repo.fetchBooksResult = .success(PagedBooks(books: newBooks, totalItems: 3))
        }

        await store.send(.fetchBooks(reset: false)) {
            $0.isLoadingNextPage = true
        }

        await store.receive(\.booksResponse) {
            $0.books = .loaded(newBooks)
            $0.currentPage = 1
            $0.totalItems = 3
            $0.isLoadingNextPage = false
        }
    }

    @MainActor
    func testSearchQueryChanged_updatesState() async {
        let store = makeTestStore()

        await store.send(.searchQueryChanged("SwiftUI")) {
            $0.searchQuery = "SwiftUI"
        }
    }

    @MainActor
    func testFetchNextPage_triggersFetchBooks() async {
        let sampleBooks = Book.fixtures
        let pagedBooks = PagedBooks(books: sampleBooks, totalItems: sampleBooks.count)

        let store = makeTestStore { repo in
            repo.fetchBooksResult = .success(pagedBooks)
        }

        await store.send(.fetchNextPage)
        await store.receive(\.fetchBooks) {
            $0.isLoadingNextPage = true
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(sampleBooks)
            $0.currentPage = 1
            $0.totalItems = 3
            $0.isLoadingNextPage = false
        }
    }

    @MainActor
    func testBookTapped_setsBookDetailsState() async {
        let store = makeTestStore()
        let book = Book(id: "123", title: "Test", subtitle: "T", thumbnailURL: URL(string: "https://x.com")!)

        await store.send(.bookTapped(book)) {
            $0.selectedBookID = "123"
            $0.bookDetails = BookDetails.State(bookId: "123")
        }
    }

    @MainActor
    func testDismissBookDetails_clearsBookDetailsState() async {
        let bookID = "abc"
        let store = makeTestStore(
            state: .init(
                selectedBookID: bookID,
                bookDetails: .init(bookId: bookID)
            )
        )

        await store.send(.dismissBookDetails) {
            $0.selectedBookID = nil
            $0.bookDetails = nil
        }
    }

    @MainActor
    func testLoadFavorites_success() async {
        let favorites = Book.fixtures

        let store = makeTestStore { repo in
            repo.getFavoriteBooksResult = .success(favorites)
        }

        await store.send(.loadFavorites) {
            $0.favoriteBooks = .loading
        }
        await store.receive(\.favoritesResponse) {
            $0.favoriteBooks = .loaded(favorites)
        }
    }

    @MainActor
    func testLoadFavorites_failure() async {
        let store = makeTestStore { repo in
            repo.getFavoriteBooksResult = .failure(TestError.someError)
        }

        await store.send(.loadFavorites) {
            $0.favoriteBooks = .loading
        }
        await store.receive(\.favoritesResponse) {
            $0.favoriteBooks = .error(TestError.someError.localizedDescription)
        }
    }

    func makeTestStore(
        state: BookList.State = BookList.State(),
        mockRepositorySetup: ((MockBooksRepository) -> Void)? = nil
    ) -> TestStore<BookList.State, BookList.Action> {
        let mockRepository = MockBooksRepository()
        mockRepositorySetup?(mockRepository)

        return TestStore(
            initialState: state,
            reducer: { BookList() }
        ) {
            $0.booksRepository = mockRepository
        }
    }
}
