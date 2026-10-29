import SwiftUI
import Testing
@testable import SharedUI

@MainActor
@Suite
struct ErrorViewSnapshotTests {
    @Test
    func defaultMessageWithoutRetry() {
        assertLightAndDarkSnapshots(of: ErrorView(), named: "default_withoutRetry")
    }

    @Test
    func customMessageWithoutRetry() {
        assertLightAndDarkSnapshots(of: ErrorView(message: "Custom error message"), named: "custom_withoutRetry")
    }

    @Test
    func defaultMessageWithRetry() {
        assertLightAndDarkSnapshots(of: ErrorView(onRetry: {}), named: "default_withRetry")
    }

    @Test
    func customMessageWithRetry() {
        assertLightAndDarkSnapshots(of: ErrorView(message: "Custom error occurred", onRetry: {}), named: "custom_withRetry")
    }
}
