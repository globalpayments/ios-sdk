import UIKit
import GlobalPayments_iOS_SDK

protocol AccessTokenFormDelegate: class {
    func onComletedForm()
    func onDiscardForm()
}

final class AccessTokenFormViewController: UIViewController, StoryboardInstantiable {

    static let storyboardName = "GlobalPay"

    weak var delegate: AccessTokenFormDelegate?

    @IBOutlet weak private var submitButton: UIButton!
    @IBOutlet weak private var navigationBar: UINavigationBar!
    // App ID
    @IBOutlet weak private var appIdLabel: UILabel!
    @IBOutlet weak private var appIdTextField: UITextField!
    // App Key
    @IBOutlet weak private var appKeyLabel: UILabel!
    @IBOutlet weak private var appKeyTextField: UITextField!
    // Seconds to Expire
    @IBOutlet weak private var secondsLabel: UILabel!
    @IBOutlet weak private var secondsTextField: UITextField!
    // Environment
    @IBOutlet weak private var environmentLabel: UILabel!
    @IBOutlet weak private var environmentTextField: UITextField!
    // Interval to Expire
    @IBOutlet weak private var intervalLabel: UILabel!
    @IBOutlet weak private var intervalTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        submitButton.apply(style: .globalPayStyle)
        hideKeyboardWhenTappedAround()
        environmentTextField.loadDropDownData(Environment.allCases.map { "\($0)".uppercased() }, onSelectItem: didSelectEnvironment)
        intervalTextField.loadDropDownData(IntervalToExpire.allCases.map { $0.rawValue.uppercased() }, onSelectItem: didSelectInterval)
    }

    // MARK: - Actions

    @IBAction private func onCloseAction() {
        delegate?.onDiscardForm()
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        delegate?.onComletedForm()
        dismiss(animated: true, completion: nil)
    }

    private func didSelectEnvironment(_ environment: String) {
        
    }

    private func didSelectInterval(_ interval: String) {
        guard let interval = IntervalToExpire(rawValue: interval) else { return }
        print(interval)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension AccessTokenFormViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.onDiscardForm()
    }
}
