import XCTest
@testable import NetworkClient

final class NetworkDispatcherTests: XCTestCase {
    var session: URLSession!

    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(URLProtocolStub.self)
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        session = URLSession(configuration: config)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        URLProtocolStub.stubResponseData = nil
        URLProtocolStub.stubResponse = nil
        URLProtocolStub.stubError = nil
        session = nil
        super.tearDown()
    }

    func testDispatcher_validResponse() async throws {
        let data = #"{"message":"hello"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        URLProtocolStub.stubResponseData = data
        URLProtocolStub.stubResponse = response

        let dispatcher = NetworkDispatcher(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)
        let resultData = try await dispatcher.send(request)

        XCTAssertEqual(resultData, data)
    }

    func testDispatcher_errorStatusCode() async throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!

        URLProtocolStub.stubResponse = response

        let dispatcher = NetworkDispatcher(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        do {
            _ = try await dispatcher.send(request)
            XCTFail("Expected error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .httpError(500))
        }
    }

    func testDispatcher_transportError() async {
        let transportError = NSError(domain: "network", code: -1009)
        URLProtocolStub.stubError = transportError

        let dispatcher = NetworkDispatcher(session: session)
        let request = URLRequest(url: URL(string: "https://test.com")!)

        do {
            _ = try await dispatcher.send(request)
            XCTFail("Expected transport error")
        } catch NetworkError.unknown {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
