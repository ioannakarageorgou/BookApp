import XCTest
import SwiftUI
import SnapshotTesting
@testable import SharedUI

final class EmptyPlaceholderViewSnapshotTests: SnapshotTestCase {
    func test_emptyPlaceholder_defaultState() {
        let view = EmptyPlaceholderView(
            title: "No entries found",
            message: "Try a different search query or check back later.",
            icon: "book"
        )
        assertSnapshots(of: view, named: "empty_placeholder_default")
    }
}
