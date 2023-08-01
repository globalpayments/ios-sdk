import UIKit
import GlobalPayments_iOS_SDK

final class BuyNowPayLaterViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "BuyNowPayLater"
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var productsTextField: UITextField!
    @IBOutlet weak var billingAddressTextField: UITextField!
    @IBOutlet weak var shippingAddressTextField: UITextField!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var typeAddressTextField: UITextField!
    @IBOutlet weak var customerTextField: UITextField!
    @IBOutlet weak var buyNowButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var supportView: UIView!
    var viewModel: BuyNowPayLaterViewInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        hideKeyboardWhenTappedAround()
        title = "buyNowPayLater.title".localized()
        buyNowButton.apply(style: .globalPayStyle, title: "buyNowPayLater.title".localized())
        
        typeTextField.loadDropDownData(BNPLType.allCases.map { $0.mapped(for: .gpApi) ?? .empty}, onSelectItem: onBnplType)
        typeAddressTextField.loadDropDownData(PhoneNumberType.allCases.map { $0.mapped(for: .gpApi) ?? .empty}, onSelectItem: onPhoneType, defaultValue: 2)
        
        billingAddressTextField.addTarget(self, action: #selector(businessAddressAction), for: .touchDown)
        shippingAddressTextField.addTarget(self, action: #selector(shippingAddressAction), for: .touchDown)
        customerTextField.addTarget(self, action: #selector(customerAction), for: .touchDown)
        productsTextField.addTarget(self, action: #selector(selectProductsAction), for: .touchDown)
        viewModel.setMockData()
        activityIndicator.stopAnimating()
    }
    
    private func onBnplType(_ type: String) {
        viewModel.setType(type)
    }
    
    private func onPhoneType(_ type: String) {
        viewModel.setTypeAddress(type)
    }
    
    @objc func businessAddressAction(textField: UITextField) {
        let viewController = MerchantAddressBuilder.build(delegate: self, path: .business)
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    @objc func shippingAddressAction(textField: UITextField) {
        let viewController = MerchantAddressBuilder.build(delegate: self, path: .shipping)
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    @objc func selectProductsAction(textField: UITextField) {
        let viewController = ProductsBuilder.build(self, selectedProducts: viewModel.selectedProducts)
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    @objc func customerAction(textField: UITextField) {
        viewModel.showCustomerScreen()
    }
    
    @IBAction func onBnplAction(_ sender: Any) {
        guard let amount = amountTextField.text, !amount.isEmpty else {
            showAlert(message: "buyNowPayLater.error.amount.message".localized())
            return
        }
        activityIndicator.startAnimating()
        viewModel.onBnplAction(amount)
    }
}

extension BuyNowPayLaterViewController: MerchantAddressDelegate {
    func onSubmitAddress(address: Address, path: MerchantAddressPath) {
        viewModel.setAddress(address, path: path)
    }
}

extension BuyNowPayLaterViewController: BuyNowPayLaterViewOutput {
    
    func setCountryCode(_ value: String) {
        countryCodeTextField.text = value
    }
    
    func setPhoneNumber(_ value: String) {
        phoneNumberTextField.text = value
    }
    
    func setShippingAddress(_ value: String) {
        shippingAddressTextField.text = value
    }
    
    func setBusinessAddress(_ value: String) {
        billingAddressTextField.text = value
    }
    
    func showCustomerScreen(_ data: Customer?) {
        let viewController = CustomerBuilder.build(delegate: self, defaultData: data)
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    func setCustomer(_ value: String) {
        customerTextField.text = value
    }
    
    func setProducts(_ value: String) {
        productsTextField.text = value
    }
    
    func showErrorView(error: Error?) {
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        supportView.addSubview(errorView)
        errorView.bindFrameToSuperviewBounds()
    }
    
    func showProductsEmptyError(_ value: String) {
        activityIndicator.stopAnimating()
        showAlert(message: value.localized())
    }
    
    func showUrlOpen(_ url: URL, transactionId: String) {
        activityIndicator.stopAnimating()
        let viewController = CaptureBnplBuilder.build(transactionId)
        navigationController?.present(viewController, animated: true, completion: nil)
        UIApplication.shared.open(url)
    }
}

extension BuyNowPayLaterViewController: CustomerDelegate {
    
    func onSubmitCustomer(_ data: Customer) {
        viewModel.setCustomerData(data)
    }
}

extension BuyNowPayLaterViewController: ProductsDelegate {
    
    func onSubmitProducts(_ data: [Product]) {
        viewModel.setProducts(data)
    }
}
