import SwiftUI

public struct Theme {
    private static let bundle = Bundle.module

    public static let accentOpacityLow: Double = 0.3

    public static let background = Color("AppBackground", bundle: bundle)
    public static let backgroundSecondary = Color("AppBackgroundSecondary", bundle: .module)
    public static let secondaryBackgroundAccent = Color("AppSecondaryBackgroundAccent", bundle: bundle)
    public static let backgroundDestructive = Color("AppBackgroundDestructive", bundle: bundle)

    public static let textPrimary = Color("AppTextPrimary", bundle: bundle)
    public static let textSecondary = Color("AppTextSecondary", bundle: bundle)
    public static let textOnAccent = Color("AppTextOnAccent", bundle: bundle)
    public static let textDestructive = Color("AppTextDestructive", bundle: bundle)

    public static let accent = Color("AppAccent", bundle: bundle)
}
