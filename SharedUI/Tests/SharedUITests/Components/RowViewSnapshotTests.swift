import XCTest
import SwiftUI
import SnapshotTesting
@testable import SharedUI

final class RowViewSnapshotTests: SnapshotTestCase {
    func test_rowView_showsPlaceholder_whenNoThumbnail() {
        let view = RowView(title: "No image", subtitle: "No thumbnail URL", thumbnailURL: nil)
        assertSnapshots(of: view, named: "row_placeholder")
    }
    
    func test_rowView_showsPlaceholder_whenImageLoadFails() {
        let view = RowView(title: "Load fail", subtitle: nil, thumbnailURL: URL(string: "https://invalid.url"))
        assertSnapshots(of: view, named: "row_load_fail")
    }
}
