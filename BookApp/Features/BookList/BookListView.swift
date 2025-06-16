import SwiftUI
import ComposableArchitecture

struct BookListView: View {
    let store: StoreOf<BookList>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                switch viewStore.books {
                case .idle, .loading:
                    LoadingView(message: "Loading books...")

                case .error(let message):
                    ErrorView(message: message) { store.send(.fetchBooks) }

                case .loaded(let books):
                    ErrorView() { store.send(.fetchBooks) }
//                    loadedView(with: books)
                }
            }
        }
        .onAppear { store.send(.fetchBooks) }
    }

    private func loadedView(with books: [Book]) -> some SwiftUI.View {
//        if books.isEmpty {
//            Text("No books found.")
//                .foregroundColor(.secondary)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//        } else {
            List(books) { book in
                Text(book.title)
            }
//        }
    }
}
