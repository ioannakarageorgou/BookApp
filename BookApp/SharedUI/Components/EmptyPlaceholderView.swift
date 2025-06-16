import SwiftUI

struct EmptyPlaceholderView: View {
    let title: String
    let message: String?
    let icon: String

    init(
        title: String,
        message: String? = nil,
        icon: String = "book"
    ) {
        self.title = title
        self.message = message
        self.icon = icon
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .semibold))
                .foregroundColor(.accentColor)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            if let message {
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    EmptyPlaceholderView(
        title: "No entries found",
        message: "Try a different search query or check back later.",
        icon: "book"
    )
}
