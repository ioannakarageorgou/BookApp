import Foundation

/// Builds a `URLRequest` from a `Request` and the API's configuration.
enum URLRequestBuilder {
    static func build<T: Request>(from request: T, configuration: NetworkClientConfiguration) throws -> URLRequest {
        guard
            request.path.hasPrefix("/"),
            var components = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: false)
        else {
            throw NetworkError.invalidURL
        }

        let basePath = components.path.hasSuffix("/") ? String(components.path.dropLast()) : components.path
        components.path = basePath + request.path

        let queryItems = request.queryItems + configuration.defaultQueryItems
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        let headers = configuration.defaultHeaders.merging(request.headers) { _, requestValue in requestValue }
        for (field, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: field)
        }
        return urlRequest
    }
}
