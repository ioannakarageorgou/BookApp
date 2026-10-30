import BooksClient
import ComposableArchitecture
import FavoritesClient
import Foundation
import Models
import OSLog

private let logger = Logger(subsystem: "BookApp", category: "bookDetails")

@Reducer
public struct BookDetails {
    @ObservableState
    public struct State: Equatable {
        public let bookId: String
        public var bookDetails: Loading<Details>
        public var isFavorite: Bool
        /// True while an add/remove is being saved; further taps are ignored until it finishes.
        public var isUpdatingFavorite: Bool
        @Presents public var alert: AlertState<Action.Alert>?

        package init(
            bookId: String,
            bookDetails: Loading<Details> = .idle,
            isFavorite: Bool = false,
            isUpdatingFavorite: Bool = false,
            alert: AlertState<Action.Alert>? = nil
        ) {
            self.bookId = bookId
            self.bookDetails = bookDetails
            self.isFavorite = isFavorite
            self.isUpdatingFavorite = isUpdatingFavorite
            self.alert = alert
        }
    }

    public enum Action {
        case fetchDetails
        case bookDetailsResponse(Result<Details, Error>)
        case favoriteStatusLoaded(Bool)
        case toggleFavoriteTapped
        /// The saved favorite state, or the error that prevented saving it.
        case alert(PresentationAction<Alert>)
        case toggleFavoriteResponse(Result<Bool, Error>)
        case delegate(Delegate)

        public enum Alert: Equatable {
            case dismissed
        }

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
                state.alert = AlertState {
                    TextState("Could not update shelf")
                } actions: {
                    ButtonState(role: .cancel, action: .dismissed) {
                        TextState("OK")
                    }
                } message: {
                    TextState("Please try again.")
                }
                logger.error("Failed to toggle favorite: \(error)")
                return .none

            case .alert:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
