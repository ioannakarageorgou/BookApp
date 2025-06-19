import SwiftUI
import ComposableArchitecture
import SharedUI

struct LoadedBooksView: View {
    let books: [Book]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.Spacing.medium) {
                Text("Books")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Theme.textPrimary)
                    .padding(.horizontal)

                LazyVStack(spacing: AppLayout.Spacing.small) {
                    ForEach(books) { book in
                        RowView(
                            title: book.title,
                            subtitle: book.subtitle,
                            thumbnailURL: book.thumbnailURL
                        )
                    }
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}


#Preview("Loaded Books") {
    LoadedBooksView(books: Book.fixtures)
}
