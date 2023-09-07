import UIKit
import GlobalPayments_iOS_SDK

final class HostedFieldsViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "HostedFields"

    var viewModel: HostedFieldsViewInput!
    weak var delegate: TokenizedCardDataDelegate?

    @IBOutlet private weak var payButton: UIButton!
    @IBOutlet private weak var supportView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var paymentRecurringRadioButton: RadioButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.onViewDidLoad()
    }

    private func setupUI() {
        title = "globalpay.hosted.fields.title".localized()
        hideKeyboardWhenTappedAround()
        payButton.apply(style: .globalPayStyle, title: "openBanking.fasterPayments.title.button".localized())
        activityIndicator.stopAnimating()
    }
    
    @IBAction func onPayAction(_ sender: Any) {
        supportView.isHidden = true
        activityIndicator.startAnimating()
        viewModel.createToken(paymentRecurringRadioButton.isOn)
    }
    
}

extension HostedFieldsViewController: HostedFieldsViewOutput {
    func showErrorView(error: Error?) {
        supportView.isHidden = false
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        supportView.addSubview(errorView)
        errorView.bindFrameToSuperviewBounds()
    }
    
    func showTransaction(_ transaction: Transaction) {
        supportView.isHidden = false
        activityIndicator.stopAnimating()
        let transactionView = TransactionView.instantiateFromNib()
        transactionView.display(transaction)
        supportView.addSubview(transactionView)
        transactionView.bindFrameToSuperviewBounds()
    }
    
    func tokenGenerated(token: String) {
        activityIndicator.stopAnimating()
        let viewController = HostedFieldsWebViewBuilder.build(token, delegate: self)
        navigationController?.present(viewController, animated: true, completion: nil)
    }
}

extension HostedFieldsViewController: HostedFieldsWebViewOutput {
    func onTokenError() {
        supportView.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    func onTokenizedSuccess(token: String, cardBrand: String) {
        delegate?.tokenizedCard(token: token, cardBrand: cardBrand)
        supportView.isHidden = false
        activityIndicator.stopAnimating()
        dismiss(animated: true, completion: nil)
    }
    
    
    func onSubmitAction() {
        supportView.isHidden = true
        activityIndicator.startAnimating()
    }
}

extension HostedFieldsViewController: TokenizedCardDataDelegate {
    
    func tokenizedCard(token: String, cardBrand: String) {
        activityIndicator.startAnimating()
        viewModel?.checkEnrollment(token, brand: cardBrand)
    }
}
