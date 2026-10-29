import SwiftUI
import Testing
@testable import SharedUI

@MainActor
@Suite
struct BookCardSnapshotTests {
    @Test
    func placeholderCoverWithSubtitle() {
        let card = BookCard(title: "The Psychology of Money", subtitle: "Morgan Housel", thumbnailURL: nil, onTap: {})
        assertLightAndDarkSnapshots(of: card.componentCanvas(width: 180), named: "withSubtitle", layout: .sizeThatFits)
    }

    @Test
    func longTitleWithoutSubtitle() {
        let card = BookCard(
            title: "A Remarkably Long Book Title That Needs More Than Two Lines",
            subtitle: nil,
            thumbnailURL: nil,
            onTap: {}
        )
        assertLightAndDarkSnapshots(of: card.componentCanvas(width: 180), named: "longTitle", layout: .sizeThatFits)
    }
}
