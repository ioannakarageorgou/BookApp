import SwiftUI
import Testing
@testable import SharedUI

@MainActor
@Suite
struct FavoriteBookCardSnapshotTests {
    @Test
    func placeholderCoverWithHeartBadge() {
        let card = FavoriteBookCard(title: "Atomic Habits", subtitle: "James Clear", thumbnailURL: nil, onTap: {})
        assertLightAndDarkSnapshots(of: card.componentCanvas(), named: "default", layout: .sizeThatFits)
    }
}
