import UIKit

func UI(execute block: @escaping () -> Void) {
    if Thread.isMainThread { return block() }
    DispatchQueue.main.async(execute: block)
}

extension UIActivityIndicatorView {

    func addLoadingLabel(_ label: String = "Waiting for Auth") {
        let loadingTextLabel = UILabel()
        loadingTextLabel.textColor = UIColor.white
        loadingTextLabel.text = label
        loadingTextLabel.font = .boldSystemFont(ofSize: 18)
        loadingTextLabel.sizeToFit()
        loadingTextLabel.center = CGPoint(x: center.x, y: center.y + 30)
        addSubview(loadingTextLabel)
    }

    func removeLoadingLabel() {
        if let view = subviews.last {
            if view is UILabel {
                view.removeFromSuperview()
            }
        }
    }
}
