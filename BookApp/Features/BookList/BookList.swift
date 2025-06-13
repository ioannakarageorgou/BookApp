import Foundation
import ComposableArchitecture

@Reducer
struct BookList {
    struct State: Equatable {
        var books: [Book] = []
        var isLoading: Bool = false
        var errorMessage: String?
    }

    enum Action {
        case onAppear
        case booksResponse(Result<[Book], Error>)
    }

    let booksRepository: BooksRepositoryProviding

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            state.isLoading = true
            state.errorMessage = nil
            return .run { send in
                do {
                    let books = try await booksRepository.fetchBooks(query: "harry potter")
                    await send(.booksResponse(.success(books)))
                } catch {
                    await send(.booksResponse(.failure(error)))
                }
            }

        case let .booksResponse(.success(books)):
            state.isLoading = false
            state.books = books
            return .none

        case .booksResponse(.failure):
            state.isLoading = false
            state.errorMessage = "opps, error"
            state.books = []
            return .none
        }
    }
}
