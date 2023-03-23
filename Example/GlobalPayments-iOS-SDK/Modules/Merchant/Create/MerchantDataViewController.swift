import UIKit
import GlobalPayments_iOS_SDK

protocol MerchantDataDelegate: AnyObject {
    func onSubmitMerchant(_ user: UserPersonalData)
}

final class MerchantDataViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "Merchant"
    
    weak var delegate: MerchantDataDelegate?
    var viewModel: MerchantDataViewInput!
    
    @IBOutlet weak var textFieldUserName: UITextField!
    @IBOutlet weak var textFieldLegalName: UITextField!
    @IBOutlet weak var textFieldDba: UITextField!
    @IBOutlet weak var textFieldMerchantCategory: UITextField!
    @IBOutlet weak var textFieldWebsite: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldCurrency: UITextField!
    @IBOutlet weak var textFieldTaxIdRef: UITextField!
    @IBOutlet weak var textFieldBusinessAddress: UITextField!
    @IBOutlet weak var textFieldShippingAddress: UITextField!
    
    @IBOutlet weak var buttonCreateMerchant: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "merchant.data.title".localized()
        hideKeyboardWhenTappedAround()
        
        buttonCreateMerchant.apply(style: .globalPayStyle, title: "merchant.create.title".localized())
        
        textFieldBusinessAddress.addTarget(self, action: #selector(businessAddressAction), for: .touchDown)
        textFieldShippingAddress.addTarget(self, action: #selector(shippingAddressAction), for: .touchDown)
        
        addMockData()
    }
    
    private func addMockData() {
        textFieldUserName.text = "CERT_Propay_\(Date())"
        textFieldLegalName.text = "Business Legal Name"
        textFieldDba.text = "Doing Business As"
        textFieldMerchantCategory.text = "5999"
        textFieldWebsite.text = "https://example.com/"
        textFieldEmail.text = "merchant@example.com"
        textFieldCurrency.text = "USD"
        textFieldTaxIdRef.text = "123456789"
    }
    
    @objc func businessAddressAction(textField: UITextField) {
        let viewController = MerchantAddressBuilder.build(delegate: self, path: .business)
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    @objc func shippingAddressAction(textField: UITextField) {
        let viewController = MerchantAddressBuilder.build(delegate: self, path: .shipping)
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func createMerchantAction(_ sender: Any) {
        let merchantData = UserPersonalData()
        merchantData.userName = textFieldUserName.text
        merchantData.legalName = textFieldLegalName.text
        merchantData.DBA = textFieldDba.text
        merchantData.merchantCategoryCode = Int(textFieldMerchantCategory.text ?? "0")
        merchantData.website = textFieldWebsite.text
        merchantData.notificationEmail = textFieldEmail.text
        merchantData.currencyCode = textFieldCurrency.text
        merchantData.taxIdReference = textFieldTaxIdRef.text
        merchantData.tier = "test"
        merchantData.type = .merchant
        viewModel.setMailingAndUserAddress(merchantData)
    }
}

extension MerchantDataViewController: MerchantAddressDelegate {
    
    func onSubmitAddress(address: Address, path: MerchantAddressPath) {
        viewModel.setAddress(address, path: path)
    }
}

extension MerchantDataViewController: MerchantDataViewOutput {
    
    func onSubmitCreateMerchant(_ user: UserPersonalData) {
        delegate?.onSubmitMerchant(user)
        navigationController?.popViewController(animated: true)
    }
    
    func setShippingAddress(_ value: String) {
        textFieldShippingAddress.text = value
    }
    
    func setBusinessAddress(_ value: String) {
        textFieldBusinessAddress.text = value
    }
}
