import XCTest
import ComposableArchitecture
@testable import BookApp

final class BookDetailsTests: XCTestCase {
    @MainActor
    func testFetchDetails_success() async {
        let book = Book.fixture()
        let details = Details.fixture(core: book)

        let store = makeTestStore(
            state: .init(bookId: book.id)
        ) { repo in
            repo.fetchBookDetailsResult = .success(details)
            repo.isFavoriteResult = true
        }

        await store.send(.fetchDetails) {
            $0.bookDetails = .loading
        }
        await store.receive(\.bookDetailsResponse) {
            $0.bookDetails = .loaded(details)
            $0.isFavorite = true
        }
    }

    @MainActor
    func testFetchDetails_failure() async {
        let store = makeTestStore(
            state: .init(bookId: "bad")
        ) { repo in
            repo.fetchBookDetailsResult = .failure(TestError.someError)
        }

        await store.send(.fetchDetails) {
            $0.bookDetails = .loading
        }
        await store.receive(\.bookDetailsResponse) {
            $0.bookDetails = .error(TestError.someError.localizedDescription)
        }
    }

    @MainActor
    func testToggleFavorite_whenNotFavorite() async {
        let book = Book.fixture()
        let details = Details.fixture(core: book)

        let store = makeTestStore(
            state: .init(
                bookId: book.id,
                bookDetails: .loaded(details),
                isFavorite: false
            )
        ) { repo in
            repo.addToFavoritesResult = .success(())
        }

        await store.send(.toggleFavoriteTapped) {
            $0.isFavorite = true
        }
    }

    @MainActor
    func testToggleFavorite_removes_whenAlreadyFavorite() async {
        let book = Book.fixture()
        let details = Details.fixture(core: book)

        let store = makeTestStore(
            state: .init(
                bookId: book.id,
                bookDetails: .loaded(details),
                isFavorite: true
            )
        ) { repo in
            repo.removeFromFavoritesResult = .success(())
        }

        await store.send(.toggleFavoriteTapped) {
            $0.isFavorite = false
        }
    }

    private func makeTestStore(
        state: BookDetails.State,
        mockRepositorySetup: ((MockBooksRepository) -> Void)? = nil
    ) -> TestStore<BookDetails.State, BookDetails.Action> {
        let mockRepository = MockBooksRepository()
        mockRepositorySetup?(mockRepository)

        return TestStore(
            initialState: state,
            reducer: { BookDetails() }
        ) {
            $0.booksRepository = mockRepository
        }
    }
}
