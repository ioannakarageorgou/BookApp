import Foundation
import NetworkClient

public final class MockNetworkClient: NetworkClient {
    public var handler: ((any Request) -> Any)?

    public init(handler: ((any Request) -> Any)? = nil) {
        self.handler = handler
    }

    public func send<T>(_ request: T) async throws -> T.Response where T: Request {
        if let result = handler?(request) as? T.Response {
            return result
        }
        throw NetworkError.unknown
    }
}
