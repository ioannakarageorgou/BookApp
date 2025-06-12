import ComposableArchitecture

@Reducer
struct BookList {
    struct State: Equatable {
        var message: String = "Hello, TCA!"
    }

    enum Action: Equatable {
        case buttonTapped
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .buttonTapped:
            state.message = "Button tapped!"
            return .none
        }
    }
}
