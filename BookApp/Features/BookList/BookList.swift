import Foundation
import ComposableArchitecture

@Reducer
struct BookList {
    struct State: Equatable {
        var books: [Book] = []
    }

    enum Action {
        case onAppear
        case booksResponse(Result<[Book], Error>)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .run { send in
                do {
                    let books = try await fetchBooks(query: "harry potter")
                    await send(.booksResponse(.success(books)))
                } catch {
                    await send(.booksResponse(.failure(error)))
                }
            }


        case let .booksResponse(.success(books)):
            state.books = books
            return .none

        case .booksResponse(.failure):
            // Add better error handling later
            state.books = []
            return .none
        }
    }

    private func fetchBooks(query: String) async throws -> [Book] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let apiKey = Secrets.googleBooksAPIKey
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)&key=\(apiKey)"
        guard let url = URL(string: urlString) else { return [] }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
        return decoded.items.map { Book(id: $0.id, title: $0.volumeInfo.title) }
    }
}
