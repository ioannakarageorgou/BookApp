import SwiftUI
import ComposableArchitecture

struct BookListView: View {
    let store: StoreOf<BookList>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 20) {
                Text(viewStore.message)
                    .font(.title)

                Button("Tap me") {
                    viewStore.send(.buttonTapped)
                }
            }
            .padding()
        }
    }
}
