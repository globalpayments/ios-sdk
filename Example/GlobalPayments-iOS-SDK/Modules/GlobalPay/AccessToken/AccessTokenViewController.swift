import UIKit
import GlobalPayments_iOS_SDK

final class AccessTokenViewController: UIViewController, StoryboardInstantiable {

    static let storyboardName = "AccessToken"

    var viewModel: AccessTokenInput!

    @IBOutlet private weak var createTokenButton: UIButton!
    @IBOutlet private weak var supportView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "access.token.title".localized()
        createTokenButton.setTitle("access.token.create".localized(), for: .normal)
        createTokenButton.apply(style: .globalPayStyle)
        activityIndicator.stopAnimating()
    }

    @IBAction func onCreateToken() {
        let form = AccessTokenFormBuilder.build(delegate: self)
        navigationController?.present(form, animated: true, completion: nil)
    }
}

// MARK: - AccessTokenOutput

extension AccessTokenViewController: AccessTokenOutput {

    func showTokenView(token: AccessTokenInfo) {
        activityIndicator.stopAnimating()
        let tokenView = AccessTokenView.instantiateFromNib()
        tokenView.setTokenInfo(token)
        supportView.addSubview(tokenView)
        tokenView.bindFrameToSuperviewBounds()
    }

    func showErrorView(error: Error?) {
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        supportView.addSubview(errorView)
        errorView.bindFrameToSuperviewBounds()
    }
}

// MARK: - AccessTokenFormDelegate

extension AccessTokenViewController: AccessTokenFormDelegate {

    func onComletedForm(form: AccessTokenForm) {
        activityIndicator.startAnimating()
        viewModel.createToken(from: form)
        supportView.clearSubviews()
    }
}
