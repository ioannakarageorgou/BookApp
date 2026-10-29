import Foundation
import CoreGraphics

package enum AppLayout {
    package enum Spacing {
        package static let tiny: CGFloat = 4
        package static let small: CGFloat = 8
        package static let medium: CGFloat = 16
        package static let large: CGFloat = 24
        package static let extraLarge: CGFloat = 32
        package static let huge: CGFloat = 40
    }

    package enum CornerRadius {
        package static let small: CGFloat = 8
        package static let medium: CGFloat = 12
        package static let large: CGFloat = 16
        package static let extraLarge: CGFloat = 20
        package static let round: CGFloat = 999 // For fully rounded elements (pills, circles)
    }

    package enum ImageSize {
        // Book cover sizes
        package static let coverSmallWidth: CGFloat = 100
        package static let coverSmallHeight: CGFloat = 140

        package static let coverMediumWidth: CGFloat = 130
        package static let coverMediumHeight: CGFloat = 180

        package static let coverLargeWidth: CGFloat = 160
        package static let coverLargeHeight: CGFloat = 220

        package static let coverHeroWidth: CGFloat = 200
        package static let coverHeroHeight: CGFloat = 280

        // Generic sizes (icons, avatars, buttons)
        package static let iconSmall: CGFloat = 16
        package static let iconMedium: CGFloat = 24
        package static let iconLarge: CGFloat = 32

        package static let avatarSmall: CGFloat = 40
        package static let avatarMedium: CGFloat = 60
        package static let avatarLarge: CGFloat = 80
    }

    package enum Duration {
        package static let short: Double = 0.2
        package static let medium: Double = 0.4
        package static let long: Double = 0.6
    }

    package enum Scale {
        package static let progressView: CGFloat = 1.2
    }

    package enum Grid {
        package static let booksColumns: Int = 2
        package static let booksSpacing: CGFloat = 20
    }

    package enum FontSize {
        package static let caption: CGFloat = 11
        package static let footnote: CGFloat = 13
        package static let body: CGFloat = 15
        package static let headline: CGFloat = 17
        package static let title3: CGFloat = 20
        package static let title2: CGFloat = 22
        package static let title: CGFloat = 28
        package static let largeTitle: CGFloat = 34
    }
}
