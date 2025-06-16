public final class MockNetworkClient: NetworkClient {
    public var handler: ((any Request) throws -> Any)?

    public init(handler: ((any Request) throws -> Any)? = nil) {
        self.handler = handler
    }
    
    public func send<T: Request>(_ request: T) async throws -> T.Response {
        if let result = try handler?(request) as? T.Response {
            return result
        }
        throw NetworkError.unknown
    }
}
