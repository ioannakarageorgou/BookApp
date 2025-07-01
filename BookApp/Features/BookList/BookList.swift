import Foundation
import ComposableArchitecture

@Reducer
struct BookList {
    @ObservableState
    struct State: Equatable {
        var books: Loading<[Book]> = .idle
        var searchQuery: String = ""

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

    enum Action {
        case fetchBooks(reset: Bool = true)
        case booksResponse(Result<PagedBooks, Error>)
        case searchQueryChanged(String)
        case fetchNextPage

        case bookTapped(Book)
        case bookDetails(BookDetails.Action)
        case dismissBookDetails
    }

    let booksRepository: BooksRepositoryProviding

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
                var allBooks: [Book] = []

                switch state.books {
                case .loaded(let existingBooks):
                    allBooks = existingBooks + pagedBooks.books
                default:
                    allBooks = pagedBooks.books
                }
                let deduplicated = Dictionary(grouping: allBooks, by: \.id).compactMap { $0.value.first }

                state.books = .loaded(deduplicated)
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
                return .send(.fetchBooks(reset: false))

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
            }
        }
        .ifLet(\.bookDetails, action: \.bookDetails) {
            BookDetails(booksRepository: booksRepository)
        }
    }
}
