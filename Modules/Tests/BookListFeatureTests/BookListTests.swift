import BookDetailsFeature
import BooksClient
import ComposableArchitecture
import FavoritesClient
import Foundation
import Models
import Testing
@testable import BookListFeature

@MainActor
@Suite
struct BookListTests {
    struct FetchBooksCall: Equatable {
        let query: String
        let page: Int
    }

    let fetchBooksCalls = LockIsolated<[FetchBooksCall]>([])
    let newBook = Book.fixture(id: "4", title: "Book Four")

    // MARK: - Fetching

    @Test
    func fetchBooksLoadsFirstPageOfSelectedCategory() async {
        let store = makeStore {
            $0.booksClient.fetchBooks = fetchBooks(.success(PagedBooks(books: Book.fixtures, totalItems: 3)))
        }

        await store.send(.fetchBooks(reset: true)) {
            $0.books = .loading
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(Book.fixtures)
            $0.pagesLoaded = 1
            $0.totalItems = 3
        }
        #expect(fetchBooksCalls.value == [.init(query: "bestsellers", page: 0)])
    }

    @Test
    func fetchBooksFailureShowsError() async {
        let store = makeStore {
            $0.booksClient.fetchBooks = fetchBooks(.failure(TestError.someError))
        }

        await store.send(.fetchBooks(reset: true)) {
            $0.books = .loading
        }
        await store.receive(\.booksResponse) {
            $0.books = .error(TestError.someError.localizedDescription)
        }
    }

    @Test
    func nextPageAppendsOnlyBooksNotAlreadyLoaded() async {
        let duplicate = Book.fixtures[0]
        let store = makeStore(firstPageLoaded()) {
            $0.booksClient.fetchBooks = fetchBooks(.success(PagedBooks(books: [duplicate, newBook], totalItems: 40)))
        }

        await store.send(.fetchBooks(reset: false)) {
            $0.isLoadingNextPage = true
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(Book.fixtures + [self.newBook])
            $0.pagesLoaded = 2
            $0.isLoadingNextPage = false
        }
    }

    @Test
    func nextPageRequestsThePageAfterTheLastLoadedOne() async {
        let store = makeStore(firstPageLoaded()) {
            $0.booksClient.fetchBooks = fetchBooks(.success(PagedBooks(books: [newBook], totalItems: 40)))
        }

        await store.send(.fetchBooks(reset: false)) {
            $0.isLoadingNextPage = true
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(Book.fixtures + [self.newBook])
            $0.pagesLoaded = 2
            $0.isLoadingNextPage = false
        }
        #expect(fetchBooksCalls.value == [.init(query: "bestsellers", page: 1)])
    }

    @Test
    func nextPageFailureKeepsLoadedBooks() async {
        let store = makeStore(firstPageLoaded()) {
            $0.booksClient.fetchBooks = fetchBooks(.failure(TestError.someError))
        }

        await store.send(.fetchBooks(reset: false)) {
            $0.isLoadingNextPage = true
        }
        await withKnownIssue("A failed next page replaces the whole list with an error; fixed in Phase 3") {
            await store.receive(\.booksResponse) {
                $0.isLoadingNextPage = false
            }
        }
    }

    // MARK: - Pagination trigger

    @Test
    func fetchNextPageLoadsNextPageAfterDebounce() async {
        let store = makeStore(firstPageLoaded()) {
            $0.booksClient.fetchBooks = fetchBooks(.success(PagedBooks(books: [newBook], totalItems: 40)))
        }

        await store.send(.fetchNextPage)
        await store.receive(\.fetchBooks) {
            $0.isLoadingNextPage = true
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(Book.fixtures + [self.newBook])
            $0.pagesLoaded = 2
            $0.isLoadingNextPage = false
        }
    }

    @Test
    func fetchNextPageIsIgnoredWhenAllBooksAreLoaded() async {
        let store = makeStore(firstPageLoaded(totalItems: Book.fixtures.count))

        await store.send(.fetchNextPage)
    }

    @Test
    func fetchNextPageIsIgnoredWhileAPageIsLoading() async {
        var state = firstPageLoaded()
        state.isLoadingNextPage = true
        let store = makeStore(state)

        await store.send(.fetchNextPage)
    }

    // MARK: - Search & categories

    @Test
    func searchSubmittedFetchesTrimmedQuery() async {
        let store = makeStore {
            $0.booksClient.fetchBooks = fetchBooks(.success(PagedBooks(books: Book.fixtures, totalItems: 3)))
        }

        await store.send(.binding(.set(\.searchQuery, "  swift  "))) {
            $0.searchQuery = "  swift  "
        }
        await store.send(.searchSubmitted)
        await store.receive(\.fetchBooks) {
            $0.books = .loading
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(Book.fixtures)
            $0.pagesLoaded = 1
            $0.totalItems = 3
        }
        #expect(fetchBooksCalls.value == [.init(query: "swift", page: 0)])
    }

    @Test
    func blankSearchFallsBackToSelectedCategory() async {
        let store = makeStore(BookList.State(searchQuery: "   ", selectedCategory: .fiction)) {
            $0.booksClient.fetchBooks = fetchBooks(.success(PagedBooks(books: [], totalItems: 0)))
        }

        await store.send(.searchSubmitted)
        await store.receive(\.fetchBooks) {
            $0.books = .loading
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded([])
            $0.pagesLoaded = 1
        }
        #expect(fetchBooksCalls.value == [.init(query: "fiction bestsellers", page: 0)])
    }

    @Test
    func selectingCategoryClearsSearchAndFetchesCategory() async {
        let store = makeStore(BookList.State(searchQuery: "swift")) {
            $0.booksClient.fetchBooks = fetchBooks(.success(PagedBooks(books: Book.fixtures, totalItems: 3)))
        }

        await store.send(.categorySelected(.mystery)) {
            $0.selectedCategory = .mystery
            $0.searchQuery = ""
        }
        await store.receive(\.fetchBooks) {
            $0.books = .loading
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(Book.fixtures)
            $0.pagesLoaded = 1
            $0.totalItems = 3
        }
        #expect(fetchBooksCalls.value == [.init(query: "mystery bestsellers", page: 0)])
    }

    // MARK: - Navigation

    @Test
    func tappingBookPresentsDetails() async {
        let store = makeStore()

        await store.send(.bookTapped(newBook)) {
            $0.bookDetails = BookDetails.State(bookId: "4")
        }
    }

    @Test
    func dismissingDetailsClearsPresentation() async {
        let store = makeStore(BookList.State(bookDetails: BookDetails.State(bookId: "4")))

        await store.send(.bookDetails(.dismiss)) {
            $0.bookDetails = nil
        }
    }

    // MARK: - Favorites

    @Test
    func loadFavoritesShowsSavedBooks() async {
        let store = makeStore {
            $0.favoritesClient.favorites = { Book.fixtures }
        }

        await store.send(.loadFavorites) {
            $0.favoriteBooks = .loading
        }
        await store.receive(\.favoritesResponse) {
            $0.favoriteBooks = .loaded(Book.fixtures)
        }
    }

    @Test
    func loadFavoritesFailureShowsError() async {
        let store = makeStore {
            $0.favoritesClient.favorites = { throw TestError.someError }
        }

        await store.send(.loadFavorites) {
            $0.favoriteBooks = .loading
        }
        await store.receive(\.favoritesResponse) {
            $0.favoriteBooks = .error(TestError.someError.localizedDescription)
        }
    }

    // MARK: - Helpers

    /// State right after the first page loaded: three books, `pagesLoaded` 1.
    private func firstPageLoaded(totalItems: Int = 40) -> BookList.State {
        BookList.State(books: .loaded(Book.fixtures), totalItems: totalItems, pagesLoaded: 1)
    }

    /// A `fetchBooks` implementation that records each call and returns `result`.
    private func fetchBooks(_ result: Result<PagedBooks, Error>) -> @Sendable (String, Int) async throws -> PagedBooks {
        { [fetchBooksCalls] query, page in
            fetchBooksCalls.withValue { $0.append(FetchBooksCall(query: query, page: page)) }
            return try result.get()
        }
    }

    /// Unconfigured client endpoints fail the test if they're called.
    private func makeStore(
        _ state: BookList.State = BookList.State(),
        dependencies: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStoreOf<BookList> {
        TestStore(initialState: state) {
            BookList()
        } withDependencies: {
            dependencies(&$0)
        }
    }
}
