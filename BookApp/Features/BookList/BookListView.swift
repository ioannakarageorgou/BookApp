import SwiftUI
import ComposableArchitecture
import SharedUI

struct BookListView: View {
    let store: StoreOf<BookList>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    Theme.background.ignoresSafeArea()

                    switch viewStore.books {
                    case .idle, .loading:
                        LoadingView(message: "Loading books...")

                    case .error(let message):
                        ErrorView(message: message) {
                            store.send(.fetchBooks())
                        }

                    case .loaded(let books):
                        contentView(books: books, viewStore: viewStore)
                    }
                }
                .onAppear {
                    // Only fetch if idle or error
                    if case .idle = viewStore.books {
                        store.send(.fetchBooks())
                    }
                    store.send(.loadFavorites)
                }
                .navigationBarHidden(true)
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

// MARK: - Content View (Loaded State)
private extension BookListView {
    @ViewBuilder
    func contentView(books: [Book], viewStore: ViewStoreOf<BookList>) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                searchBar(viewStore: viewStore)
                categoryTabs
                favoritesSection
                booksSection(books: books, viewStore: viewStore)
            }
            .padding(.top, AppLayout.Spacing.medium)
        }
    }
}

// MARK: - Header Section
private extension BookListView {
    @ViewBuilder
    var header: some View {
        HStack {
            Text("Library")
                .font(.system(size: AppLayout.FontSize.largeTitle, weight: .bold, design: .serif))
                .foregroundColor(Theme.textPrimary)

            Spacer()

            profileButton
        }
        .padding(.horizontal, AppLayout.Spacing.medium)
        .padding(.bottom, AppLayout.Spacing.small)
    }

    @ViewBuilder
    var profileButton: some View {
        Button(action: {
            // TODO: Add profile action
        }) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Theme.accent, Theme.accentSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: AppLayout.ImageSize.avatarSmall, height: AppLayout.ImageSize.avatarSmall)
                .overlay(
                    Text("JD")
                        .font(.system(size: AppLayout.FontSize.footnote + 1, weight: .semibold)) // 14pt
                        .foregroundColor(.white)
                )
                .cardShadowMedium()
        }
    }
}

// MARK: - Search & Categories
private extension BookListView {
    @ViewBuilder
    func searchBar(viewStore: ViewStoreOf<BookList>) -> some View {
        SearchBar(
            text: viewStore.binding(
                get: \.searchQuery,
                send: BookList.Action.searchQueryChanged
            ),
            placeholder: "Search books, authors...",
            onSubmit: {
                store.send(.fetchBooks())
            }
        )
        .padding(.horizontal, AppLayout.Spacing.medium)
        .padding(.bottom, AppLayout.Spacing.large)
    }

    @ViewBuilder
    var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppLayout.Spacing.small) {
                CategoryTab(title: "All", isSelected: true) {
                    // TODO: Handle category selection
                }
                CategoryTab(title: "Popular", isSelected: false) {}
                CategoryTab(title: "Fiction", isSelected: false) {}
                CategoryTab(title: "Non-Fiction", isSelected: false) {}
                CategoryTab(title: "Mystery", isSelected: false) {}
            }
            .padding(.horizontal, AppLayout.Spacing.medium)
        }
        .padding(.bottom, AppLayout.Spacing.extraLarge)
    }
}

// MARK: - Favorites Section
private extension BookListView {
    @ViewBuilder
    var favoritesSection: some View {
        WithPerceptionTracking {
            if case let .loaded(favorites) = store.favoriteBooks, !favorites.isEmpty {
                VStack(alignment: .leading, spacing: AppLayout.Spacing.medium) {
                    SectionHeader(
                        title: "Your Shelf",
                        icon: "heart.fill",
                        showSeeAll: true,
                        onSeeAllTap: {
                            // TODO: Navigate to all favorites
                        }
                    )
                    .padding(.horizontal, AppLayout.Spacing.medium)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppLayout.Spacing.medium) {
                            ForEach(favorites, id: \.id) { book in
                                FavoriteBookCard(
                                    title: book.title,
                                    subtitle: book.subtitle,
                                    thumbnailURL: book.thumbnailURL,
                                    onTap: { store.send(.bookTapped(book)) }
                                )
                            }
                        }
                        .padding(.horizontal, AppLayout.Spacing.medium)
                    }
                }
                .padding(.vertical, AppLayout.Spacing.large)
                .background(favoritesSectionBackground)
                .padding(.horizontal, AppLayout.Spacing.medium)
                .padding(.bottom, AppLayout.Spacing.extraLarge)
            }
        }
    }

    @ViewBuilder
    var favoritesSectionBackground: some View {
        RoundedRectangle(cornerRadius: AppLayout.CornerRadius.extraLarge)
            .fill(
                LinearGradient(
                    colors: [
                        Theme.accentLight.opacity(0.3),
                        Theme.accentLight.opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.CornerRadius.extraLarge)
                    .strokeBorder(Theme.accent.opacity(0.15), lineWidth: 1)
            )
    }
}

// MARK: - Books Grid Section
private extension BookListView {
    @ViewBuilder
    func booksSection(books: [Book], viewStore: ViewStoreOf<BookList>) -> some View {
        VStack(alignment: .leading, spacing: AppLayout.Spacing.medium) {
            SectionHeader(title: "Discover")
            .padding(.horizontal, AppLayout.Spacing.medium)

            if books.isEmpty {
                EmptyPlaceholderView(
                    title: "No books found",
                    message: "Try a different search query or check back later.",
                    icon: "book.closed"
                )
            } else {
                booksGrid(books: books, viewStore: viewStore)
            }
        }
    }

    @ViewBuilder
    func booksGrid(books: [Book], viewStore: ViewStoreOf<BookList>) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: AppLayout.Grid.booksSpacing),
                GridItem(.flexible(), spacing: AppLayout.Grid.booksSpacing)
            ],
            spacing: AppLayout.Grid.booksSpacing
        ) {
            ForEach(Array(books.enumerated()), id: \.1.id) { index, book in
                BookCard(
                    title: book.title,
                    subtitle: book.subtitle,
                    thumbnailURL: book.thumbnailURL,
                    onTap: { store.send(.bookTapped(book)) }
                )
                .onAppear {
                    handlePagination(index: index, totalBooks: books.count, viewStore: viewStore)
                }
            }
        }
        .padding(.horizontal, AppLayout.Spacing.medium)
        .padding(.bottom, AppLayout.Spacing.extraLarge)

        if viewStore.isLoadingNextPage {
            paginationLoader
        }
    }

    @ViewBuilder
    var paginationLoader: some View {
        HStack {
            Spacer()
            ProgressView()
                .tint(Theme.accent)
            Spacer()
        }
        .padding(.vertical, AppLayout.Spacing.large)
    }

    func handlePagination(index: Int, totalBooks: Int, viewStore: ViewStoreOf<BookList>) {
        if index >= totalBooks - 5 && viewStore.hasMorePages && !viewStore.isLoadingNextPage {
            store.send(.fetchNextPage)
        }
    }
}
