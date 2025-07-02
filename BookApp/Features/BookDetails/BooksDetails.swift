import Foundation
import ComposableArchitecture

@Reducer
struct BookDetails {
    @ObservableState
    struct State: Equatable {
        let bookId: String
        var bookDetails: Loading<Details> = .idle
    }

    enum Action {
        case fetchDetails
        case bookDetailsResponse(Result<Details, Error>)
    }

    @Dependency(\.booksRepository) var booksRepository

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .fetchDetails:
            state.bookDetails = .loading
            return .run { [bookId = state.bookId] send in
                do {
                    let details = try await booksRepository.fetchBookDetails(id: bookId)
                    await send(.bookDetailsResponse(.success(details)))
                } catch {
                    await send(.bookDetailsResponse(.failure(error)))
                }
            }

        case let .bookDetailsResponse(.success(details)):
            state.bookDetails = .loaded(details)
            return .none

        case let .bookDetailsResponse(.failure(error)):
            state.bookDetails = .error(error.localizedDescription)
            return .none
        }
    }
}
