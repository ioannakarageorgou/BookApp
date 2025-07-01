import SwiftUI
import ComposableArchitecture
import SharedUI

struct BookListView: View {
    let store: StoreOf<BookList>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack(alignment: .leading, spacing: AppLayout.Spacing.large) {
                    appTitle
                    searchBar
                    booksList
                }
                .padding(.top, AppLayout.Spacing.large)
                .background(Theme.background.ignoresSafeArea())
                .onAppear { store.send(.fetchBooks()) }
                .navigationDestination(
                    item: viewStore.binding(
                        get: \.bookDetails,
                        send: { _ in .dismissBookDetails }
                    )
                ) { _ in
                    IfLetStore(store.scope(state: \.bookDetails, action: \.bookDetails)) {
                        BookDetailsView(store: $0)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var appTitle: some View {
        Text("My Books App")
            .font(.largeTitle.bold())
            .foregroundColor(Theme.textPrimary)
            .padding(.horizontal)
    }

    @ViewBuilder
    private var searchBar: some View {
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
            .onSubmit { store.send(.fetchBooks()) }
        }
    }

    @ViewBuilder
    private var booksList: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                switch viewStore.books {
                case .idle, .loading:
                    LoadingView(message: "Loading books...")

                case .error(let message):
                    ErrorView(message: message) { store.send(.fetchBooks()) }

                case .loaded(let books) where books.isEmpty:
                    EmptyPlaceholderView(
                        title: "No books found",
                        message: "Try a different search query or check back later.",
                        icon: "book"
                    )

                case .loaded(let books):
                    loadedBooksView(for: books)
                }
            }
        }
    }
}

private extension BookListView {
    @ViewBuilder
    func loadedBooksView(for books: [Book]) -> some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: AppLayout.Spacing.medium) {
                    loadedBooksTitle
                    booksListView(for: books)
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Theme.background.ignoresSafeArea())
        }
    }

    @ViewBuilder
    var loadedBooksTitle: some View {
        Text("Books")
            .font(.title2)
            .bold()
            .foregroundColor(Theme.textPrimary)
            .padding(.horizontal)
    }

    @ViewBuilder
    func booksListView(for books: [Book]) -> some View {
        LazyVStack(spacing: AppLayout.Spacing.small) {
            booksForEach(books)
            loadMoreButton
        }
    }

    @ViewBuilder
    func booksForEach(_ books: [Book]) -> some View {
        WithPerceptionTracking {
            ForEach(books, id: \.id) { book in
                RowView(
                    title: book.title,
                    subtitle: book.subtitle,
                    thumbnailURL: book.thumbnailURL,
                    onTap: { store.send(.bookTapped(book)) }
                )
            }
        }
    }

    @ViewBuilder
    var loadMoreButton: some View {
        WithPerceptionTracking {
            if store.hasMorePages {
                Button {
                    store.send(.fetchNextPage)
                } label: {
                    if store.isLoadingNextPage {
                        ProgressView().padding()
                    } else {
                        Text("Load More").foregroundColor(Theme.accent).padding()
                    }
                }
            }
        }
    }
}
