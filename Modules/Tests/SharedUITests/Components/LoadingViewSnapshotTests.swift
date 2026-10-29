import SwiftUI
import Testing
@testable import SharedUI

@MainActor
@Suite
struct LoadingViewSnapshotTests {
    @Test
    func defaultMessage() {
        assertLightAndDarkSnapshots(of: LoadingView(), named: "defaultMessage")
    }

    @Test
    func customMessage() {
        assertLightAndDarkSnapshots(of: LoadingView(message: "Please wait..."), named: "customMessage")
    }
}
