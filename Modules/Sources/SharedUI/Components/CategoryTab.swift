import SwiftUI

/// A pill-shaped category tab button with selected state
public struct CategoryTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    public init(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: AppLayout.FontSize.footnote, weight: .semibold))
                .foregroundColor(isSelected ? Theme.background : Theme.textSecondary)
                .padding(.horizontal, AppLayout.Spacing.large)
                .padding(.vertical, AppLayout.Spacing.small)
                .background(
                    isSelected ? Theme.textPrimary : Color.clear
                )
                .cornerRadius(AppLayout.CornerRadius.round)
                .shadow(
                    color: isSelected ? Color.black.opacity(0.1) : Color.clear,
                    radius: AppLayout.Spacing.small,
                    x: 0,
                    y: 2
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: AppLayout.Spacing.small) {
        CategoryTab(title: "All", isSelected: true) {}
        CategoryTab(title: "Fiction", isSelected: false) {}
        CategoryTab(title: "Non-Fiction", isSelected: false) {}
    }
    .padding()
    .background(Theme.background)
}
