import Foundation

enum Secrets {
    /// Injected from `Config/Secrets.xcconfig` through Info.plist.
    /// `nil` when no key is configured, in which case requests use Google's anonymous quota.
    static var googleBooksAPIKey: String? {
        guard
            let key = Bundle.main.object(forInfoDictionaryKey: "GoogleBooksAPIKey") as? String,
            !key.isEmpty
        else {
            return nil
        }
        return key
    }
}
