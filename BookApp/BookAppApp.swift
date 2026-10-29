import BookListFeature
import BooksClient
import BooksClientLive
import ComposableArchitecture
import FavoritesClient
import FavoritesClientLive
import SwiftUI

@main
struct BookAppApp: App {
    /// The composition root: the only place that chooses live implementations.
    @MainActor
    static let store = Store(initialState: BookList.State()) {
        BookList()
    } withDependencies: {
        $0.booksClient = .live(apiKey: Secrets.googleBooksAPIKey)
        $0.favoritesClient = .live()
    }

    var body: some Scene {
        WindowGroup {
            // Unit tests run inside the app; skip the real UI so it never hits the live API.
            if !isTesting {
                BookListView(store: Self.store)
            }
        }
    }
}
