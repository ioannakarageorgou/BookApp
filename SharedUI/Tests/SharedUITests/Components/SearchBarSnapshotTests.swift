import SwiftUI
import Testing
@testable import SharedUI

@MainActor
@Suite
struct SearchBarSnapshotTests {
    @Test
    func emptyShowsPlaceholder() {
        let searchBar = SearchBar(text: .constant(""), placeholder: "Search books, authors...")
        assertLightAndDarkSnapshots(of: searchBar.componentCanvas(width: 360), named: "empty", layout: .sizeThatFits)
    }

    @Test
    func withTextShowsClearButton() {
        let searchBar = SearchBar(text: .constant("Swift programming"), placeholder: "Search books, authors...")
        assertLightAndDarkSnapshots(of: searchBar.componentCanvas(width: 360), named: "withText", layout: .sizeThatFits)
    }
}
