import ComposableArchitecture
import Foundation
import Testing
@testable import BookApp

@MainActor
@Suite
struct BookListTests {
    let repository = MockBooksRepository()
    let newBook = Book.fixture(id: "4", title: "Book Four")

    // MARK: - Fetching

    @Test
    func fetchBooksLoadsFirstPageOfSelectedCategory() async {
        repository.fetchBooksResult = .success(PagedBooks(books: Book.fixtures, totalItems: 3))
        let store = makeStore()

        await store.send(.fetchBooks(reset: true)) {
            $0.books = .loading
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(Book.fixtures)
            $0.currentPage = 1
            $0.totalItems = 3
        }
        #expect(repository.fetchBooksCalls.value == [.init(query: "bestsellers", page: 0)])
    }

    @Test
    func fetchBooksFailureShowsError() async {
        repository.fetchBooksResult = .failure(TestError.someError)
        let store = makeStore()

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
        repository.fetchBooksResult = .success(PagedBooks(books: [duplicate, newBook], totalItems: 40))
        let store = makeStore(firstPageLoaded())

        await store.send(.fetchBooks(reset: false)) {
            $0.isLoadingNextPage = true
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(Book.fixtures + [newBook])
            $0.currentPage = 2
            $0.isLoadingNextPage = false
        }
    }

    @Test
    func nextPageRequestsThePageAfterTheLastLoadedOne() async {
        repository.fetchBooksResult = .success(PagedBooks(books: [newBook], totalItems: 40))
        let store = makeStore(firstPageLoaded())

        await store.send(.fetchBooks(reset: false)) {
            $0.isLoadingNextPage = true
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(Book.fixtures + [newBook])
            $0.currentPage = 2
            $0.isLoadingNextPage = false
        }
        withKnownIssue("Requests page 2 after the first page, skipping results 21–40; fixed in Phase 3") {
            #expect(repository.fetchBooksCalls.value == [.init(query: "bestsellers", page: 1)])
        }
    }

    @Test
    func nextPageFailureKeepsLoadedBooks() async {
        repository.fetchBooksResult = .failure(TestError.someError)
        let store = makeStore(firstPageLoaded())

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
        repository.fetchBooksResult = .success(PagedBooks(books: [newBook], totalItems: 40))
        let store = makeStore(firstPageLoaded())

        await store.send(.fetchNextPage)
        await store.receive(\.fetchBooks) {
            $0.isLoadingNextPage = true
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(Book.fixtures + [newBook])
            $0.currentPage = 2
            $0.isLoadingNextPage = false
        }
    }

    @Test
    func fetchNextPageIsIgnoredWhenAllBooksAreLoaded() async {
        let store = makeStore(firstPageLoaded(totalItems: Book.fixtures.count))

        await store.send(.fetchNextPage)
        #expect(repository.fetchBooksCalls.value.isEmpty)
    }

    @Test
    func fetchNextPageIsIgnoredWhileAPageIsLoading() async {
        var state = firstPageLoaded()
        state.isLoadingNextPage = true
        let store = makeStore(state)

        await store.send(.fetchNextPage)
        #expect(repository.fetchBooksCalls.value.isEmpty)
    }

    // MARK: - Search & categories

    @Test
    func searchSubmittedFetchesTrimmedQuery() async {
        repository.fetchBooksResult = .success(PagedBooks(books: Book.fixtures, totalItems: 3))
        let store = makeStore()

        await store.send(.binding(.set(\.searchQuery, "  swift  "))) {
            $0.searchQuery = "  swift  "
        }
        await store.send(.searchSubmitted)
        await store.receive(\.fetchBooks) {
            $0.books = .loading
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(Book.fixtures)
            $0.currentPage = 1
            $0.totalItems = 3
        }
        #expect(repository.fetchBooksCalls.value == [.init(query: "swift", page: 0)])
    }

    @Test
    func blankSearchFallsBackToSelectedCategory() async {
        repository.fetchBooksResult = .success(PagedBooks(books: [], totalItems: 0))
        let store = makeStore(BookList.State(searchQuery: "   ", selectedCategory: .fiction))

        await store.send(.searchSubmitted)
        await store.receive(\.fetchBooks) {
            $0.books = .loading
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded([])
            $0.currentPage = 1
        }
        #expect(repository.fetchBooksCalls.value == [.init(query: "fiction bestsellers", page: 0)])
    }

    @Test
    func selectingCategoryClearsSearchAndFetchesCategory() async {
        repository.fetchBooksResult = .success(PagedBooks(books: Book.fixtures, totalItems: 3))
        let store = makeStore(BookList.State(searchQuery: "swift"))

        await store.send(.categorySelected(.mystery)) {
            $0.selectedCategory = .mystery
            $0.searchQuery = ""
        }
        await store.receive(\.fetchBooks) {
            $0.books = .loading
        }
        await store.receive(\.booksResponse) {
            $0.books = .loaded(Book.fixtures)
            $0.currentPage = 1
            $0.totalItems = 3
        }
        #expect(repository.fetchBooksCalls.value == [.init(query: "mystery bestsellers", page: 0)])
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
        repository.getFavoriteBooksResult = .success(Book.fixtures)
        let store = makeStore()

        await store.send(.loadFavorites) {
            $0.favoriteBooks = .loading
        }
        await store.receive(\.favoritesResponse) {
            $0.favoriteBooks = .loaded(Book.fixtures)
        }
    }

    @Test
    func loadFavoritesFailureShowsError() async {
        repository.getFavoriteBooksResult = .failure(TestError.someError)
        let store = makeStore()

        await store.send(.loadFavorites) {
            $0.favoriteBooks = .loading
        }
        await store.receive(\.favoritesResponse) {
            $0.favoriteBooks = .error(TestError.someError.localizedDescription)
        }
    }

    // MARK: - Helpers

    /// State right after the first page loaded: three books, `currentPage` 1.
    private func firstPageLoaded(totalItems: Int = 40) -> BookList.State {
        BookList.State(books: .loaded(Book.fixtures), totalItems: totalItems, currentPage: 1)
    }

    private func makeStore(_ state: BookList.State = BookList.State()) -> TestStoreOf<BookList> {
        TestStore(initialState: state) {
            BookList()
        } withDependencies: { [repository] in
            $0.booksRepository = repository
        }
    }
}
