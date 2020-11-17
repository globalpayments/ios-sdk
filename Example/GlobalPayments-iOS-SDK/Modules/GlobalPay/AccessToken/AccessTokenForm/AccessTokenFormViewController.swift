import UIKit
import GlobalPayments_iOS_SDK

protocol AccessTokenFormDelegate: class {
    func onComletedForm(form: AccessTokenForm)
}

final class AccessTokenFormViewController: UIViewController, StoryboardInstantiable {

    static let storyboardName = "AccessToken"

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
        hideKeyboardWhenTappedAround()

        navigationBar.topItem?.title = "access.token.form.title".localized()

        submitButton.apply(style: .globalPayStyle)
        submitButton.setTitle("access.token.form.submit".localized(), for: .normal)

        appIdLabel.text = "access.token.form.app.id".localized()
        appIdTextField.text = Constants.gpApiAppID

        appKeyLabel.text = "access.token.form.app.key".localized()
        appKeyTextField.text = Constants.gpApiAppKey

        secondsLabel.text = "access.token.form.seconds".localized()

        environmentLabel.text = "access.token.form.environment".localized()
        environmentTextField.loadDropDownData(Environment.allCases.map { "\($0)".uppercased() })

        intervalLabel.text = "access.token.form.interval".localized()
        intervalTextField.loadDropDownData(IntervalToExpire.allCases.map { $0.rawValue.uppercased() })
    }

    // MARK: - Actions

    @IBAction private func onCloseAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        let interval: IntervalToExpire = IntervalToExpire(rawValue: intervalTextField.text ?? .empty) ?? .week
        let environment: Environment = environmentTextField.text?.lowercased() == "test" ? .test : .production

        let form = AccessTokenForm(
            appId: appIdTextField.text ?? .empty,
            appKey: appKeyTextField.text ?? .empty,
            secondsToExpire: Int(secondsTextField.text ?? .empty),
            environment: environment,
            interval: interval
        )

        delegate?.onComletedForm(form: form)
        dismiss(animated: true, completion: nil)
    }
}
