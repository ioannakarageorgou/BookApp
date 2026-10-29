import SwiftUI
import Testing
@testable import SharedUI

@MainActor
@Suite
struct SectionHeaderSnapshotTests {
    @Test
    func titleOnly() {
        let header = SectionHeader(title: "Discover")
        assertLightAndDarkSnapshots(of: header.componentCanvas(width: 360), named: "titleOnly", layout: .sizeThatFits)
    }

    @Test
    func iconAndSeeAll() {
        let header = SectionHeader(title: "Your Shelf", icon: "heart.fill", showSeeAll: true, onSeeAllTap: {})
        assertLightAndDarkSnapshots(of: header.componentCanvas(width: 360), named: "iconAndSeeAll", layout: .sizeThatFits)
    }
}
