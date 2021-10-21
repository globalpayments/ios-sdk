import UIKit
import GlobalPayments_iOS_SDK

protocol ConfigurationViewDelegate: AnyObject {
    func onUpdateConfiguration()
}

final class ConfigurationViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Configuration"

    var viewModel: ConfigurationViewInput!

    weak var delegate: ConfigurationViewDelegate?

    @IBOutlet private weak var appIdTextField: UITextField!
    @IBOutlet private weak var appKeyTextField: UITextField!
    @IBOutlet private weak var secondsToExpireTextField: UITextField!
    @IBOutlet private weak var intervalToExpireTextField: UITextField!
    @IBOutlet private weak var channelTextField: UITextField!
    @IBOutlet private weak var languageTextField: UITextField!
    @IBOutlet private weak var countryTextField: UITextField!
    @IBOutlet private weak var challengeNotificationUrlTextField: UITextField!
    @IBOutlet private weak var methodNotificationUrlTextField: UITextField!
    @IBOutlet private weak var merchantContactUrlTextField: UITextField!
    @IBOutlet private weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        viewModel.onViewDidLoad()
    }

    private func setupUI() {
        title = "configuration.title".localized()
        appIdTextField.placeholder = "configuration.app.id".localized()
        appKeyTextField.placeholder = "configuration.app.key".localized()
        secondsToExpireTextField.placeholder = "configuration.seconds.to.expire".localized()
        intervalToExpireTextField.placeholder = "configuration.interval.to.expire".localized()
        intervalToExpireTextField.loadDropDownData(IntervalToExpire.allCases.map { $0.rawValue.uppercased() })
        intervalToExpireTextField.text = nil
        channelTextField.placeholder = "configuration.channel".localized()
        channelTextField.loadDropDownData(Channel.allCases.map { $0.rawValue.uppercased() })
        channelTextField.text = nil
        languageTextField.placeholder = "configuration.language".localized()
        languageTextField.loadDropDownData(Language.allCases.map { $0.rawValue.uppercased() })
        languageTextField.text = nil
        countryTextField.placeholder = "configuration.country".localized()
        countryTextField.loadDropDownData(CountryUtils.ISOCountryInfo.allCountries.map({ $0.alpha2}))
        saveButton.apply(style: .globalPayStyle, title: "configuration.save".localized())
        challengeNotificationUrlTextField.placeholder = "configuration.challenge.notification.url".localized()
        methodNotificationUrlTextField.placeholder = "configuration.method.notification.url".localized()
        merchantContactUrlTextField.placeholder = "configuration.merchant.contact.url".localized()

        hideKeyboardWhenTappedAround()
    }

    // MARK: - Actions

    @IBAction private func onSaveAction() {
        guard let appId = appIdTextField.text, !appId.isEmpty else {
            showAlert(message: "configuration.app.id.message".localized())
            return
        }
        guard let appKey = appKeyTextField.text, !appKey.isEmpty else {
            showAlert(message: "configuration.app.key.message".localized())
            return
        }
        guard let channel = Channel(value: channelTextField.text) else {
            showAlert(message: "configuration.channel.message".localized())
            return
        }
        let secondsToExpire = (secondsToExpireTextField.text != nil && !secondsToExpireTextField.text!.isEmpty) ? Int(secondsToExpireTextField.text!) : nil
        let country = (countryTextField.text != nil && !countryTextField.text!.isEmpty) ? countryTextField.text : nil
        let config = Config(
            appId: appId,
            appKey: appKey,
            secondsToExpire: secondsToExpire,
            intervalToExpire: IntervalToExpire(value: intervalToExpireTextField.text),
            channel: channel,
            language: Language(value: languageTextField.text),
            country: country,
            challengeNotificationUrl: challengeNotificationUrlTextField.text,
            methodNotificationUrl: methodNotificationUrlTextField.text,
            merchantContactUrl: merchantContactUrlTextField.text
        )
        viewModel.saveConfig(config)
    }
}

// MARK: - ConfigurationViewOutput

extension ConfigurationViewController: ConfigurationViewOutput {

    func displayConfig(_ config: Config) {
        appIdTextField.text = config.appId
        appKeyTextField.text = config.appKey
        if let secondsToExpire = config.secondsToExpire {
            secondsToExpireTextField.text = String(secondsToExpire)
        }
        intervalToExpireTextField.text = config.intervalToExpire?.mapped(for: .gpApi)?.uppercased()
        channelTextField.text = config.channel.mapped(for: .gpApi)?.uppercased()
        languageTextField.text = config.language?.mapped(for: .gpApi)?.uppercased()
        countryTextField.text = config.country
        challengeNotificationUrlTextField.text = config.challengeNotificationUrl
        methodNotificationUrlTextField.text = config.methodNotificationUrl
        merchantContactUrlTextField.text = config.merchantContactUrl
    }

    func displayError(_ error: Error) {
        showAlert(message: error.localizedDescription)
    }

    func closeModule() {
        delegate?.onUpdateConfiguration()
        dismiss(animated: true, completion: nil)
    }
}
