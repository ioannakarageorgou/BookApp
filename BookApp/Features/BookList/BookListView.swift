import SwiftUI
import ComposableArchitecture
import SharedUI

struct BookListView: View {
    let store: StoreOf<BookList>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack(alignment: .leading, spacing: AppLayout.Spacing.medium) {
                    appTitle
                    favoritesSection
                    booksSection
                }
                .padding(.top, AppLayout.Spacing.large)
                .background(Theme.background.ignoresSafeArea())
                .onAppear {
                    store.send(.fetchBooks())
                    store.send(.loadFavorites)
                }
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
}

private extension BookListView {
    @ViewBuilder
    var appTitle: some View {
        Text("My Books App")
            .font(.largeTitle.bold())
            .foregroundColor(Theme.textPrimary)
            .padding(.horizontal)
    }

    @ViewBuilder
    var booksSection: some View {
        VStack(alignment: .leading, spacing: AppLayout.Spacing.medium) {
            loadedBooksTitle
            searchBar
            booksList
        }
        .padding(AppLayout.Spacing.small)
        .cornerRadius(AppLayout.CornerRadius.large)
        .padding(.horizontal)
    }

    @ViewBuilder
    var searchBar: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            TextField(
                "Search books...",
                text: viewStore.binding(
                    get: \.searchQuery,
                    send: BookList.Action.searchQueryChanged
                )
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .submitLabel(.search)
            .onSubmit { store.send(.fetchBooks()) }
        }
    }
}

private extension BookListView {
    @ViewBuilder
    var booksList: some View {
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

    @ViewBuilder
    func loadedBooksView(for books: [Book]) -> some View {
        WithPerceptionTracking {
            ScrollView {
                booksListView(for: books)
            }
            .background(Theme.background.ignoresSafeArea())
        }
    }

    @ViewBuilder
    var loadedBooksTitle: some View {
        Text("Books")
            .font(.title3.bold())
            .foregroundColor(Theme.textPrimary)
    }

    @ViewBuilder
    func booksListView(for books: [Book]) -> some View {
        WithPerceptionTracking {
            LazyVStack(spacing: AppLayout.Spacing.small) {
                booksForEach(books)
                if store.isLoadingNextPage {
                    ProgressView()
                        .padding()
                }
            }
        }
    }

    @ViewBuilder
    func booksForEach(_ books: [Book]) -> some View {
        WithPerceptionTracking {
            ForEach(Array(books.enumerated()), id: \.1.id) { index, book in
                RowView(
                    title: book.title,
                    subtitle: book.subtitle,
                    thumbnailURL: book.thumbnailURL,
                    onTap: { store.send(.bookTapped(book)) }
                )
                .onAppear {
                    if index >= books.count - 5 && store.hasMorePages && !store.isLoadingNextPage {
                        store.send(.fetchNextPage)
                    }
                }
            }
        }
    }
}

private extension BookListView {
    @ViewBuilder
    var favoritesSection: some View {
        WithPerceptionTracking {
            if case let .loaded(favorites) = store.favoriteBooks, !favorites.isEmpty {
                VStack(alignment: .leading, spacing: AppLayout.Spacing.medium) {
                    Text("Favorites shelf")
                        .font(.title3.bold())
                        .foregroundColor(Theme.textPrimary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppLayout.Spacing.medium) {
                            ForEach(favorites, id: \.id) { book in
                                CardView(
                                    title: book.title,
                                    thumbnailURL: book.thumbnailURL
                                ) {
                                    store.send(.bookTapped(book))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(AppLayout.Spacing.small)
                .background(Theme.backgroundSecondary)
                .cornerRadius(AppLayout.CornerRadius.large)
                .padding(.horizontal)
            }
        }
    }
}
