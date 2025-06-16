import SwiftUI
import ComposableArchitecture

struct BookListView: View {
    let store: StoreOf<BookList>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                switch viewStore.books {
                case .idle, .loading:
                    loadingView()

                case .error(let message):
                    errorView(with: message)

                case .loaded(let books):
                    loadedView(with: books)
                }
            }
        }
        .onAppear { store.send(.onAppear) }
    }

    private func loadingView() -> some SwiftUI.View {
        ProgressView("Loading books...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
    }

    private func errorView(with message: String) -> some SwiftUI.View {
        VStack(spacing: 12) {
            Text("😕")
                .font(.system(size: 40))
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func loadedView(with books: [Book]) -> some SwiftUI.View {
//        if books.isEmpty {
//            Text("No books found.")
//                .foregroundColor(.secondary)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//        } else {
            List(books) { book in
                Text(book.title)
            }
//        }
    }
}
