import SwiftUI

public struct BookRowView: View {
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
                    .lineLimit(2)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle ?? "No subtitle")")
    }
    
    @ViewBuilder
    private var placeholderImage: some View {
        Image(systemName: "book.closed.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 75)
            .foregroundColor(.gray.opacity(0.5))
            .cornerRadius(6)
    }
}


#Preview("Loading/Loaded Image") {
    BookRowView(title: "SwiftUI Essentials", subtitle: "John Appleseed", thumbnailURL: URL(string: "https://picsum.photos/50/75"))
}

#Preview("Failed Image/No Image URL") {
    BookRowView(title: "Failed to load", subtitle: nil, thumbnailURL: URL(string: "https://invalid.url"))
}
