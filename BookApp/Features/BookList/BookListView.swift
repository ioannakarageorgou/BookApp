import SwiftUI
import ComposableArchitecture
import SharedUI

struct BookListView: View {
    let store: StoreOf<BookList>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                TextField(
                    "Search books...",
                    text: viewStore.binding(
                        get: \.searchQuery,
                        send: BookList.Action.searchQueryChanged
                    )
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .submitLabel(.search)
                .onSubmit { store.send(.fetchBooks) }

                Group {
                    switch viewStore.books {
                    case .idle, .loading:
                        LoadingView(message: "Loading books...")

                    case .error(let message):
                        ErrorView(message: message) { store.send(.fetchBooks) }

                    case .loaded(let books) where books.isEmpty:
                        EmptyPlaceholderView(
                            title: "No books found",
                            message: "Try a different search query or check back later.",
                            icon: "book"
                        )

                    case .loaded(let books):
                        LoadedBooksView(books: books)
                    }
                }
            }
            .onAppear { store.send(.fetchBooks) }
        }
    }
}
