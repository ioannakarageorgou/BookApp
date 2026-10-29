import BooksClient
import ComposableArchitecture
import FavoritesClient
import Foundation
import Models

@Reducer
struct BookDetails {
    @ObservableState
    struct State: Equatable {
        let bookId: String
        var bookDetails: Loading<Details> = .idle
        var isFavorite: Bool = false
    }

    enum Action {
        case fetchDetails
        case bookDetailsResponse(Result<Details, Error>)
        case toggleFavoriteTapped
    }

    @Dependency(\.booksClient) var booksClient
    @Dependency(\.favoritesClient) var favoritesClient

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .fetchDetails:
            state.bookDetails = .loading
            return .run { [bookId = state.bookId] send in
                do {
                    let details = try await booksClient.fetchBookDetails(id: bookId)
                    await send(.bookDetailsResponse(.success(details)))
                } catch {
                    await send(.bookDetailsResponse(.failure(error)))
                }
            }

        case let .bookDetailsResponse(.success(details)):
            state.bookDetails = .loaded(details)
            state.isFavorite = favoritesClient.isFavorite(id: details.core.id)
            return .none

        case let .bookDetailsResponse(.failure(error)):
            state.bookDetails = .error(error.localizedDescription)
            return .none

        case .toggleFavoriteTapped:
            guard let book = state.bookDetails.value?.core else {
                return .none
            }
            do {
                if state.isFavorite {
                    try favoritesClient.remove(id: book.id)
                    state.isFavorite = false
                } else {
                    try favoritesClient.add(book: book)
                    state.isFavorite = true
                }
            } catch {
                // TODO: Optionally log or handle the error
                // For now, maybe just print it or set a .error state
                print("Failed to update favorites: \(error)")
            }
            return .none
        }
    }
}
