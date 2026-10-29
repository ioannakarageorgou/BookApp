import BooksClient
import ComposableArchitecture
import FavoritesClient
import Foundation
import Models

@Reducer
struct BookList {
    @ObservableState
    struct State: Equatable {
        var books: Loading<[Book]> = .idle
        @Presents var bookDetails: BookDetails.State?

        // MARK: - Search & Filters
        var searchQuery: String = ""
        var selectedCategory: Category = .all

        // MARK: - Pagination
        var isLoadingNextPage = false
        var totalItems: Int = 0
        var currentPage = 0
        var hasMorePages: Bool {
            switch books {
            case .loaded(let loadedBooks):
                return loadedBooks.count < totalItems
            default:
                return false
            }
        }

        // MARK: - Favorites
        var favoriteBooks: Loading<[Book]> = .idle

        // MARK: - Categories
        enum Category: String, CaseIterable, Equatable {
            case all = "All"
            case popular = "Popular"
            case fiction = "Fiction"
            case nonFiction = "Non-Fiction"
            case mystery = "Mystery"

            var searchQuery: String {
                switch self {
                case .all: return "bestsellers"
                case .popular: return "bestsellers"
                case .fiction: return "fiction bestsellers"
                case .nonFiction: return "nonfiction bestsellers"
                case .mystery: return "mystery bestsellers"
                }
            }
        }
    }

    @CasePathable
    enum Action: BindableAction {
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

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

                // MARK: - Books Fetching
            case let .fetchBooks(reset):
                if reset {
                    state.books = .loading
                    state.currentPage = 0
                    state.isLoadingNextPage = false
                } else {
                    state.isLoadingNextPage = true
                }

                let page = reset ? 0 : state.currentPage + 1

                // Determine query: user search takes precedence, otherwise use category
                let query: String
                if !state.searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
                    query = state.searchQuery.trimmingCharacters(in: .whitespaces)
                } else {
                    query = state.selectedCategory.searchQuery
                }

                return .run { send in
                    do {
                        let pagedBooks = try await booksClient.fetchBooks(query: query, page: page)
                        await send(.booksResponse(.success(pagedBooks)))
                    } catch {
                        await send(.booksResponse(.failure(error)))
                    }
                }

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

                state.currentPage += 1
                state.totalItems = pagedBooks.totalItems
                return .none

            case let .booksResponse(.failure(error)):
                state.isLoadingNextPage = false
                state.books = .error(error.localizedDescription)
                return .none

            case .fetchNextPage:
                guard !state.isLoadingNextPage, state.hasMorePages else { return .none }
                return .send(.fetchBooks(reset: false))
                    .debounce(id: CancelID.fetchNextPageDebounce, for: 0.5, scheduler: DispatchQueue.main)

                // MARK: - Search & Categories
            case .searchSubmitted:
                return .send(.fetchBooks(reset: true))

            case let .categorySelected(category):
                state.selectedCategory = category
                // Clear search when switching categories
                state.searchQuery = ""
                return .send(.fetchBooks(reset: true))

                // MARK: - Navigation
            case .bookTapped(let book):
                state.bookDetails = BookDetails.State(bookId: book.id)
                return .none

            case .bookDetails:
                return .none

                // MARK: - Favorites
            case .loadFavorites:
                state.favoriteBooks = .loading
                return .run { send in
                    do {
                        let favorites = try favoritesClient.favorites()
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
        case fetchNextPageDebounce
    }
}
