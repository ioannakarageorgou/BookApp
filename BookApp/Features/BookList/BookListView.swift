import SwiftUI
import ComposableArchitecture

struct BookListView: View {
    let store: StoreOf<BookList>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.books) { book in
                    Text(book.title)
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
