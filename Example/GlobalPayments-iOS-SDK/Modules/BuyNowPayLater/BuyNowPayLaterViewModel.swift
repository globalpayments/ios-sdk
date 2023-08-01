import Foundation
import GlobalPayments_iOS_SDK

protocol BuyNowPayLaterViewInput {
    func setAddress(_ address: Address, path: MerchantAddressPath)
    func setMockData()
    func setCustomerData(_ data: Customer?)
    func setType(_ value: String)
    func setTypeAddress(_ value: String)
    func setProducts(_ value: [Product])
    func showCustomerScreen()
    func onBnplAction(_ amount: String)
    var selectedProducts: [Product]? { get set }
}

protocol BuyNowPayLaterViewOutput: AnyObject{
    func showErrorView(error: Error?)
    func showUrlOpen(_ url: URL, transactionId: String)
    func setShippingAddress(_ value: String)
    func setBusinessAddress(_ value: String)
    func setCountryCode(_ value: String)
    func setPhoneNumber(_ value: String)
    func setCustomer(_ value: String)
    func setProducts(_ value: String)
    func showCustomerScreen(_ data: Customer?)
    func showProductsEmptyError(_ value: String)
}

final class BuyNowPayLaterViewModel: BuyNowPayLaterViewInput {
    
    var selectedProducts: [Product]? = []
    weak var view: BuyNowPayLaterViewOutput?
    private var shippingAddress: Address?
    private var businessAddress: Address?
    private var countryCode: String = "1"
    private var phoneNumber: String = "7708298000"
    private var products: [Product] = []
    private let CURRENCY = "USD"
    private var typeBnlpCustomer: BNPLType = .AFFIRM
    private var typeAddress: PhoneNumberType = .Shipping
    
    private lazy var customer: Customer = {
        let customer = Customer()
        customer.id = "12345678"
        customer.firstName = "James"
        customer.lastName = "Mason"
        customer.email = "james.mason@example.com"
        
        let phoneNumber = PhoneNumber()
        phoneNumber.countryCode = "1"
        phoneNumber.number = "7708298000"
        phoneNumber.areaCode = PhoneNumberType.Home.mapped(for: .gpApi)
        customer.phoneNumber = phoneNumber
        
        let customerDocument = CustomerDocument()
        customerDocument.reference = "123456789"
        customerDocument.issuer = "US"
        customerDocument.type = CustomerDocumentType.PASSPORT
        var documents: [CustomerDocument] = []
        documents.append(customerDocument)
        customer.documents = documents
        return customer
    }()
    
    func setMockData() {
        setAddress(createEmptyAddress(), path: .business)
        setAddress(createEmptyAddress(), path: .shipping)
        view?.setCountryCode("\(countryCode)")
        view?.setPhoneNumber(phoneNumber)
        let customerName = "\(customer.firstName ?? "") \(customer.lastName ?? "")"
        view?.setCustomer(customerName)
        setProducts(products)
    }
    
    func setAddress(_ address: Address, path: MerchantAddressPath) {
        let value = "\(address.streetAddress1 ?? "")"
        switch path {
        case .business:
            businessAddress = address
            view?.setBusinessAddress(value)
        case .shipping:
            shippingAddress = address
            view?.setShippingAddress(value)
        }
    }
    
    func setType(_ value: String) {
        typeBnlpCustomer = BNPLType(value: value) ?? .AFFIRM
    }
    
    func setTypeAddress(_ value: String) {
        typeAddress = PhoneNumberType(value: value) ?? .Shipping
    }
    
    func setProducts(_ value: [Product]) {
        products = value
        let labelProducts = products.count == 1 ? "product" : "products"
        let label = "\(products.count) \(labelProducts) selected"
        view?.setProducts(label)
    }
    
    func showCustomerScreen() {
        view?.showCustomerScreen(customer)
    }
    
    func setCustomerData(_ data: Customer?) {
        if let data = data {
            customer = data
            let customerName = "\(customer.firstName ?? "") \(customer.lastName ?? "")"
            view?.setCustomer(customerName)
        }
    }
    
    func onBnplAction(_ amount: String) {
        if products.isEmpty {
            view?.showProductsEmptyError("buyNowPayLater.error.products.message")
            return
        }
        let paymentMethod = BNPL()
        paymentMethod.BNPLType = typeBnlpCustomer
        paymentMethod.returnUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.statusUpdateUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.cancelUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        
        guard let shippingAddress = shippingAddress, let businessAddress = businessAddress else { return }
        
        paymentMethod.authorize(amount: NSDecimalNumber(string: amount))
            .withCurrency(CURRENCY)
            .withMiscProductData(products)
            .withAddress(shippingAddress, type: .shipping)
            .withAddress(businessAddress, type: .billing)
            .withPhoneNumber(countryCode, number: phoneNumber, type: typeAddress)
            .withCustomerData(customer)
            .withBNPLShippingMethod(.DELIVERY)
            .execute(completion: showOutput)
    }
    
    private func createEmptyAddress() -> Address {
        let address = Address()
        address.streetAddress1 = "Apartment 852"
        address.streetAddress2 = "Complex 741"
        address.streetAddress3 = "no"
        address.city = "Birmingham"
        address.postalCode = "50001"
        address.countryCode = "US"
        address.state = "IL"
        return address
    }
    
    private func showOutput(transaction: Transaction?, error: Error?) {
        UI {
            guard let transaction = transaction else {
                self.view?.showErrorView(error: error)
                return
            }
            
            if let urlMerchant = transaction.bnplResponse?.redirectUrl, let url = URL(string: urlMerchant), let transactionId = transaction.transactionId {
                self.view?.showUrlOpen(url, transactionId: transactionId)
            }
        }
    }
}
