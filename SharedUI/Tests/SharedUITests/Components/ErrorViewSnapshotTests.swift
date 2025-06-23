import XCTest
import SwiftUI
import SnapshotTesting
@testable import SharedUI

final class ErrorViewSnapshotTests: SnapshotTestCase {
    func test_errorView_defaultMessage_withoutRetry() {
        let view = ErrorView()
        assertSnapshots(of: view, named: "errorView_default_withoutRetry")
    }

    func test_errorView_customMessage_withoutRetry() {
        let view = ErrorView(message: "Custom error message")
        assertSnapshots(of: view, named: "errorView_custom_withoutRetry")
    }

    func test_errorView_defaultMessage_withRetry() {
        let view = ErrorView(onRetry: {})
        assertSnapshots(of: view, named: "errorView_default_withRetry")
    }

    func test_errorView_customMessage_withRetry() {
        let view = ErrorView(message: "Custom error occurred", onRetry: {})
        assertSnapshots(of: view, named: "errorView_custom_withRetry")
    }
}
