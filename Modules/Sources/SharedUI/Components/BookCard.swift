import SwiftUI

/// A book card for grid display with cover, title, and subtitle
package struct BookCard: View {
    let title: String
    let subtitle: String?
    let thumbnailURL: URL?
    let onTap: () -> Void

    package init(
        title: String,
        subtitle: String?,
        thumbnailURL: URL?,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.thumbnailURL = thumbnailURL
        self.onTap = onTap
    }

    package var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppLayout.Spacing.small) {
                // Cover image
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .empty:
                        placeholderCover
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(2/3, contentMode: .fill)
                    case .failure:
                        placeholderCover
                    @unknown default:
                        placeholderCover
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(2/3, contentMode: .fit)
                .cornerRadius(AppLayout.CornerRadius.medium)
                .cardShadowMedium()

                // Title
                Text(title)
                    .font(.system(size: AppLayout.FontSize.footnote, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Subtitle/Author
                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: AppLayout.FontSize.caption, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var placeholderCover: some View {
        RoundedRectangle(cornerRadius: AppLayout.CornerRadius.medium)
            .fill(
                LinearGradient(
                    colors: [Theme.accent.opacity(0.3), Theme.accentSecondary.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Image(systemName: "book.closed.fill")
                    .font(.system(size: AppLayout.FontSize.title, weight: .light))
                    .foregroundColor(Theme.accent.opacity(0.5))
            )
            .aspectRatio(2/3, contentMode: .fit)
    }
}

#Preview {
    LazyVGrid(
        columns: [
            GridItem(.flexible(), spacing: AppLayout.Grid.booksSpacing),
            GridItem(.flexible(), spacing: AppLayout.Grid.booksSpacing)
        ],
        spacing: AppLayout.Grid.booksSpacing
    ) {
        BookCard(
            title: "The Psychology of Money",
            subtitle: "Morgan Housel",
            thumbnailURL: nil,
            onTap: {}
        )

        BookCard(
            title: "Sapiens",
            subtitle: "Yuval Noah Harari",
            thumbnailURL: nil,
            onTap: {}
        )
    }
    .padding()
    .background(Theme.background)
}
