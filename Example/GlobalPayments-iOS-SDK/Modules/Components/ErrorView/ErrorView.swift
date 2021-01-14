import UIKit
import GlobalPayments_iOS_SDK

final class ErrorView: UIView {

    @IBOutlet private weak var errorMessageTextView: UITextView!

    class func instantiateFromNib() -> ErrorView {
        UINib(nibName: "ErrorView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! ErrorView
    }

    func display(_ error: Error?) {
        if let error = error as? BuilderException { errorMessageTextView.text = error.message }
        else if let error = error as? ConfigurationException { errorMessageTextView.text = error.message }
        else if let error = error as? UnsupportedTransactionException { errorMessageTextView.text = error.message }
        else if let error = error as? ApiException { errorMessageTextView.text = error.message }
        else if let error = error as? GatewayException {
            let empty = "generic.empty".localized()
            let message = "Message:\n\(error.message ?? empty)"
            let responseCode = "Response Code:\n\(error.responseCode ?? empty)"
            let responseMessage = "Response Message:\n\(error.responseMessage ?? empty)"
            errorMessageTextView.text = "\(message)\n\n\(responseCode)\n\n\(responseMessage)"
        } else {
            errorMessageTextView.text = error.debugDescription
        }
    }
}
