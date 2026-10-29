import BooksClient
import ComposableArchitecture
import FavoritesClient
import Foundation
import Models

@Reducer
public struct BookDetails {
    @ObservableState
    public struct State: Equatable {
        public let bookId: String
        public var bookDetails: Loading<Details>
        public var isFavorite: Bool

        package init(bookId: String, bookDetails: Loading<Details> = .idle, isFavorite: Bool = false) {
            self.bookId = bookId
            self.bookDetails = bookDetails
            self.isFavorite = isFavorite
        }
    }

    public enum Action {
        case fetchDetails
        case bookDetailsResponse(Result<Details, Error>)
        case toggleFavoriteTapped
    }

    @Dependency(\.booksClient) var booksClient
    @Dependency(\.favoritesClient) var favoritesClient

    package init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
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
}
