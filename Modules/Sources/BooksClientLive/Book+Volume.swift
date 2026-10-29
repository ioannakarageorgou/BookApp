import BookAPIClient
import Foundation
import Models

extension Book {
    init(volume: Volume) {
        self.init(
            id: volume.id,
            title: volume.volumeInfo.title,
            subtitle: volume.volumeInfo.displaySubtitle,
            thumbnailURL: volume.volumeInfo.secureThumbnailURL
        )
    }
}

extension Details {
    init(volume: Volume) {
        self.init(
            core: Book(volume: volume),
            description: volume.volumeInfo.description?.htmlToPlainString,
            authors: volume.volumeInfo.authors ?? [],
            publisher: volume.volumeInfo.publisher,
            publishedDate: volume.volumeInfo.publishedDate
        )
    }
}

extension VolumeInfo {
    /// Authors, falling back to the publisher, then the published date.
    var displaySubtitle: String? {
        authors?.joined(separator: ", ")
        ?? publisher
        ?? publishedDate
    }

    var secureThumbnailURL: URL? {
        guard let urlString = imageLinks?.thumbnail else { return nil }
        return URL(string: urlString)?.usingHTTPS
    }
}
