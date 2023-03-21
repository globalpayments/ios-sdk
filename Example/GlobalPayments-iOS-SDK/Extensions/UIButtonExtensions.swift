import UIKit

struct ButtonStyle {
    let backgroundColor: UIColor
    let titleColor: UIColor
    let font: UIFont
    let cornerRadius: CGFloat
}

extension ButtonStyle {

    static var globalPayStyle: ButtonStyle {
        ButtonStyle(
            backgroundColor: Theme.buttonFillColor,
            titleColor: Theme.buttonTextColor,
            font: Theme.titleFont,
            cornerRadius: Theme.cornerRadius
        )
    }
}

extension UIButton {

    func apply(style: ButtonStyle, title: String?, for state: UIControl.State = .normal) {
        backgroundColor = style.backgroundColor
        setTitleColor(style.titleColor, for: .normal)
        layer.cornerRadius = style.cornerRadius
        titleLabel?.font = style.font
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.textAlignment = .center
        setTitle(title, for: state)
    }
}
