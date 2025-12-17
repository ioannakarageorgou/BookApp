import SwiftUI

/// A styled search bar with icon and optional clear button
public struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSubmit: () -> Void

    public init(
        text: Binding<String>,
        placeholder: String = "Search...",
        onSubmit: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }

    public var body: some View {
        HStack(spacing: AppLayout.Spacing.small) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: AppLayout.ImageSize.iconSmall, weight: .medium))
                .foregroundColor(Theme.textTertiary)

            TextField(placeholder, text: $text)
                .font(.system(size: AppLayout.FontSize.body, weight: .medium))
                .foregroundColor(Theme.textPrimary)
                .submitLabel(.search)
                .onSubmit(onSubmit)

            // Clear button (show only when text exists)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: AppLayout.ImageSize.iconSmall, weight: .medium))
                        .foregroundColor(Theme.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppLayout.Spacing.medium)
        .padding(.vertical, AppLayout.Spacing.medium)
        .background(Theme.backgroundSecondary)
        .cornerRadius(AppLayout.CornerRadius.large)
        .cardShadowSmall()
    }
}

#Preview {
    VStack(spacing: AppLayout.Spacing.large) {
        SearchBar(
            text: .constant(""),
            placeholder: "Search books, authors...",
            onSubmit: {}
        )

        SearchBar(
            text: .constant("Swift programming"),
            placeholder: "Search books, authors...",
            onSubmit: {}
        )
    }
    .padding()
    .background(Theme.background)
}
