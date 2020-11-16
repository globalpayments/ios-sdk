import UIKit
import GlobalPayments_iOS_SDK

final class AccessTokenViewController: UIViewController, StoryboardInstantiable {

    static let storyboardName = "GlobalPay"

    lazy fileprivate var accessTokenRouter: AccessTokenRouter = {
        return AccessTokenRouter(navigationController: navigationController)
    }()

    var viewModel: AccessTokenInput!

    @IBOutlet private weak var createTokenButton: UIButton!
    @IBOutlet private weak var supportView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "access.token.title".localized()
        createTokenButton.setTitle("access.token.create".localized(), for: .normal)
        createTokenButton.apply(style: .globalPayStyle)
    }

    @IBAction func onCreateToken() {
        accessTokenRouter.navigate(to: .form(self))
//        viewModel.createToken()
//        supportView.clearSubviews()
    }

    deinit {
        print("AccessTokenViewController deinit")
    }
}

// MARK: - AccessTokenOutput

extension AccessTokenViewController: AccessTokenOutput {

    func showTokenView(token: AccessTokenInfo) {
        let tokenView = AccessTokenView.instantiateFromNib()
        tokenView.setTokenInfo(token)
        supportView.addSubview(tokenView)
    }

    func showErrorView(error: Error?) {

    }
}

// MARK: - AccessTokenFormDelegate

extension AccessTokenViewController: AccessTokenFormDelegate {

    func onComletedForm() {
        print("onComletedForm")
    }

    func onDiscardForm() {
        print("onDiscardForm")
    }
}
