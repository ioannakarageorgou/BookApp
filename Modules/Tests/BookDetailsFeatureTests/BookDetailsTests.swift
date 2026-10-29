import BooksClient
import ComposableArchitecture
import FavoritesClient
import Models
import Testing
@testable import BookDetailsFeature

@MainActor
@Suite
struct BookDetailsTests {
    let details = Details.fixture()

    @Test
    func fetchDetailsLoadsDetailsAndFavoriteState() async {
        let requestedIDs = LockIsolated<[Book.ID]>([])
        let store = makeStore(BookDetails.State(bookId: details.core.id)) { [details] in
            $0.booksClient.fetchBookDetails = { id in
                requestedIDs.withValue { $0.append(id) }
                return details
            }
            $0.favoritesClient.isFavorite = { _ in true }
        }

        await store.send(.fetchDetails) {
            $0.bookDetails = .loading
        }
        await store.receive(\.bookDetailsResponse) {
            $0.bookDetails = .loaded(self.details)
            $0.isFavorite = true
        }
        #expect(requestedIDs.value == [details.core.id])
    }

    @Test
    func fetchDetailsFailureShowsError() async {
        let store = makeStore(BookDetails.State(bookId: "bad")) {
            $0.booksClient.fetchBookDetails = { _ in throw TestError.someError }
        }

        await store.send(.fetchDetails) {
            $0.bookDetails = .loading
        }
        await store.receive(\.bookDetailsResponse) {
            $0.bookDetails = .error(TestError.someError.localizedDescription)
        }
    }

    @Test
    func toggleFavoriteAddsBookToShelf() async {
        let added = LockIsolated<[Book]>([])
        let store = makeStore(loaded(isFavorite: false)) {
            $0.favoritesClient.add = { book in added.withValue { $0.append(book) } }
        }

        await store.send(.toggleFavoriteTapped) {
            $0.isFavorite = true
        }
        #expect(added.value == [details.core])
    }

    @Test
    func toggleFavoriteRemovesBookFromShelf() async {
        let removedIDs = LockIsolated<[Book.ID]>([])
        let store = makeStore(loaded(isFavorite: true)) {
            $0.favoritesClient.remove = { id in removedIDs.withValue { $0.append(id) } }
        }

        await store.send(.toggleFavoriteTapped) {
            $0.isFavorite = false
        }
        #expect(removedIDs.value == [details.core.id])
    }

    @Test
    func toggleFavoriteKeepsStateWhenSavingFails() async {
        let store = makeStore(loaded(isFavorite: false)) {
            $0.favoritesClient.add = { _ in throw TestError.someError }
        }

        await store.send(.toggleFavoriteTapped)
    }

    @Test
    func toggleFavoriteDoesNothingBeforeDetailsLoad() async {
        // Any favoritesClient call would fail this test: none is configured.
        let store = makeStore(BookDetails.State(bookId: details.core.id))

        await store.send(.toggleFavoriteTapped)
    }

    // MARK: - Helpers

    private func loaded(isFavorite: Bool) -> BookDetails.State {
        BookDetails.State(bookId: details.core.id, bookDetails: .loaded(details), isFavorite: isFavorite)
    }

    /// Unconfigured client endpoints fail the test if they're called.
    private func makeStore(
        _ state: BookDetails.State,
        dependencies: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStoreOf<BookDetails> {
        TestStore(initialState: state) {
            BookDetails()
        } withDependencies: {
            dependencies(&$0)
        }
    }
}
