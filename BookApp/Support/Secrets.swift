import Foundation

enum Secrets {
    static var googleBooksAPIKey: String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil),
            let dict = plist as? [String: Any],
            let key = dict["GoogleBooksAPIKey"] as? String
        else {
            fatalError("Missing or invalid Google Books API key")
        }
        return key
    }
}
