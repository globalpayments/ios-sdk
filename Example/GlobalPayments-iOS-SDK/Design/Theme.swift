import UIKit

@propertyWrapper
struct DynamicColor {
    let light: UIColor
    let dark: UIColor

    var wrappedValue: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark: return self.dark
                case .light, .unspecified: return self.light
                @unknown default: return self.light
                }
            }
        } else {
            return light
        }
    }
}

extension UIColor {
    static let appTintColor = UIColor(red: 0, green: 60/255, blue: 113/255, alpha: 1.0)
    static let appGreenColor = UIColor(red: 0, green: 128/255, blue: 79/255, alpha: 1.0)
}

extension UIFont {
    static let title: UIFont = systemFont(ofSize: 16, weight: .semibold)
    static let subtitle: UIFont = systemFont(ofSize: 16, weight: .regular)
}

struct Theme {
    // MARK: - Colors
    @DynamicColor(light: UIColor.appTintColor, dark: UIColor.appTintColor)
    static var navigationBarColor: UIColor
    @DynamicColor(light: UIColor.white, dark: UIColor.white)
    static var titleColor: UIColor
    @DynamicColor(light: UIColor.appGreenColor, dark: UIColor.appGreenColor)
    static var buttonFillColor: UIColor
    @DynamicColor(light: .white, dark: .white)
    static var buttonTextColor: UIColor

    // MARK: - Corners
    static var cornerRadius: CGFloat = 8.0

    // MARK: - Fonts
    static let titleFont: UIFont = UIFont.title
    static let subtitleFont: UIFont = UIFont.subtitle
}
