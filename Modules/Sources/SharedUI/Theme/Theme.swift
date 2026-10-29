import SwiftUI

public struct Theme {
    private static let bundle = Bundle.module

    public static let accentOpacityLow: Double = 0.3
    public static let shadowOpacity: Double = 0.08
    public static let cardShadowOpacity: Double = 0.12

    /// Main app background
    public static let background = Color("AppBackground", bundle: bundle)

    /// Secondary background for cards and elevated surfaces
    public static let backgroundSecondary = Color("AppBackgroundSecondary", bundle: bundle)

    /// Tertiary background for nested cards or special sections
    public static let backgroundTertiary = Color("AppBackgroundTertiary", bundle: bundle)

    /// Accent background for special sections (like favorites shelf)
    public static let backgroundAccent = Color("AppBackgroundAccent", bundle: bundle)

    /// Destructive action backgrounds
    public static let backgroundDestructive = Color("AppBackgroundDestructive", bundle: bundle)

    /// Primary text (darkest, highest contrast)
    public static let textPrimary = Color("AppTextPrimary", bundle: bundle)

    /// Secondary text (medium contrast, for subtitles/metadata)
    public static let textSecondary = Color("AppTextSecondary", bundle: bundle)

    /// Tertiary text (lowest contrast, for captions/labels)
    public static let textTertiary = Color("AppTextTertiary", bundle: bundle)

    /// Text on accent-colored backgrounds
    public static let textOnAccent = Color("AppTextOnAccent", bundle: bundle)

    /// Destructive/error text
    public static let textDestructive = Color("AppTextDestructive", bundle: bundle)

    /// Primary accent
    public static let accent = Color("AppAccent", bundle: bundle)

    /// Light accent for backgrounds/highlights
    public static let accentLight = Color("AppAccentLight", bundle: bundle)

    /// Secondary accent (optional, for variety)
    public static let accentSecondary = Color("AppAccentSecondary", bundle: bundle)

    /// Subtle divider lines
    public static let divider = Color("AppDivider", bundle: bundle)

    /// Border for cards and input fields
    public static let border = Color("AppBorder", bundle: bundle)
}
