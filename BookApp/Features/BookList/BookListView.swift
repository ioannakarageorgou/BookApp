import SwiftUI
import ComposableArchitecture
import SharedUI

struct BookListView: View {
    let store: StoreOf<BookList>

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: AppLayout.Spacing.large) {
                title()
                searchBar()
                booksList()
            }
            .padding(.top, AppLayout.Spacing.large)
            .background(Theme.background.ignoresSafeArea())
            .onAppear { store.send(.fetchBooks) }
        }
    }

    @ViewBuilder
    private func title() -> some View {
        Text("My Books App")
            .font(.largeTitle.bold())
            .foregroundColor(Theme.textPrimary)
            .padding(.horizontal)
    }

    @ViewBuilder
    private func searchBar() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
        }
    }

    @ViewBuilder
    private func booksList() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
    }
}
