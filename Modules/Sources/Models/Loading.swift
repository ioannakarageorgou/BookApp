public enum Loading<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case error(String)
}

public extension Loading {
    var value: Value? {
        if case let .loaded(value) = self { return value }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var errorMessage: String? {
        if case let .error(message) = self { return message }
        return nil
    }
}

extension Loading: Sendable where Value: Sendable {}
