import UIKit

extension UIViewController {

    func showAlert(message: String) {
        DispatchQueue.main.async { [weak navigationController] in
            let alert = UIAlertController(title: "generic.alert".localized(), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "generic.close".localized(), style: .default))
            navigationController?.present(alert, animated: true)
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

    static func empty() -> UIViewController {
        let viewController = UIViewController()
        viewController.navigationItem.title = "generic.not.implemented".localized()
        let emptyLabel = UILabel()
        emptyLabel.text = "generic.empty".localized()
        emptyLabel.textAlignment = .center
        viewController.view.addSubview(emptyLabel)
        emptyLabel.bindFrameToSuperviewBounds()
        viewController.view.backgroundColor = .white

        return viewController
    }
}
