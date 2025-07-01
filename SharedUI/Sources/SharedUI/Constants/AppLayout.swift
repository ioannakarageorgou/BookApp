import Foundation

public enum AppLayout {
    public enum Spacing {
        public static let tiny: CGFloat = 4
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 24
        public static let extraLarge: CGFloat = 32
    }

    public enum CornerRadius {
        public static let small: CGFloat = 6
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 20
    }

    public struct ImageSize {
        public static let width: CGFloat = 50
        public static let height: CGFloat = 75
        public static let mediumWidth: CGFloat = 120
        public static let mediumHeight: CGFloat = 180
    }

    public enum Duration {
        public static let short: Double = 0.2
        public static let medium: Double = 0.4
        public static let long: Double = 0.6
    }

    public struct Scale {
        public static let progressView: CGFloat = 1.2
    }
}
