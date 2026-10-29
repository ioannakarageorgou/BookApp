import Foundation

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
            if let rawJSON = String(data: data, encoding: .utf8) {
                print("🧩 Decoding failed for \(T.Response.self)")
                print("📦 Raw JSON: \(rawJSON)")
            } else {
                print("🧩 Decoding failed. Could not convert data to string.")
            }
            print("🐛 Decoding error: \(error)")
#endif
            throw NetworkError.decodingError(error)
        }
    }
}
