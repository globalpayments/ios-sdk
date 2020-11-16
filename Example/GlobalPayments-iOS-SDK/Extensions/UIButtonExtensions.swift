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

    func apply(style: ButtonStyle) {
        backgroundColor = style.backgroundColor
        setTitleColor(style.titleColor, for: .normal)
        layer.cornerRadius = style.cornerRadius
        titleLabel?.font = style.font
    }
}
