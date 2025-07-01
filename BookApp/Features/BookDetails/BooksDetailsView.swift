import SwiftUI
import ComposableArchitecture
import SharedUI

struct BookDetailsView: View {
    let store: StoreOf<BookDetails>

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 16) {
                switch store.bookDetails {
                case .idle, .loading:
                    LoadingView(message: "Loading book details...")

                case .error(let message):
                    ErrorView(message: message) {
                        store.send(.fetchDetails)
                    }

                case .loaded(let book):
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if let url = book.thumbnailURL {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(height: 200)
                                .cornerRadius(12)
                            }

                            Text(book.title)
                                .font(.title)
                                .bold()

                            if let subtitle = book.subtitle {
                                Text(subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            if let desc = book.description {
                                Text(desc)
                                    .font(.body)
                            }

                            Spacer()
                        }
                        .padding()
                    }
                }
            }
            .onAppear { store.send(.fetchDetails) }
            .navigationTitle("Details")
            .background(Theme.background.ignoresSafeArea())
        }
    }
}
