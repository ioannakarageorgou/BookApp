import Foundation
import OSLog

private let logger = Logger(subsystem: "BookApp", category: "network")

/// Builds the `URLRequest`, sends it through `NetworkDispatcher` and decodes the JSON response.
struct LiveNetworkClient: NetworkClient {
    private let configuration: NetworkClientConfiguration
    private let dispatcher: NetworkDispatcher

    init(configuration: NetworkClientConfiguration, dispatcher: NetworkDispatcher = NetworkDispatcher()) {
        self.configuration = configuration
        self.dispatcher = dispatcher
    }

    func send<T: Request>(_ request: T) async throws -> T.Response {
        let urlRequest = try URLRequestBuilder.build(from: request, configuration: configuration)
        let data = try await dispatcher.send(urlRequest)

        do {
            return try JSONDecoder().decode(T.Response.self, from: data)
        } catch {
#if DEBUG
            let rawJSON = String(data: data, encoding: .utf8) ?? "<unreadable>"
            logger.debug("Raw JSON for failed decode of \(T.Response.self): \(rawJSON)")
#endif
            logger.error("Decoding failed for \(T.Response.self): \(error)")
            throw NetworkError.decodingError(error)
        }
    }
}
