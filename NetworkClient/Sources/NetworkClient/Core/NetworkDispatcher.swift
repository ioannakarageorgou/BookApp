import Foundation
import OSLog

private let logger = Logger(subsystem: "BookApp", category: "network")

/// Performs the `URLSession` call and validates the HTTP status code.
///
/// Errors: transport failures become `.transportError`, non-2xx responses `.httpError`, and
/// cancellation is reported as `CancellationError` rather than as a network failure.
struct NetworkDispatcher {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send(_ request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse
        // Only the URLSession call is inside `do`, so errors thrown while validating the
        // response below are never caught and re-wrapped by these handlers.
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch let error as URLError {
            throw NetworkError.transportError(error)
        } catch let error as CancellationError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.httpError(-1)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "<unreadable>"
            logger.error("HTTP \(httpResponse.statusCode): \(errorBody)")
            throw NetworkError.httpError(httpResponse.statusCode)
        }

        return data
    }
}
