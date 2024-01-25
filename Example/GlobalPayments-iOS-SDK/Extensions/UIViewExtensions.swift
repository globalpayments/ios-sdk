import UIKit

extension UIView {

    func clearSubviews() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }

    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: .zero).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: .zero).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: .zero).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: .zero).isActive = true
    }
    
    @IBInspectable
    public var cornerRadius: CGFloat
    {
        set (radius) {
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = radius > 0
        }
        
        get {
            return self.layer.cornerRadius
        }
    }
    
    func setOnClickListener(action:@escaping () -> Void){
        self.isUserInteractionEnabled = true
        let tapRecogniser = ClickListener(target: self, action: #selector(onViewClicked(sender:)))
        tapRecogniser.onClick = action
        self.addGestureRecognizer(tapRecogniser)
    }
    
    @objc func onViewClicked(sender: ClickListener) {
        if let onClick = sender.onClick {
            onClick()
        }
    }
    
    func cornersBorder(borderColor: UIColor = #colorLiteral(red: 0.8565762639, green: 0.8771021962, blue: 0.9055939317, alpha: 1)) {
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
    }
    
    func setCorners(_ radius: CGFloat) {
        cornerRadius = radius
    }
}

class ClickListener: UITapGestureRecognizer {
    var onClick : (() -> Void)? = nil
}
