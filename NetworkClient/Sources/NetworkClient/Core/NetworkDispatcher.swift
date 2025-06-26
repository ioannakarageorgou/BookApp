import Foundation

/// Responsible for performing the actual network call using URLSession.
/// Validates HTTP response status code (must be 2xx).
/// Returns raw Data or throws NetworkError on failure.
struct NetworkDispatcher {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.httpError(-1)
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
#if DEBUG
                let errorBody = String(data: data, encoding: .utf8) ?? "<unreadable>"
                print("🚨 HTTP Error \(httpResponse.statusCode)")
                print("📄 Body: \(errorBody)")
#endif
                throw NetworkError.httpError(httpResponse.statusCode)
            }

            return data
        } catch let urlError as URLError {
            throw NetworkError.transportError(urlError)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
