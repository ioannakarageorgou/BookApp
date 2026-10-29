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
        /// True while an add/remove is being saved; further taps are ignored until it finishes.
        public var isUpdatingFavorite: Bool

        package init(
            bookId: String,
            bookDetails: Loading<Details> = .idle,
            isFavorite: Bool = false,
            isUpdatingFavorite: Bool = false
        ) {
            self.bookId = bookId
            self.bookDetails = bookDetails
            self.isFavorite = isFavorite
            self.isUpdatingFavorite = isUpdatingFavorite
        }
    }

    public enum Action {
        case fetchDetails
        case bookDetailsResponse(Result<Details, Error>)
        case favoriteStatusLoaded(Bool)
        case toggleFavoriteTapped
        /// The saved favorite state, or the error that prevented saving it.
        case toggleFavoriteResponse(Result<Bool, Error>)
        case delegate(Delegate)

        /// Announcements for the parent feature; BookDetails never handles these itself.
        @CasePathable
        public enum Delegate: Equatable {
            case favoritesChanged
        }
    }

    @Dependency(\.booksClient) var booksClient
    @Dependency(\.favoritesClient) var favoritesClient

    package init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchDetails:
                state.bookDetails = .loading
                return .run { [bookId = state.bookId, booksClient, favoritesClient] send in
                    do {
                        let details = try await booksClient.fetchBookDetails(id: bookId)
                        await send(.bookDetailsResponse(.success(details)))
                    } catch {
                        await send(.bookDetailsResponse(.failure(error)))
                        return
                    }
                    await send(.favoriteStatusLoaded(favoritesClient.isFavorite(id: bookId)))
                }

            case let .bookDetailsResponse(.success(details)):
                state.bookDetails = .loaded(details)
                return .none

            case let .bookDetailsResponse(.failure(error)):
                state.bookDetails = .error(error.localizedDescription)
                return .none

            case let .favoriteStatusLoaded(isFavorite):
                state.isFavorite = isFavorite
                return .none

            case .toggleFavoriteTapped:
                guard !state.isUpdatingFavorite, let book = state.bookDetails.value?.core else {
                    return .none
                }
                state.isUpdatingFavorite = true
                return .run { [isFavorite = state.isFavorite, favoritesClient] send in
                    let result = await Result {
                        if isFavorite {
                            try await favoritesClient.remove(id: book.id)
                        } else {
                            try await favoritesClient.add(book: book)
                        }
                        return !isFavorite
                    }
                    await send(.toggleFavoriteResponse(result))
                }

            case let .toggleFavoriteResponse(.success(isFavorite)):
                state.isUpdatingFavorite = false
                state.isFavorite = isFavorite
                return .send(.delegate(.favoritesChanged))

            case let .toggleFavoriteResponse(.failure(error)):
                state.isUpdatingFavorite = false
                // TODO: Optionally log or handle the error
                // For now, maybe just print it or set a .error state
                print("Failed to update favorites: \(error)")
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
