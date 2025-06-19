import SwiftUI
import ComposableArchitecture
import SharedUI

struct LoadedBooksView: View {
    let books: [Book]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Books")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)

                LazyVStack(spacing: 8) {
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
    }
}


#Preview("Loaded Books") {
    LoadedBooksView(books: Book.fixtures)
}
