import SwiftUI
import ComposableArchitecture

@main
struct BookAppApp: App {
    var body: some Scene {
        WindowGroup {
            BookListView(
                store: Store(initialState: BookList.State()) {
                    BookList()
                }
            )
        }
    }
}
