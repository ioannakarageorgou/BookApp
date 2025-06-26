import Foundation

public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case transportError(URLError)
    case httpError(Int)
    case decodingError(Error)
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .transportError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "Server returned error code: \(statusCode)."
        case .decodingError:
            return "Failed to decode the response."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
