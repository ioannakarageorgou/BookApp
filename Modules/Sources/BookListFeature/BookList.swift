import BookDetailsFeature
import BooksClient
import ComposableArchitecture
import FavoritesClient
import Foundation
import Models

@Reducer
public struct BookList {
    @ObservableState
    public struct State: Equatable {
        public var books: Loading<[Book]>
        @Presents public var bookDetails: BookDetails.State?

        // MARK: - Search & Filters
        public var searchQuery: String
        public var selectedCategory: Category

        // MARK: - Pagination
        public var isLoadingNextPage: Bool
        /// Set when loading the next page fails; the books already loaded stay visible.
        public var nextPageError: String?
        public var totalItems: Int
        public var pagesLoaded: Int
        public var hasMorePages: Bool {
            switch books {
            case .loaded(let loadedBooks):
                return loadedBooks.count < totalItems
            default:
                return false
            }
        }

        // MARK: - Favorites
        public var favoriteBooks: Loading<[Book]>

        // MARK: - Categories
        public enum Category: String, CaseIterable, Equatable {
            case all = "All"
            case popular = "Popular"
            case fiction = "Fiction"
            case nonFiction = "Non-Fiction"
            case mystery = "Mystery"

            public var searchQuery: String {
                switch self {
                case .all: return "bestsellers"
                case .popular: return "bestsellers"
                case .fiction: return "fiction bestsellers"
                case .nonFiction: return "nonfiction bestsellers"
                case .mystery: return "mystery bestsellers"
                }
            }
        }

        public init(
            books: Loading<[Book]> = .idle,
            bookDetails: BookDetails.State? = nil,
            searchQuery: String = "",
            selectedCategory: Category = .all,
            isLoadingNextPage: Bool = false,
            nextPageError: String? = nil,
            totalItems: Int = 0,
            pagesLoaded: Int = 0,
            favoriteBooks: Loading<[Book]> = .idle
        ) {
            self.books = books
            self.bookDetails = bookDetails
            self.searchQuery = searchQuery
            self.selectedCategory = selectedCategory
            self.isLoadingNextPage = isLoadingNextPage
            self.nextPageError = nextPageError
            self.totalItems = totalItems
            self.pagesLoaded = pagesLoaded
            self.favoriteBooks = favoriteBooks
        }
    }

    @CasePathable
    public enum Action: BindableAction {
        case binding(BindingAction<State>)

        // MARK: - Books
        case fetchBooks(reset: Bool = true)
        case booksResponse(Result<PagedBooks, Error>)
        case fetchNextPage

        // MARK: - Search & Categories
        case searchSubmitted
        case categorySelected(State.Category)

        // MARK: - Navigation
        case bookTapped(Book)
        case bookDetails(PresentationAction<BookDetails.Action>)

        // MARK: - Favorites
        case loadFavorites
        case favoritesResponse(Result<[Book], Error>)
    }

    @Dependency(\.booksClient) var booksClient
    @Dependency(\.favoritesClient) var favoritesClient
    @Dependency(\.continuousClock) var clock

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

                // MARK: - Books Fetching
            case let .fetchBooks(reset):
                state.nextPageError = nil
                if reset {
                    state.books = .loading
                    state.pagesLoaded = 0
                    state.isLoadingNextPage = false
                } else {
                    state.isLoadingNextPage = true
                }

                let page = reset ? 0 : state.pagesLoaded

                let query: String
                if !state.searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
                    query = state.searchQuery.trimmingCharacters(in: .whitespaces)
                } else {
                    query = state.selectedCategory.searchQuery
                }

                return .run { [booksClient] send in
                    do {
                        let pagedBooks = try await booksClient.fetchBooks(query: query, page: page)
                        await send(.booksResponse(.success(pagedBooks)))
                    } catch {
                        await send(.booksResponse(.failure(error)))
                    }
                }
                // A new search or page replaces any request still in flight, so a stale
                // response can never land in the new list.
                .cancellable(id: CancelID.fetchBooks, cancelInFlight: true)

            case let .booksResponse(.success(pagedBooks)):
                state.isLoadingNextPage = false

                switch state.books {
                case .loaded(let existing):
                    let existingIDs = Set(existing.map(\.id))
                    let onlyNew = pagedBooks.books.filter { !existingIDs.contains($0.id) }
                    state.books = .loaded(existing + onlyNew)
                default:
                    state.books = .loaded(pagedBooks.books)
                }

                state.pagesLoaded += 1
                state.totalItems = pagedBooks.totalItems
                return .none

            case let .booksResponse(.failure(error)):
                state.isLoadingNextPage = false
                if case .loaded = state.books {
                    // A next page failed: keep the books the user is looking at.
                    state.nextPageError = error.localizedDescription
                } else {
                    state.books = .error(error.localizedDescription)
                }
                return .none

            case .fetchNextPage:
                // After a failed page, wait for the user to tap Retry instead of retrying on every scroll.
                guard !state.isLoadingNextPage, state.nextPageError == nil, state.hasMorePages else { return .none }
                // Debounce: each call restarts the wait, so a burst of calls loads one page.
                return .run { [clock] send in
                    try await clock.sleep(for: .milliseconds(500))
                    await send(.fetchBooks(reset: false))
                }
                .cancellable(id: CancelID.fetchNextPageDebounce, cancelInFlight: true)

                // MARK: - Search & Categories
            case .searchSubmitted:
                return .send(.fetchBooks(reset: true))

            case let .categorySelected(category):
                state.selectedCategory = category
                state.searchQuery = ""
                return .send(.fetchBooks(reset: true))

                // MARK: - Navigation
            case .bookTapped(let book):
                state.bookDetails = BookDetails.State(bookId: book.id)
                return .none

            case .bookDetails(.presented(.delegate(.favoritesChanged))):
                // The shelf shows favorites too, so refresh it whenever details changes them.
                return .send(.loadFavorites)

            case .bookDetails:
                return .none

                // MARK: - Favorites
            case .loadFavorites:
                // Keep the shelf visible while refreshing so it doesn't flicker.
                if case .loaded = state.favoriteBooks {} else {
                    state.favoriteBooks = .loading
                }
                return .run { [favoritesClient] send in
                    do {
                        let favorites = try await favoritesClient.favorites()
                        await send(.favoritesResponse(.success(favorites)))
                    } catch {
                        await send(.favoritesResponse(.failure(error)))
                    }
                }

            case let .favoritesResponse(.success(favorites)):
                state.favoriteBooks = .loaded(favorites)
                return .none

            case let .favoritesResponse(.failure(error)):
                state.favoriteBooks = .error(error.localizedDescription)
                return .none
            }
        }
        .ifLet(\.$bookDetails, action: \.bookDetails) {
            BookDetails()
        }
    }
}

private extension BookList {
    enum CancelID {
        case fetchBooks
        case fetchNextPageDebounce
    }
}
