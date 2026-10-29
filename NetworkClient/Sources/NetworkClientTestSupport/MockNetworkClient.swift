import Foundation
import NetworkClient

/// Returns whatever `handler` returns for each request. Immutable, so it's safe to share.
public final class MockNetworkClient: NetworkClient {
    public let handler: (@Sendable (any Request) throws -> Any)?

    public init(handler: (@Sendable (any Request) throws -> Any)? = nil) {
        self.handler = handler
    }

    public func send<T: Request>(_ request: T) async throws -> T.Response {
        if let result = try handler?(request) as? T.Response {
            return result
        }
        let error = NSError(
            domain: "MockNetworkClient",
            code: 0,
            userInfo: [
                NSLocalizedDescriptionKey: "No mock response provided for this request."
            ]
        )
        throw NetworkError.unknown(error)
    }
}
