import ComposableArchitecture
import Testing
@testable import BookApp

@MainActor
@Suite
struct BookDetailsTests {
    let repository = MockBooksRepository()
    let details = Details.fixture()

    @Test
    func fetchDetailsLoadsDetailsAndFavoriteState() async {
        repository.fetchBookDetailsResult = .success(details)
        repository.isFavoriteResult = true
        let store = makeStore(BookDetails.State(bookId: details.core.id))

        await store.send(.fetchDetails) {
            $0.bookDetails = .loading
        }
        await store.receive(\.bookDetailsResponse) {
            $0.bookDetails = .loaded(self.details)
            $0.isFavorite = true
        }
        #expect(repository.fetchBookDetailsCalls.value == [details.core.id])
    }

    @Test
    func fetchDetailsFailureShowsError() async {
        repository.fetchBookDetailsResult = .failure(TestError.someError)
        let store = makeStore(BookDetails.State(bookId: "bad"))

        await store.send(.fetchDetails) {
            $0.bookDetails = .loading
        }
        await store.receive(\.bookDetailsResponse) {
            $0.bookDetails = .error(TestError.someError.localizedDescription)
        }
    }

    @Test
    func toggleFavoriteAddsBookToShelf() async {
        repository.addToFavoritesResult = .success(())
        let store = makeStore(loaded(isFavorite: false))

        await store.send(.toggleFavoriteTapped) {
            $0.isFavorite = true
        }
        #expect(repository.addedToFavorites.value == [details.core])
    }

    @Test
    func toggleFavoriteRemovesBookFromShelf() async {
        repository.removeFromFavoritesResult = .success(())
        let store = makeStore(loaded(isFavorite: true))

        await store.send(.toggleFavoriteTapped) {
            $0.isFavorite = false
        }
        #expect(repository.removedFromFavorites.value == [details.core])
    }

    @Test
    func toggleFavoriteKeepsStateWhenSavingFails() async {
        repository.addToFavoritesResult = .failure(TestError.someError)
        let store = makeStore(loaded(isFavorite: false))

        await store.send(.toggleFavoriteTapped)
    }

    @Test
    func toggleFavoriteDoesNothingBeforeDetailsLoad() async {
        let store = makeStore(BookDetails.State(bookId: details.core.id))

        await store.send(.toggleFavoriteTapped)
        #expect(repository.addedToFavorites.value.isEmpty)
    }

    // MARK: - Helpers

    private func loaded(isFavorite: Bool) -> BookDetails.State {
        BookDetails.State(bookId: details.core.id, bookDetails: .loaded(details), isFavorite: isFavorite)
    }

    private func makeStore(_ state: BookDetails.State) -> TestStoreOf<BookDetails> {
        TestStore(initialState: state) {
            BookDetails()
        } withDependencies: { [repository] in
            $0.booksRepository = repository
        }
    }
}
