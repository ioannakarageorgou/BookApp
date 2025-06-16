import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: (() -> Void)?

    init(
        message: String = "Something went wrong. Please try again later.",
        onRetry: (() -> Void)? = nil
    ) {
        self.message = message
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("😕")
                .font(.system(size: 48))

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Text("Retry")
                        .font(.subheadline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .transition(.opacity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .animation(.default, value: onRetry != nil)
    }
}

#Preview {
    ErrorView(onRetry: {})
}
