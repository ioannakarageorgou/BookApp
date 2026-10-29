import Foundation

extension String {
    /// Converts the simple HTML used in Google Books descriptions to plain text.
    ///
    /// Handles paragraphs, line breaks, other tags (removed) and named or numeric entities.
    /// Unlike `NSAttributedString`'s HTML importer, which must run on the main thread, this is
    /// plain string processing and safe on any thread.
    var htmlToPlainString: String {
        let withoutTags = self
            .replacing(/(?i)<br\s*\/?>/, with: "\n")
            .replacing(/(?i)<\/p\s*>/, with: "\n\n")
            .replacing(/<[^>]+>/, with: "")

        // A single pass decodes each entity once, so "&amp;lt;" becomes "&lt;", not "<".
        let decoded = withoutTags.replacing(/&(#[xX][0-9A-Fa-f]+|#[0-9]+|[A-Za-z]+);/) { match in
            Self.decodeEntity(String(match.output.1)) ?? String(match.output.0)
        }

        return decoded
            .replacing(/\n{3,}/, with: "\n\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// `entity` is the text between `&` and `;`, e.g. "amp", "#39" or "#x201C".
    private static func decodeEntity(_ entity: String) -> String? {
        let scalarValue: UInt32?
        if entity.hasPrefix("#x") || entity.hasPrefix("#X") {
            scalarValue = UInt32(entity.dropFirst(2), radix: 16)
        } else if entity.hasPrefix("#") {
            scalarValue = UInt32(entity.dropFirst())
        } else {
            return ["amp": "&", "lt": "<", "gt": ">", "quot": "\"", "apos": "'", "nbsp": " "][entity]
        }
        return scalarValue.flatMap(Unicode.Scalar.init).map { String(Character($0)) }
    }
}
