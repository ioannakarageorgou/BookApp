public enum NetworkError: Error {
    case invalidURL
    case decodingError(Error)
    case httpError(Int)
    case unknown(Error)
}
