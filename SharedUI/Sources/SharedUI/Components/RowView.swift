import SwiftUI

public struct RowView: View {
    public let title: String
    public let subtitle: String?
    public let thumbnailURL: URL?
    public let onTap: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        thumbnailURL: URL? = nil,
        onTap: @escaping () -> Void = {}
    ) {
        self.title = title
        self.subtitle = subtitle
        self.thumbnailURL = thumbnailURL
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: AppLayout.Spacing.medium) {
                thumbnailView
                contentView
                Spacer()
            }
            .padding(.vertical, AppLayout.Spacing.small)
            .padding(.horizontal, AppLayout.Spacing.medium)
            .background(Theme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.CornerRadius.medium))
        }
        .buttonStyle(.plain)
    }
}

private extension RowView {
    @ViewBuilder
    var thumbnailView: some View {
        if let url = thumbnailURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.accent))
                        .frame(width: AppLayout.ImageSize.width, height: AppLayout.ImageSize.height)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: AppLayout.ImageSize.width, height: AppLayout.ImageSize.height)
                        .clipped()
                        .cornerRadius(AppLayout.CornerRadius.small)
                default:
                    placeholderImage
                }
            }
        } else {
            placeholderImage
        }
    }

    @ViewBuilder
    var contentView: some View {
        VStack(alignment: .leading, spacing: AppLayout.Spacing.tiny) {
            Text(title)
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .lineLimit(2)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    var placeholderImage: some View {
        Image(systemName: "book.closed.fill")
            .resizable()
            .scaledToFit()
            .frame(width: AppLayout.ImageSize.width, height: AppLayout.ImageSize.height)
            .foregroundColor(Theme.accent.opacity(Theme.accentOpacityLow))
            .background(Theme.backgroundSecondary)
            .cornerRadius(AppLayout.CornerRadius.small)
    }
}


#Preview("Loading/Loaded Image") {
    RowView(
        title: "SwiftUI Essentials",
        subtitle: "John Appleseed",
        thumbnailURL: URL(
            string: "https://picsum.photos/50/75"
        )
    )
}

#Preview("Failed Image/No Image URL") {
    RowView(
        title: "Failed to load",
        subtitle: nil,
        thumbnailURL: URL(
            string: "https://invalid.url"
        )
    )
}
