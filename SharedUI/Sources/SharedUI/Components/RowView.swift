import SwiftUI

public struct RowView: View {
    public let title: String
    public let subtitle: String?
    public let thumbnailURL: URL?

    public init(
        title: String,
        subtitle: String? = nil,
        thumbnailURL: URL? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.thumbnailURL = thumbnailURL
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let url = thumbnailURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.accent))
                            .frame(width: 50, height: 75)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 75)
                            .clipped()
                            .cornerRadius(6)
                    case .failure(_):
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }

            VStack(alignment: .leading, spacing: 4) {
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

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Theme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private var placeholderImage: some View {
        Image(systemName: "book.closed.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 75)
            .foregroundColor(Theme.accent.opacity(0.3))
            .background(Theme.backgroundSecondary)
            .cornerRadius(6)
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
