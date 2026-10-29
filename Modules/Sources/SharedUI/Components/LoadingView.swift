import SwiftUI

public struct LoadingView: View {
    let message: String

    public init(message: String = "Loading...") {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: AppLayout.Spacing.medium) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(AppLayout.Scale.progressView)
                .tint(Theme.accent)

            Text(message)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
    }
}

#Preview {
    LoadingView()
}
