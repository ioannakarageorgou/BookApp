import ComposableArchitecture
import Models
import SharedUI
import SwiftUI

package struct BookDetailsView: View {
    let store: StoreOf<BookDetails>

    package init(store: StoreOf<BookDetails>) {
        self.store = store
    }

    package var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: AppLayout.Spacing.medium) {
                switch store.bookDetails {
                case .idle, .loading:
                    LoadingView(message: "Loading book details...")

                case .error(let message):
                    ErrorView(message: message) {
                        store.send(.fetchDetails)
                    }

                case .loaded(let details):
                    content(details)
                }
            }
            .onAppear { store.send(.fetchDetails) }
            .navigationTitle("Book Details")
            .background(Theme.background.ignoresSafeArea())
        }
    }
}

private extension BookDetailsView {
    @ViewBuilder
    func content(_ details: Details) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.Spacing.large) {
                header(details)
                Divider().background(Theme.accent.opacity(0.3))
                description(details.description)
                Spacer(minLength: AppLayout.Spacing.large)
            }
            .padding(AppLayout.Spacing.medium)
        }
    }

    @ViewBuilder
    func header(_ details: Details) -> some View {
        HStack(alignment: .top, spacing: AppLayout.Spacing.medium) {
            coverImage(details.core.thumbnailURL)
            VStack(alignment: .leading, spacing: AppLayout.Spacing.medium) {
                titleAndSubtitle(title: details.core.title, subtitle: details.core.subtitle)
                favoriteButton.padding(.top, AppLayout.Spacing.tiny)
            }
        }
    }

    @ViewBuilder
    var favoriteButton: some View {
        WithPerceptionTracking {
            Button(action: {
                store.send(.toggleFavoriteTapped)
            }) {
                Label(
                    store.isFavorite ? "Remove from shelf" : "Add to shelf",
                    systemImage: store.isFavorite ? "heart.fill" : "heart"
                )
                .labelStyle(.titleAndIcon)
                .lineLimit(1)
                .padding(.horizontal)
                .padding(.vertical, AppLayout.Spacing.small)
                .background(
                    Capsule()
                        .fill(store.isFavorite ? Theme.backgroundDestructive : Theme.backgroundAccent)
                )
                .foregroundColor(store.isFavorite ? Theme.textDestructive : Theme.accent)
            }
            .buttonStyle(.plain)
            .disabled(store.isUpdatingFavorite)
        }
    }

    @ViewBuilder
    func coverImage(_ url: URL?) -> some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.accent))
                        .scaleEffect(AppLayout.Scale.progressView)
                        .frame(width: AppLayout.ImageSize.coverMediumWidth, height: AppLayout.ImageSize.coverMediumHeight)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: AppLayout.ImageSize.coverMediumWidth, height: AppLayout.ImageSize.coverMediumHeight)
                        .cornerRadius(AppLayout.CornerRadius.medium)
                default:
                    placeholderImage
                        .frame(width: AppLayout.ImageSize.coverMediumWidth, height: AppLayout.ImageSize.coverMediumHeight)
                }
            }
        } else {
            placeholderImage
                .frame(width: AppLayout.ImageSize.coverMediumWidth, height: AppLayout.ImageSize.coverMediumHeight)
        }
    }

    @ViewBuilder
    func titleAndSubtitle(title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: AppLayout.Spacing.small) {
            Text(title)
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func description(_ text: String?) -> some View {
        if let text, !text.isEmpty {
            Text(text)
                .font(.body)
                .foregroundColor(Theme.textPrimary)
                .lineSpacing(AppLayout.Spacing.tiny)
        } else {
            Text("No description available.")
                .font(.body)
                .italic()
                .foregroundColor(Theme.textSecondary)
        }
    }

    @ViewBuilder
    var placeholderImage: some View {
        Image(systemName: "book.closed.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(Theme.accent.opacity(Theme.accentOpacityLow))
            .background(Theme.backgroundSecondary)
            .cornerRadius(AppLayout.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.1), radius: AppLayout.CornerRadius.small, x: 0, y: 2)
    }
}

// Previews use the clients' preview values: fixture books and an in-memory shelf.
#Preview {
    NavigationStack {
        BookDetailsView(
            store: Store(initialState: BookDetails.State(bookId: "1")) {
                BookDetails()
            }
        )
    }
}
