import SwiftUI

public struct Theme {
    private static let bundle = Bundle.module

    public static let background = Color("AppBackground", bundle: bundle)
    public static let backgroundSecondary = Color("AppBackgroundSecondary", bundle: .module)

    public static let textPrimary = Color("AppTextPrimary", bundle: bundle)
    public static let textSecondary = Color("AppTextSecondary", bundle: bundle)
    public static let textOnAccent = Color("AppTextOnAccent", bundle: bundle)

    public static let accent = Color("AppAccent", bundle: bundle)
}
