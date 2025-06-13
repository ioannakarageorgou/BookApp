import Foundation

/// Responsible for performing the actual network call using URLSession.
/// Validates HTTP response status code (must be 2xx).
/// Returns raw Data or throws NetworkError on failure.
struct NetworkDispatcher {
    public init() {}

    public func send(_ request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.httpError(-1)
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }

            return data
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
