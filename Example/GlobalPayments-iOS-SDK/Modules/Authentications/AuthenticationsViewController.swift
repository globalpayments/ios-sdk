import UIKit
import GlobalPayments_iOS_SDK

final class AuthenticationsViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Authentications"

    var viewModel: AuthenticationsViewModelInput!

    @IBOutlet private weak var checkAvailabilityButton: UIButton!
    @IBOutlet private weak var initiateButton: UIButton!
    @IBOutlet private weak var getResultButton: UIButton!
    @IBOutlet private weak var fullFlowButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var supportView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "authentications.title".localized()
        checkAvailabilityButton.apply(style: .globalPayStyle, title: "authentications.check.availability".localized())
        initiateButton.apply(style: .globalPayStyle, title: "authentications.initiate".localized())
        getResultButton.apply(style: .globalPayStyle, title: "authentications.get.result".localized())
        fullFlowButton.apply(style: .globalPayStyle, title: "authentications.full.flow".localized())
        activityIndicator.stopAnimating()
    }

    // MARK: - Actions

    @IBAction private func onCheckAvailability() {
        let form = CheckAvailabilityFormBuilder.build(with: self)
        navigationController?.present(form, animated: true, completion: nil)
    }

    @IBAction private func onInitiate() {
        let form = InitiateFormBuilder.build(with: self, flowType: .initiate)
        navigationController?.present(form, animated: true, completion: nil)
    }

    @IBAction private func onGetResult() {
        let form = AuthenticationDataFormBuilder.build(with: self)
        navigationController?.present(form, animated: true, completion: nil)
    }

    @IBAction private func onFullFlow() {
        let form = InitiateFormBuilder.build(with: self, flowType: .full)
        navigationController?.present(form, animated: true, completion: nil)
    }
}

// MARK: - AuthenticationsViewModelOutput

extension AuthenticationsViewController: AuthenticationsViewModelOutput {

    func showErrorView(error: Error?) {
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        supportView.addSubview(errorView)
        errorView.bindFrameToSuperviewBounds()
    }

    func showThreeDSecure(_ threeDSecure: ThreeDSecure) {
        activityIndicator.stopAnimating()
        let threeDSecureView = ThreeDSecureView.instantiateFromNib()
        threeDSecureView.display(threeDSecure)
        supportView.addSubview(threeDSecureView)
        threeDSecureView.bindFrameToSuperviewBounds()
    }

    func showTransaction(_ transaction: Transaction) {
        activityIndicator.stopAnimating()
        let transactionView = TransactionView.instantiateFromNib()
        transactionView.display(transaction)
        supportView.addSubview(transactionView)
        transactionView.bindFrameToSuperviewBounds()
    }

    func showChallengeWebView(_ form: InitiateForm, _ threeDSecure: ThreeDSecure) {
        activityIndicator.stopAnimating()
        let acsWebView = ACSWebView.instantiateFromNib()
        supportView.addSubview(acsWebView)
        acsWebView.bindFrameToSuperviewBounds()
        acsWebView.load(form: form, threeDSecure: threeDSecure)
        acsWebView.onFinishChallenge = { [weak self] form, threeDSecure in
            self?.supportView.clearSubviews()
            self?.activityIndicator.startAnimating()
            self?.viewModel?.onFinishChallenge(form: form, threeDSecure: threeDSecure)
        }
    }
}

// MARK: - CheckAvailabilityFormDelegate

extension AuthenticationsViewController: CheckAvailabilityFormDelegate {

    func onSubmitForm(form: CheckAvailabilityForm) {
        supportView.clearSubviews()
        activityIndicator.startAnimating()
        viewModel?.onCheckAvailability(form: form)
    }
}

// MARK: - AuthenticationDataFormDelegate

extension AuthenticationsViewController: AuthenticationDataFormDelegate {

    func onSubmitForm(form: AuthenticationDataForm) {
        supportView.clearSubviews()
        activityIndicator.startAnimating()
        viewModel.onGetResult(form: form)
    }
}

// MARK: - InitiateFormDelegate

extension AuthenticationsViewController: InitiateFormDelegate {

    func onSubmitForm(form: InitiateForm, flowType: FlowType) {
        supportView.clearSubviews()
        activityIndicator.startAnimating()
        switch flowType {
        case .initiate:
            viewModel.onInitiate(form: form)
        case .full:
            viewModel.onFullFlow(form: form)
        }
    }
}
