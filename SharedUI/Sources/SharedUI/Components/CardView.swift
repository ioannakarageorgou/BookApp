import SwiftUI

public struct CardView: View {
    public let title: String
    public let thumbnailURL: URL?
    public let onTap: () -> Void

    public init(
        title: String,
        thumbnailURL: URL? = nil,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppLayout.Spacing.small) {
                AsyncImage(url: thumbnailURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: AppLayout.ImageSize.width,
                            height: AppLayout.ImageSize.height
                        )
                        .clipped()
                        .cornerRadius(AppLayout.CornerRadius.medium)
                } placeholder: {
                    RoundedRectangle(cornerRadius: AppLayout.CornerRadius.medium)
                        .fill(Theme.backgroundSecondary)
                        .frame(
                            width: AppLayout.ImageSize.width,
                            height: AppLayout.ImageSize.height
                        )
                }

                Text(title)
                    .font(.caption2)
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(
                        width: AppLayout.ImageSize.width,
                        alignment: .center
                    )
            }
            .padding(AppLayout.Spacing.small)
            .background(Theme.backgroundSecondary)
            .cornerRadius(AppLayout.CornerRadius.medium)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Loading/Loaded Image") {
    CardView(
        title: "SwiftUI Essentials",
        thumbnailURL: URL(
            string: "https://picsum.photos/50/75"
        ),
        onTap: {}
    )
}

#Preview("Failed Image/No Image URL") {
    CardView(
        title: "Failed to load",
        thumbnailURL: URL(
            string: "https://invalid.url"
        ),
        onTap: {}
    )
}
