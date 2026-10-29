import SwiftUI

package struct EmptyPlaceholderView: View {
    let title: String
    let message: String?
    let icon: String

    package init(
        title: String,
        message: String? = nil,
        icon: String = "book"
    ) {
        self.title = title
        self.message = message
        self.icon = icon
    }

    package var body: some View {
        VStack(spacing: AppLayout.Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: AppLayout.FontSize.largeTitle, weight: .semibold))
                .foregroundColor(Theme.accent)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Theme.textPrimary)

            if let message {
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.textSecondary)
                    .padding(.horizontal)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
    }
}

#Preview {
    EmptyPlaceholderView(
        title: "No entries found",
        message: "Try a different search query or check back later.",
        icon: "book"
    )
}
