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
    
    static var redesignStyle: ButtonStyle {
        let bgColor = #colorLiteral(red: 0, green: 0.5375977755, blue: 0.8219335675, alpha: 1)
        return ButtonStyle(
            backgroundColor: bgColor,
            titleColor: .white,
            font: Theme.titleFont,
            cornerRadius: 24
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
    
    func applyWithImage(style: ButtonStyle, title: String, for state: UIControl.State = .normal) {
        backgroundColor = style.backgroundColor
        setTitleColor(style.titleColor, for: .normal)
        layer.cornerRadius = style.cornerRadius
        titleLabel?.font = style.font
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.textAlignment = .center
        let image = #imageLiteral(resourceName: "ic_arrow_next")
        setImage(image, for: .normal)
        setTitle("\(title)   ", for: state)
        semanticContentAttribute = .forceRightToLeft
    }
    
    func applyFlat(style: ButtonStyle, title: String, for state: UIControl.State = .normal) {
        backgroundColor = .white
        setTitleColor(.black, for: .normal)
        layer.cornerRadius = style.cornerRadius
        layer.borderWidth = 1
        layer.borderColor = style.backgroundColor.cgColor
        titleLabel?.font = style.font
        titleLabel?.textAlignment = .center
        setTitle(title, for: state)
    }
}
