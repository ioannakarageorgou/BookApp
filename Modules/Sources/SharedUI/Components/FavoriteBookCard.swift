import SwiftUI

/// A larger book card with heart badge for favorites section
public struct FavoriteBookCard: View {
    let title: String
    let subtitle: String?
    let thumbnailURL: URL?
    let onTap: () -> Void

    public init(
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

    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppLayout.Spacing.small) {
                // Cover with heart badge
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .empty:
                            placeholderCover
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            placeholderCover
                        @unknown default:
                            placeholderCover
                        }
                    }
                    .frame(
                        width: AppLayout.ImageSize.coverMediumWidth,
                        height: AppLayout.ImageSize.coverMediumHeight
                    )
                    .cornerRadius(AppLayout.CornerRadius.medium)
                    .cardShadowLarge()

                    // Heart badge
                    Circle()
                        .fill(Theme.accent.opacity(0.95))
                        .frame(width: AppLayout.ImageSize.iconLarge, height: AppLayout.ImageSize.iconLarge)
                        .overlay(
                            Image(systemName: "heart.fill")
                                .font(.system(size: AppLayout.FontSize.caption, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Theme.accent.opacity(0.4), radius: AppLayout.Spacing.small, x: 0, y: 2)
                        .offset(x: -AppLayout.Spacing.small, y: AppLayout.Spacing.small)
                }

                // Title and subtitle
                VStack(alignment: .leading, spacing: AppLayout.Spacing.tiny) {
                    Text(title)
                        .font(.system(size: AppLayout.FontSize.footnote, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if let subtitle = subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: AppLayout.FontSize.caption, weight: .medium))
                            .foregroundColor(Theme.textSecondary)
                            .lineLimit(1)
                    }
                }
                .frame(width: AppLayout.ImageSize.coverMediumWidth)
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
                    .font(.system(size: AppLayout.ImageSize.iconLarge, weight: .light))
                    .foregroundColor(Theme.accent.opacity(0.5))
            )
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: AppLayout.Spacing.medium) {
            FavoriteBookCard(
                title: "The Psychology of Money",
                subtitle: "Morgan Housel",
                thumbnailURL: nil,
                onTap: {}
            )

            FavoriteBookCard(
                title: "Atomic Habits",
                subtitle: "James Clear",
                thumbnailURL: nil,
                onTap: {}
            )

            FavoriteBookCard(
                title: "Sapiens",
                subtitle: "Yuval Noah Harari",
                thumbnailURL: nil,
                onTap: {}
            )
        }
        .padding()
    }
    .background(Theme.background)
}
