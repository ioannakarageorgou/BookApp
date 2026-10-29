import SwiftUI

package struct ErrorView: View {
    let message: String
    let onRetry: (() -> Void)?

    package init(
        message: String = "Something went wrong. Please try again later.",
        onRetry: (() -> Void)? = nil
    ) {
        self.message = message
        self.onRetry = onRetry
    }

    package var body: some View {
        VStack(spacing: AppLayout.Spacing.medium) {
            Text("😕")
                .font(.system(size: AppLayout.FontSize.largeTitle))

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.textSecondary)

            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Text("Retry")
                        .font(.subheadline)
                        .padding(.horizontal, AppLayout.Spacing.large)
                        .padding(.vertical, AppLayout.Spacing.small)
                        .background(Theme.accent)
                        .foregroundColor(Theme.textOnAccent)
                        .clipShape(Capsule())
                }
                .transition(.opacity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
        .animation(.default, value: onRetry != nil)
    }
}

#Preview {
    ErrorView(onRetry: {})
}
