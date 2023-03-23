import UIKit
import GlobalPayments_iOS_SDK

final class CreateMerchantViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "Merchant"
    
    var viewModel: CreateMerchantViewInput!
    
    @IBOutlet weak var textFieldMerchantData: UITextField!
    @IBOutlet weak var textFieldProducts: UITextField!
    @IBOutlet weak var textFieldPaymentStatistics: UITextField!
    @IBOutlet weak var buttonCreateMerchant: UIButton!
    @IBOutlet private weak var supportView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "merchant.create.title".localized()
        hideKeyboardWhenTappedAround()
        
        buttonCreateMerchant.apply(style: .globalPayStyle, title: "merchant.create.title".localized())
        textFieldMerchantData.addTarget(self, action: #selector(merchantDataAction), for: .touchDown)
        textFieldProducts.addTarget(self, action: #selector(merchantProductsAction), for: .touchDown)
        textFieldPaymentStatistics.addTarget(self, action: #selector(merchantStatisticsAction), for: .touchDown)
        activityIndicator.stopAnimating()
    }
    
    @objc func merchantDataAction(textField: UITextField) {
        let viewController = MerchantDataBuilder.build(self)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func merchantProductsAction(textField: UITextField) {
        let viewController = MerchantProductsBuilder.build(self)
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    @objc func merchantStatisticsAction(textField: UITextField) {
        let viewController = MerchantStatisticsBuilder.build(self)
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    
    @IBAction func createMerchantAction(_ sender: Any) {
        activityIndicator.startAnimating()
        viewModel.createMerchant()
        supportView.clearSubviews()
    }
}

extension CreateMerchantViewController: MerchantDataDelegate {
    
    func onSubmitMerchant(_ user: UserPersonalData) {
        self.viewModel.setUser(user)
        textFieldMerchantData.text = user.userName
    }
}

extension CreateMerchantViewController: MerchantStatisticsDelegate {
    
    func onSubmitStatistics(statistics: PaymentStatistics) {
        self.viewModel.setStatistics(statistics)
        textFieldPaymentStatistics.text = "\(statistics.totalMonthlySalesAmount ?? 0)|\(statistics.averageTicketSalesAmount ?? 0)|\(statistics.highestTicketSalesAmount ?? 0)"
    }
}

extension CreateMerchantViewController: MerchantProductsDelegate {
    func onSubmitProducts(products: [Product]) {
        self.viewModel.setProducts(products)
        var labelProducts = "["
        products.forEach { labelProducts += " \($0.productId ?? "")," }
        labelProducts += "]"
        textFieldProducts.text = labelProducts
    }
}

extension CreateMerchantViewController: CreateMerchantViewOutput {
    
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
