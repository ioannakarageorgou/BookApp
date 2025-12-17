import SwiftUI

public struct Theme {
    private static let bundle = Bundle.module

    public static let accentOpacityLow: Double = 0.3

    public static let background = Color("AppBackground", bundle: bundle)
    public static let backgroundSecondary = Color("AppBackgroundSecondary", bundle: .module)
    public static let backgroundTertiary = Color("AppBackgroundTertiary", bundle: .module)
    public static let backgroundAccent = Color("AppBackgroundAccent", bundle: bundle)
    public static let backgroundDestructive = Color("AppBackgroundDestructive", bundle: bundle)

    public static let textPrimary = Color("AppTextPrimary", bundle: bundle)
    public static let textSecondary = Color("AppTextSecondary", bundle: bundle)
    public static let textTertiary = Color("AppTextTertiary", bundle: bundle)
    public static let textOnAccent = Color("AppTextOnAccent", bundle: bundle)
    public static let textDestructive = Color("AppTextDestructive", bundle: bundle)

    public static let accent = Color("AppAccent", bundle: bundle)
    public static let accentLight = Color("AppAccentLight", bundle: bundle)
    public static let accentSecondary = Color("AppAccentSecondary", bundle: bundle)

    public static let border = Color("AppBorder", bundle: bundle)
    public static let divider = Color("AppDivider", bundle: bundle)
}
