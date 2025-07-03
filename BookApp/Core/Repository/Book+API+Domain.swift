import Foundation
import BookAPIClient

extension BooksRepository {
    func mapToBooks(_ volumes: [Volume]?) -> [Book] {
        guard let volumes else { return [] }
        return volumes.map { mapVolumeToBook($0) }
    }

    func mapVolumeToBook(_ volume: Volume) -> Book {
        Book(
            id: volume.id,
            title: volume.volumeInfo.title,
            subtitle: extractSubtitle(from: volume.volumeInfo),
            thumbnailURL:  extractThumbnailURL(from: volume.volumeInfo)
        )
    }

    func mapVolumeToBookDetails(_ volume: Volume) -> Details {
        Details(
            core: Book(
                id: volume.id,
                title: volume.volumeInfo.title,
                subtitle: extractSubtitle(from: volume.volumeInfo),
                thumbnailURL: extractThumbnailURL(from: volume.volumeInfo)
            ),
            description: volume.volumeInfo.description?.htmlToPlainString,
            authors: volume.volumeInfo.authors ?? [],
            publisher: volume.volumeInfo.publisher,
            publishedDate: volume.volumeInfo.publishedDate,
        )
    }

    func extractSubtitle(from info: VolumeInfo) -> String? {
        info.authors?.joined(separator: ", ")
        ?? info.publisher
        ?? info.publishedDate
    }

    func extractThumbnailURL(from info: VolumeInfo) -> URL? {
        guard let urlString = info.imageLinks?.thumbnail else { return nil }
        return URL(string: urlString)?.usingHTTPS
    }
}
