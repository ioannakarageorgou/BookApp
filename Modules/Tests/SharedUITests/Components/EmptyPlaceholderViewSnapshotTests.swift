import SwiftUI
import Testing
@testable import SharedUI

@MainActor
@Suite
struct EmptyPlaceholderViewSnapshotTests {
    @Test
    func titleMessageAndIcon() {
        let view = EmptyPlaceholderView(
            title: "No entries found",
            message: "Try a different search query or check back later.",
            icon: "book"
        )
        assertLightAndDarkSnapshots(of: view, named: "default")
    }

    @Test
    func titleOnly() {
        assertLightAndDarkSnapshots(of: EmptyPlaceholderView(title: "Nothing here yet"), named: "titleOnly")
    }
}
