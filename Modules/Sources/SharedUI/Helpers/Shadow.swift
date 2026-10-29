import SwiftUI

// MARK: - Shadow Helpers
// Add this extension at the bottom of your Theme.swift file

public extension View {
    /// Small shadow for subtle elevation (buttons, small cards)
    func cardShadowSmall() -> some View {
        self.shadow(
            color: Color.black.opacity(0.06),
            radius: 3,
            x: 0,
            y: 1
        )
    }

    /// Medium shadow for standard cards and elevated surfaces
    func cardShadowMedium() -> some View {
        self.shadow(
            color: Color.black.opacity(0.08),
            radius: 12,
            x: 0,
            y: 4
        )
    }

    /// Large shadow for prominent elements (favorites, hero images)
    func cardShadowLarge() -> some View {
        self.shadow(
            color: Color.black.opacity(0.12),
            radius: 20,
            x: 0,
            y: 8
        )
    }

    /// Extra large shadow for modal overlays and floating elements
    func cardShadowXLarge() -> some View {
        self.shadow(
            color: Color.black.opacity(0.15),
            radius: 25,
            x: 0,
            y: 10
        )
    }
}
