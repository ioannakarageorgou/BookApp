import Foundation
import CoreGraphics

public enum AppLayout {
    public enum Spacing {
        public static let tiny: CGFloat = 4
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 24
        public static let extraLarge: CGFloat = 32
        public static let huge: CGFloat = 40
    }

    public enum CornerRadius {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 16
        public static let extraLarge: CGFloat = 20
        public static let round: CGFloat = 999 // For fully rounded elements (pills, circles)
    }

    public enum ImageSize {
        // Book cover sizes
        public static let coverSmallWidth: CGFloat = 100
        public static let coverSmallHeight: CGFloat = 140

        public static let coverMediumWidth: CGFloat = 130
        public static let coverMediumHeight: CGFloat = 180

        public static let coverLargeWidth: CGFloat = 160
        public static let coverLargeHeight: CGFloat = 220

        public static let coverHeroWidth: CGFloat = 200
        public static let coverHeroHeight: CGFloat = 280

        // Generic sizes (icons, avatars, buttons)
        public static let iconSmall: CGFloat = 16
        public static let iconMedium: CGFloat = 24
        public static let iconLarge: CGFloat = 32

        public static let avatarSmall: CGFloat = 40
        public static let avatarMedium: CGFloat = 60
        public static let avatarLarge: CGFloat = 80
    }

    public enum Duration {
        public static let short: Double = 0.2
        public static let medium: Double = 0.4
        public static let long: Double = 0.6
    }

    public enum Scale {
        public static let progressView: CGFloat = 1.2
    }

    public enum Grid {
        public static let booksColumns: Int = 2
        public static let booksSpacing: CGFloat = 20
    }

    public enum FontSize {
        public static let caption: CGFloat = 11
        public static let footnote: CGFloat = 13
        public static let body: CGFloat = 15
        public static let headline: CGFloat = 17
        public static let title3: CGFloat = 20
        public static let title2: CGFloat = 22
        public static let title: CGFloat = 28
        public static let largeTitle: CGFloat = 34
    }
}
