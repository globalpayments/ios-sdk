import UIKit
import GlobalPayments_iOS_SDK

protocol CustomerDelegate: AnyObject {
    func onSubmitCustomer(_ data: Customer)
}

final class CustomerViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "Customer"
    
    var viewModel: CustomerViewInput!
    var delegate: CustomerDelegate?
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var numberPhoneTextField: UITextField!
    @IBOutlet weak var typeNumberTextField: UITextField!
    @IBOutlet weak var issuerTextField: UITextField!
    @IBOutlet weak var documentReferenceTextField: UITextField!
    @IBOutlet weak var documentTypeTextField: UITextField!
    @IBOutlet weak var createCustomerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        hideKeyboardWhenTappedAround()
        createCustomerButton.applyFlat(style: .redesignStyle, title: "customer.create.title.button".localized())
        
        typeNumberTextField.loadDropDownData(PhoneNumberType.allCases.map { $0.mapped(for: .gpApi) ?? .empty}, onSelectItem: onPhoneNumberType)
        documentTypeTextField.loadDropDownData(CustomerDocumentType.allCases.map { $0.mapped(for: .gpApi) ?? .empty}, onSelectItem: onDocumentType)
        viewModel.setCustomerData()
    }
    
    private func onPhoneNumberType(_ type: String) {
        typeNumberTextField.text = type
    }
    
    private func onDocumentType(_ type: String) {
        documentTypeTextField.text = type
    }
    
    @IBAction func onCreateCustomerAction(_ sender: Any) {
        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let email = emailTextField.text,
              let countryCode = countryCodeTextField.text,
              let numberPhone = numberPhoneTextField.text,
              let numberType = typeNumberTextField.text,
              let issuer = issuerTextField.text,
              let documentReference = documentReferenceTextField.text,
              let documentType = documentTypeTextField.text else { return }
        viewModel.createCustomerData(
            CustomerForm(
                firstName: firstName,
                lastName: lastName,
                email: email,
                countryCode: countryCode,
                numberPhone: numberPhone,
                numberType: numberType,
                issuer: issuer,
                documentReference: documentReference,
                documentType: documentType
            )
        )
    }
}

extension CustomerViewController: CustomerViewOutput {
    
    func showDefaultData(_ data: Customer) {
        firstNameTextField.text = data.firstName
        lastNameTextField.text = data.lastName
        emailTextField.text = data.email
        
        countryCodeTextField.text = data.phoneNumber?.countryCode
        numberPhoneTextField.text = data.phoneNumber?.number
        typeNumberTextField.text = data.phoneNumber?.areaCode
        
        if let document = data.documents?.first {
            issuerTextField.text = document.issuer
            documentReferenceTextField.text = document.reference
            documentTypeTextField.text = document.type?.mapped(for: .gpApi)
        }
    }
    
    func sendCustomerData(_ data: Customer) {
        delegate?.onSubmitCustomer(data)
        dismiss(animated: true)
    }
}
