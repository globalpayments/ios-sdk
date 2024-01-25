import UIKit
import GlobalPayments_iOS_SDK

protocol MerchantAddressDelegate: AnyObject {
    func onSubmitAddress(address: Address, path: MerchantAddressPath)
}

final class MerchantAddressViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "Merchant"
    
    weak var delegate: MerchantAddressDelegate?
    var path: MerchantAddressPath = .business
    
    @IBOutlet weak var textFieldStreet1: UITextField!
    @IBOutlet weak var textFieldStreet2: UITextField!
    @IBOutlet weak var textFieldStreet3: UITextField!
    @IBOutlet weak var textFieldCity: UITextField!
    @IBOutlet weak var textFieldState: UITextField!
    @IBOutlet weak var textFieldPostalCode: UITextField!
    @IBOutlet weak var textFieldCountryCode: UITextField!
    
    @IBOutlet weak var buttonCreateAddress: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "merchant.address.title".localized()
        hideKeyboardWhenTappedAround()
        buttonCreateAddress.applyFlat(style: .redesignStyle, title: "merchant.create.address.label".localized())
        addMockData()
    }
    
    private func addMockData() {
        textFieldStreet1.text = "Apartment 9123"
        textFieldStreet2.text = "Complex 890"
        textFieldStreet3.text = "Unit 9"
        textFieldCity.text = "Chicago"
        textFieldState.text = "IL"
        textFieldPostalCode.text = "50001"
        textFieldCountryCode.text = "840"
    }
    
    @IBAction func createMerchantAddressAction(_ sender: Any) {
        let address = Address()
        address.streetAddress1 = textFieldStreet1.text
        address.streetAddress2 = textFieldStreet2.text
        address.streetAddress3 = textFieldStreet3.text
        address.city = textFieldCity.text
        address.state = textFieldState.text
        address.postalCode = textFieldPostalCode.text
        address.countryCode = textFieldCountryCode.text
        delegate?.onSubmitAddress(address: address, path: path)
        dismiss(animated: true, completion: nil)
    }
}
