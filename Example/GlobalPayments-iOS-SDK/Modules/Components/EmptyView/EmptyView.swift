import UIKit

final class EmptyView: UIView {

    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var iconImage: UIImageView!
    
    class func instantiateFromNib() -> EmptyView {
        let nib = UINib(nibName: "EmptyView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! EmptyView
        nib.setupUI()
        return nib
    }

    private func setupUI() {
        messageLabel?.text = "generic.empty".localized()
        iconImage?.tintColor = Theme.navigationBarColor
    }
}
