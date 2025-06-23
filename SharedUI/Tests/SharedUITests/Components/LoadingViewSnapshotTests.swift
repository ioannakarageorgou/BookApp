import XCTest
import SwiftUI
import SnapshotTesting
@testable import SharedUI

final class LoadingViewSnapshotTests: SnapshotTestCase {
    func test_loadingView_defaultMessage() {
        let view = LoadingView()
        assertSnapshots(of: view, named: "loadingView_defaultMessage")
    }

    func test_loadingView_customMessage() {
        let view = LoadingView(message: "Please wait...")
        assertSnapshots(of: view, named: "loadingView_customMessage")
    }
}
