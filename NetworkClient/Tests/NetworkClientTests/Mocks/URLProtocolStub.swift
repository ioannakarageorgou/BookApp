import Foundation

class URLProtocolStub: URLProtocol {
    static var stubResponseData: Data?
    static var stubResponse: URLResponse?
    static var stubError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = URLProtocolStub.stubError {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = URLProtocolStub.stubResponse {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let data = URLProtocolStub.stubResponseData {
                self.client?.urlProtocol(self, didLoad: data)
            }
            
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {}
}
