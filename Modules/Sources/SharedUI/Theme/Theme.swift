import SwiftUI

package struct Theme {
    private static let bundle = Bundle.module

    package static let accentOpacityLow: Double = 0.3
    package static let shadowOpacity: Double = 0.08
    package static let cardShadowOpacity: Double = 0.12

    /// Main app background
    package static let background = Color("AppBackground", bundle: bundle)

    /// Secondary background for cards and elevated surfaces
    package static let backgroundSecondary = Color("AppBackgroundSecondary", bundle: bundle)

    /// Tertiary background for nested cards or special sections
    package static let backgroundTertiary = Color("AppBackgroundTertiary", bundle: bundle)

    /// Accent background for special sections (like favorites shelf)
    package static let backgroundAccent = Color("AppBackgroundAccent", bundle: bundle)

    /// Destructive action backgrounds
    package static let backgroundDestructive = Color("AppBackgroundDestructive", bundle: bundle)

    /// Primary text (darkest, highest contrast)
    package static let textPrimary = Color("AppTextPrimary", bundle: bundle)

    /// Secondary text (medium contrast, for subtitles/metadata)
    package static let textSecondary = Color("AppTextSecondary", bundle: bundle)

    /// Tertiary text (lowest contrast, for captions/labels)
    package static let textTertiary = Color("AppTextTertiary", bundle: bundle)

    /// Text on accent-colored backgrounds
    package static let textOnAccent = Color("AppTextOnAccent", bundle: bundle)

    /// Destructive/error text
    package static let textDestructive = Color("AppTextDestructive", bundle: bundle)

    /// Primary accent
    package static let accent = Color("AppAccent", bundle: bundle)

    /// Light accent for backgrounds/highlights
    package static let accentLight = Color("AppAccentLight", bundle: bundle)

    /// Secondary accent (optional, for variety)
    package static let accentSecondary = Color("AppAccentSecondary", bundle: bundle)

    /// Subtle divider lines
    package static let divider = Color("AppDivider", bundle: bundle)

    /// Border for cards and input fields
    package static let border = Color("AppBorder", bundle: bundle)
}
