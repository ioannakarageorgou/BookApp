public enum NetworkError: Error, Equatable {
    case invalidURL
    case decodingError
    case httpError(Int)
    case unknown
}
