import Testing
@testable import BookApp

@Suite
struct SecretsTests {
    @Test
    func readsConfiguredKey() {
        #expect(Secrets.googleBooksAPIKey(in: ["GoogleBooksAPIKey": "abc123"]) == "abc123")
    }

    @Test(arguments: [
        ["GoogleBooksAPIKey": ""],
        [:],
        nil,
    ] as [[String: String]?])
    func returnsNilWithoutAKey(infoDictionary: [String: String]?) {
        #expect(Secrets.googleBooksAPIKey(in: infoDictionary) == nil)
    }
}
