import UIKit

final class ErrorView: UIView {

    @IBOutlet private weak var errorMessageTextView: UITextView!

    class func instantiateFromNib() -> ErrorView {
        UINib(nibName: "ErrorView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! ErrorView
    }

    func display(_ error: Error?) {
        errorMessageTextView.text = error.debugDescription
    }
}
