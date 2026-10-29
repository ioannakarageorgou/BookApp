public protocol NetworkClient {
    func send<T: Request>(_ request: T) async throws -> T.Response
}

public func makeLiveNetworkClient(apiKey: String? = nil) -> NetworkClient {
    return LiveNetworkClient(apiKey: apiKey)
}

/*
 Network Client Overview:

 1. Request Protocol:
    - Defines the blueprint for any network request.
    - Requires properties: path, queryItems, method, headers.
    - Has an associated Response type (Decodable).

 2. Concrete Request (e.g., FetchBooksRequest):
    - Implements Request for a specific API endpoint.
    - Encapsulates endpoint path, parameters, HTTP method, headers.
    - Does NOT hold the API key directly; key is injected during request building.

 3. URLRequestBuilder:
    - Converts a Request into a URLRequest.
    - Adds base URL scheme and host.
    - Appends API key as a query parameter.
    - Sets HTTP method and headers.

 4. NetworkDispatcher:
    - Performs the actual network call using URLSession.
    - Validates HTTP response status codes.
    - Returns raw Data or throws NetworkError on failure.

 5. NetworkError:
    - Unified error enum for network-related failures.
    - Covers invalid URLs, decoding failures, HTTP errors, unknown errors.
    - Conforms to Error and Equatable for consistent error handling and testing.

 6. LiveNetworkClient:
    - Main interface used by the app to send network requests.
    - Holds the API key and uses URLRequestBuilder + NetworkDispatcher internally.
    - Decodes response data into the Request's Response type.
    - Throws NetworkError on failures.

 Workflow:
 - The app creates a LiveNetworkClient with an API key.
 - Creates a specific Request (e.g., FetchBooksRequest).
 - Calls send() on the client to perform the request.
 - The client builds the URLRequest (injecting the API key).
 - NetworkDispatcher executes the request.
 - Response data is decoded and returned.
 - Errors are handled uniformly using NetworkError.
*/
