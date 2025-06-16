import SwiftUI

public struct EmptyPlaceholderView: View {
    public let title: String
    public let message: String?
    public let icon: String

    public init(
        title: String,
        message: String? = nil,
        icon: String = "book"
    ) {
        self.title = title
        self.message = message
        self.icon = icon
    }

    public var body: some View {
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
