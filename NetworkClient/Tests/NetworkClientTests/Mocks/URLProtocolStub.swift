import Foundation
import Testing

/// Answers every request made through `URLSession.stubbed()` with `handler`.
final class URLProtocolStub: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.resourceUnavailable))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

/// `URLProtocolStub.handler` is shared, so every suite using it is nested here and runs serially.
@Suite(.serialized)
struct StubbedNetworkTests {}

extension URLSession {
    static func stubbed() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }
}

extension HTTPURLResponse {
    static func stub(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
