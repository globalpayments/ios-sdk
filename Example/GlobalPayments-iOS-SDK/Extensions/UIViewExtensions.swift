import UIKit

extension UIView {

    func clearSubviews() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }
}
