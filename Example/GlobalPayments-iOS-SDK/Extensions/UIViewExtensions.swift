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
}
