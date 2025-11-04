import Foundation
import ComposableArchitecture

@Reducer
struct BookList {
    @ObservableState
    struct State: Equatable {
        var books: Loading<[Book]> = .idle
        var searchQuery: String = ""

        var favoriteBooks: Loading<[Book]> = .idle

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

        var selectedBookID: String?
        var bookDetails: BookDetails.State?
    }

    @CasePathable
    enum Action {
        case fetchBooks(reset: Bool = true)
        case booksResponse(Result<PagedBooks, Error>)
        case searchQueryChanged(String)
        case fetchNextPage

        case bookTapped(Book)
        case bookDetails(BookDetails.Action)
        case dismissBookDetails

        case loadFavorites
        case favoritesResponse(Result<[Book], Error>)
    }

    @Dependency(\.booksRepository) var booksRepository

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .fetchBooks(reset):
                if reset {
                    state.books = .loading
                    state.currentPage = 0
                    state.isLoadingNextPage = false
                } else {
                    state.isLoadingNextPage = true
                }

                let page = reset ? 0 : state.currentPage + 1
                let query = state.searchQuery.isEmpty ? "bestsellers" : state.searchQuery.trimmingCharacters(in: .whitespaces)

                return .run { send in
                    do {
                        let pagedBooks = try await booksRepository.fetchBooks(query: query, page: page)
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

            case let .searchQueryChanged(query):
                state.searchQuery = query
                return .none

            case .fetchNextPage:
                guard !state.isLoadingNextPage else { return .none }
                return .send(.fetchBooks(reset: false))
                    .debounce(id: CancelID.fetchNextPageDebounce, for: 0.5, scheduler: DispatchQueue.main)

            case .bookTapped(let book):
                state.selectedBookID = book.id
                state.bookDetails = BookDetails.State(bookId: book.id)
                return .none

            case .dismissBookDetails:
                state.selectedBookID = nil
                state.bookDetails = nil
                return .none

            case .bookDetails:
                return .none

            case .loadFavorites:
                state.favoriteBooks = .loading
                return .run { send in
                    do {
                        let favorites = try booksRepository.getFavoriteBooks()
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
        .ifLet(\.bookDetails, action: \.bookDetails) {
            BookDetails()
        }
    }
}

private extension BookList {
    enum CancelID {
        case fetchNextPageDebounce
    }
}
