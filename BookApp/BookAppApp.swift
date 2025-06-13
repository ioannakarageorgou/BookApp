import SwiftUI
import ComposableArchitecture
import NetworkClient

@main
struct BookAppApp: App {
    let networkClient = makeLiveNetworkClient(apiKey: Secrets.googleBooksAPIKey)
    let booksRepository: BooksRepository

    init() {
        self.booksRepository = BooksRepository(networkClient: networkClient)
    }

    var body: some Scene {
        WindowGroup {
            BookListView(
                store: Store(initialState: BookList.State()) {
                    BookList(booksRepository: booksRepository)
                }
            )
        }
    }
}
