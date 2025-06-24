import Foundation
import ComposableArchitecture

@Reducer
struct BookList {
    struct State: Equatable {
        var books: Loading<[Book]> = .idle
        var searchQuery: String = ""
    }

    enum Action {
        case fetchBooks
        case booksResponse(Result<[Book], Error>)
        case searchQueryChanged(String)
    }

    let booksRepository: BooksRepositoryProviding

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .fetchBooks:
            state.books = .loading
            let query = state.searchQuery.isEmpty ? "*" : state.searchQuery
            return .run { send in
                do {
                    let books = try await booksRepository.fetchBooks(query: query)
                    await send(.booksResponse(.success(books)))
                } catch {
                    await send(.booksResponse(.failure(error)))
                }
            }

        case let .searchQueryChanged(query):
            state.searchQuery = query
            return .none

        case let .booksResponse(.success(books)):
            state.books = .loaded(books)
            return .none

        case let .booksResponse(.failure(error)):
            state.books = .error("Oops, something went wrong: \(error.localizedDescription)")
            return .none
        }
    }
}
