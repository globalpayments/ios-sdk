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
}

struct Theme {
    @DynamicColor(light: UIColor.appTintColor, dark: UIColor.appTintColor)
    static var navigationBarColor: UIColor
    @DynamicColor(light: UIColor.white, dark: UIColor.white)
    static var titleColor: UIColor
}
