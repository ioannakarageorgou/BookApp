import XCTest
@testable import NetworkClient

final class LiveNetworkClientTests: XCTestCase {
    override class func setUp() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    override class func tearDown() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }

    func testSend_successfulDecoding() async throws {
        let data = #"{"message":"success"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        URLProtocolStub.stubResponseData = data
        URLProtocolStub.stubResponse = response

        let client = makeLiveNetworkClient(apiKey: "dummy")
        let mockRequest = MockRequest()
        let result = try await client.send(mockRequest)

        XCTAssertEqual(result, MockResponse(message: "success"))
    }

    func testSend_decodingError() async throws {
        let data = #"{"unexpected":"format"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        URLProtocolStub.stubResponseData = data
        URLProtocolStub.stubResponse = response

        let client = makeLiveNetworkClient(apiKey: "dummy")

        do {
            _ = try await client.send(MockRequest())
            XCTFail("Expected decoding error")
        } catch let error as NetworkError {
            if case .decodingError = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected error type")
            }
        }
    }
}
