import XCTest
import SnapshotTesting
import SwiftUI

open class SnapshotTestCase: XCTestCase {
    public var snapshotDevice: ViewImageConfig { .iPhone13 }

    public func assertSnapshots<V: View>(
        of view: V,
        named name: String,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let strategy: Snapshotting<AnyView, UIImage> = .image(layout: .device(config: snapshotDevice))

        let light = AnyView(view.environment(\.colorScheme, .light))
        let dark = AnyView(view.environment(\.colorScheme, .dark))

        assertSnapshot(of: light, as: strategy, named: "\(name)_light", file: file, testName: testName, line: line)
        assertSnapshot(of: dark, as: strategy, named: "\(name)_dark", file: file, testName: testName, line: line)
    }
}
