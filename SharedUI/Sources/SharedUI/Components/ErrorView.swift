import SwiftUI

public struct ErrorView: View {
    let message: String
    let onRetry: (() -> Void)?

    public init(
        message: String = "Something went wrong. Please try again later.",
        onRetry: (() -> Void)? = nil
    ) {
        self.message = message
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("😕")
                .font(.system(size: 48))

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.textSecondary)

            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Text("Retry")
                        .font(.subheadline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
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
