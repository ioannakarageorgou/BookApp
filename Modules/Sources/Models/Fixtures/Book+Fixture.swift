#if DEBUG
import Foundation

public extension Book {
    static func fixture(
        id: String = "1",
        title: String = "Sample Book",
        subtitle: String? = "A great book",
        thumbnailURL: URL? = URL(string: "https://example.com/thumbnail.jpg")
    ) -> Self {
        Book(
            id: id,
            title: title,
            subtitle: subtitle,
            thumbnailURL: thumbnailURL
        )
    }

    static var fixtures: [Self] {
        [
            fixture(id: "1", title: "Book One", subtitle: "Subtitle One"),
            fixture(id: "2", title: "Book Two", subtitle: "Subtitle Two"),
            fixture(id: "3", title: "Book Three", subtitle: "Subtitle Three")
        ]
    }
}
#endif
