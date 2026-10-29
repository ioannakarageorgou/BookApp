import SwiftUI
import ComposableArchitecture

@main
struct BookAppApp: App {
    var body: some Scene {
        WindowGroup {
            // Unit tests run inside the app; skip the real UI so it never hits the live API.
            if !isTesting {
                BookListView(
                    store: Store(initialState: BookList.State()) {
                        BookList()
                    }
                )
            }
        }
    }
}
