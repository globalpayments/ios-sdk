import UIKit
import GlobalPayments_iOS_SDK

final class MerchantViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "Merchant"
    
    var viewModel: MerchantViewInput!
    
    @IBOutlet weak var buttonSearch: UIButton!
    @IBOutlet weak var textFieldMerchantId: UITextField!
    @IBOutlet weak var buttonAddMerchant: UIButton!
    
    @IBOutlet weak var supportView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        buttonSearch.apply(style: .globalPayStyle, title: "merchant.search.label".localized())
        buttonAddMerchant.apply(style: .globalPayStyle, title: "merchant.create.title".localized())
        activityIndicator.stopAnimating()
    }

    private func setupUI() {
        title = "merchant.title".localized()
        hideKeyboardWhenTappedAround()
        addMockData()
    }
    
    private func addMockData() {
        textFieldMerchantId.text = "MER_98f60f1a397c4dd7b7167bda61520292"
    }
    
    @IBAction func addMerchantAction(_ sender: Any) {
        let viewController = CreateMerchantBuilder.build()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func searchMerchantAction(_ sender: Any) {
        guard let merchantId = textFieldMerchantId.text, !merchantId.isEmpty  else { return }
        viewModel.findUserById(merchantId)
        activityIndicator.startAnimating()
        supportView.clearSubviews()
    }
}

extension MerchantViewController: MerchantViewOutput {
    
    func showErrorView(error: Error?) {
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        supportView.addSubview(errorView)
        errorView.bindFrameToSuperviewBounds()
    }
    
    func showUser(_ user: User) {
        activityIndicator.stopAnimating()
        let userView = UserView.instantiateFromNib()
        userView.display(user)
        supportView.addSubview(userView)
        userView.bindFrameToSuperviewBounds()
    }
}
