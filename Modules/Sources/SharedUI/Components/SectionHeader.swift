import SwiftUI

/// A reusable section header with title and optional "See all" button
public struct SectionHeader: View {
    let title: String
    let icon: String?
    let showSeeAll: Bool
    let onSeeAllTap: (() -> Void)?

    public init(
        title: String,
        icon: String? = nil,
        showSeeAll: Bool = false,
        onSeeAllTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.showSeeAll = showSeeAll
        self.onSeeAllTap = onSeeAllTap
    }

    public var body: some View {
        HStack(spacing: AppLayout.Spacing.small) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: AppLayout.FontSize.headline, weight: .semibold))
                    .foregroundColor(Theme.accent)
            }

            Text(title)
                .font(.system(size: AppLayout.FontSize.title2, weight: .bold, design: .serif))
                .foregroundColor(Theme.textPrimary)

            Spacer()

            if showSeeAll, let onSeeAllTap = onSeeAllTap {
                Button(action: onSeeAllTap) {
                    Text("See all")
                        .font(.system(size: AppLayout.FontSize.footnote, weight: .semibold))
                        .foregroundColor(Theme.accent)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: AppLayout.Spacing.large) {
        SectionHeader(
            title: "Your Shelf",
            icon: "heart.fill",
            showSeeAll: true,
            onSeeAllTap: {}
        )

        SectionHeader(
            title: "Discover",
            showSeeAll: true,
            onSeeAllTap: {}
        )

        SectionHeader(title: "Recently Added")
    }
    .padding()
    .background(Theme.background)
}
