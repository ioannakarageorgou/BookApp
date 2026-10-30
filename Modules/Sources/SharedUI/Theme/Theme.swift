import SwiftUI

package struct Theme {
    private static let bundle = Bundle.module

    package static let accentOpacityLow: Double = 0.3
    package static let shadowOpacity: Double = 0.08
    package static let cardShadowOpacity: Double = 0.12

    package static let background = Color("AppBackground", bundle: bundle)
    package static let backgroundSecondary = Color("AppBackgroundSecondary", bundle: bundle)
    package static let backgroundTertiary = Color("AppBackgroundTertiary", bundle: bundle)
    package static let backgroundAccent = Color("AppBackgroundAccent", bundle: bundle)
    package static let backgroundDestructive = Color("AppBackgroundDestructive", bundle: bundle)

    package static let textPrimary = Color("AppTextPrimary", bundle: bundle)
    package static let textSecondary = Color("AppTextSecondary", bundle: bundle)
    package static let textTertiary = Color("AppTextTertiary", bundle: bundle)
    package static let textOnAccent = Color("AppTextOnAccent", bundle: bundle)
    package static let textDestructive = Color("AppTextDestructive", bundle: bundle)

    package static let accent = Color("AppAccent", bundle: bundle)
    package static let accentLight = Color("AppAccentLight", bundle: bundle)
    package static let accentSecondary = Color("AppAccentSecondary", bundle: bundle)

    package static let divider = Color("AppDivider", bundle: bundle)
    package static let border = Color("AppBorder", bundle: bundle)
}
