import SwiftUI
import Testing
@testable import SharedUI

@MainActor
@Suite
struct CategoryTabSnapshotTests {
    @Test
    func selectedAndUnselected() {
        let tabs = HStack(spacing: AppLayout.Spacing.small) {
            CategoryTab(title: "All", isSelected: true) {}
            CategoryTab(title: "Fiction", isSelected: false) {}
        }
        assertLightAndDarkSnapshots(of: tabs.componentCanvas(), named: "selectedAndUnselected", layout: .sizeThatFits)
    }
}
