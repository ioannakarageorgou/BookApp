import SnapshotTesting
import SwiftUI
import UIKit
@testable import SharedUI

/// Records `view` in light and dark mode as `<name>_light` and `<name>_dark`.
///
/// Images are always rendered at @3x. Record and verify them on the reference simulator,
/// iPhone 17 Pro on iOS 26.5: other iOS versions render text and SF Symbols differently.
@MainActor
func assertLightAndDarkSnapshots<V: View>(
    of view: V,
    named name: String,
    layout: SwiftUISnapshotLayout = .device(config: .iPhone13),
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    for style in [UIUserInterfaceStyle.light, .dark] {
        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: layout,
                traits: UITraitCollection {
                    $0.userInterfaceStyle = style
                    $0.displayScale = 3
                }
            ),
            named: "\(name)_\(style == .dark ? "dark" : "light")",
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
    }
}

extension View {
    /// Places a component on the app background for `.sizeThatFits` snapshots, at its ideal size
    /// or at a fixed width with its ideal height. Without `fixedSize`, text and flexible shapes
    /// collapse to zero because the snapshot proposes no space.
    func componentCanvas(width: CGFloat? = nil) -> some View {
        fixedSize(horizontal: width == nil, vertical: true)
            .frame(width: width)
            .padding(AppLayout.Spacing.medium)
            .background(Theme.background)
    }
}
