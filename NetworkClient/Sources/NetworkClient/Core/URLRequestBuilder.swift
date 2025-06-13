import Foundation

/// Builds a URLRequest from any Request instance.
/// Adds base URL scheme and host.
/// Injects the API key as a query parameter to authenticate requests.
/// Sets HTTP method and headers as defined by the Request.
enum URLRequestBuilder {
    static func build<T: Request>(from request: T, apiKey: String? = nil) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.googleapis.com"
        components.path = request.path

        var items = request.queryItems
        if let key = apiKey {
            items.append(URLQueryItem(name: "key", value: key))
        }
        components.queryItems = items

        guard let url = components.url else { throw NetworkError.invalidURL }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        request.headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        return urlRequest
    }
}
