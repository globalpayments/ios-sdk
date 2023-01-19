import UIKit

extension UIViewController {

    func showAlert(message: String) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            UI { [weak topController] in
                let alert = UIAlertController(title: "generic.alert".localized(), message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "generic.close".localized(), style: .default))
                topController?.present(alert, animated: true)
            }
        }
    }

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
