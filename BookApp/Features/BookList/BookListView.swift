import ComposableArchitecture
import Models
import SharedUI
import SwiftUI

struct BookListView: View {
    @Bindable var store: StoreOf<BookList>

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                switch store.books {
                case .idle, .loading:
                    LoadingView(message: "Loading books...")

                case .error(let message):
                    ErrorView(message: message) {
                        store.send(.fetchBooks())
                    }

                case .loaded(let books):
                    contentView(books: books)
                }
            }
            .onAppear {
                if case .idle = store.books {
                    store.send(.fetchBooks())
                }
                store.send(.loadFavorites)
            }
            .sheet(
                item: $store.scope(state: \.bookDetails, action: \.bookDetails)
            ) { detailStore in
                BookDetailsView(store: detailStore)
            }
        }
    }
}

// MARK: - Content View (Loaded State)
private extension BookListView {
    @ViewBuilder
    func contentView(books: [Book]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                searchBar
                categoryTabs
                favoritesSection
                booksSection(books: books)
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
                        .font(.system(size: AppLayout.FontSize.footnote, weight: .semibold))
                        .foregroundColor(.white)
                )
                .cardShadowMedium()
        }
    }
}

// MARK: - Search & Categories
private extension BookListView {
    @ViewBuilder
    var searchBar: some View {
        SearchBar(
            text: $store.searchQuery,
            placeholder: "Search books, authors...",
            onSubmit: {
                store.send(.searchSubmitted)
            }
        )
        .padding(.horizontal, AppLayout.Spacing.medium)
        .padding(.bottom, AppLayout.Spacing.large)
    }

    @ViewBuilder
    var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppLayout.Spacing.small) {
                ForEach(BookList.State.Category.allCases, id: \.self) { category in
                    CategoryTab(
                        title: category.rawValue,
                        isSelected: store.selectedCategory == category
                    ) {
                        store.send(.categorySelected(category))
                    }
                }
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
    func booksSection(books: [Book]) -> some View {
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
                booksGrid(books: books)
            }
        }
    }

    @ViewBuilder
    func booksGrid(books: [Book]) -> some View {
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
                    handlePagination(index: index, totalBooks: books.count)
                }
            }
        }
        .padding(.horizontal, AppLayout.Spacing.medium)
        .padding(.bottom, AppLayout.Spacing.extraLarge)

        if store.isLoadingNextPage {
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

    func handlePagination(index: Int, totalBooks: Int) {
        if index >= totalBooks - 5 && store.hasMorePages && !store.isLoadingNextPage {
            store.send(.fetchNextPage)
        }
    }
}
