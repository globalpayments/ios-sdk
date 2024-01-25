import Foundation
import GlobalPayments_iOS_SDK

final class BuyNowPayLaterViewModel: BaseViewModel {
    
    var showProductsScreen: Dynamic<[Product]?> = Dynamic(nil)
    var setProductLabel: Dynamic<String> = Dynamic("")
    var setBillingLabel: Dynamic<String> = Dynamic("")
    var setShippingLabel: Dynamic<String> = Dynamic("")
    var setCustomerLabel: Dynamic<String> = Dynamic("")
    var showAddressScreen: Dynamic<MerchantAddressPath> = Dynamic(.business)
    var showCustomerScreen: Dynamic<Customer> = Dynamic(Customer())
    var openUrl: Dynamic<(URL, String)> = Dynamic((URL(fileURLWithPath: ""), ""))
    var enableButton: Dynamic<Bool> = Dynamic(false)
    
    var selectedProducts: [Product]? = []
    private var amount: NSDecimalNumber = 0.0
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
        let customerName = "\(customer.firstName ?? "") \(customer.lastName ?? "")"
        setCustomerLabel.value = customerName
        setProducts(products)
    }
    
    func setAddress(_ address: Address, path: MerchantAddressPath) {
        let value = "\(address.streetAddress1 ?? "")"
        switch path {
        case .business:
            businessAddress = address
            setBillingLabel.value = value
        case .shipping:
            shippingAddress = address
            setShippingLabel.value = value
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
        setProductLabel.value = label
    }
    
    func setCustomerData(_ data: Customer?) {
        if let data = data {
            customer = data
            let customerName = "\(customer.firstName ?? "") \(customer.lastName ?? "")"
            setCustomerLabel.value = customerName
        }
    }
    
    func onBnplAction() {
        showLoading.executer()
        if products.isEmpty {
            self.showDataResponse.value = (.error, GatewayException(message: "buyNowPayLater.error.products.message".localized()))
            return
        }
        let paymentMethod = BNPL()
        paymentMethod.BNPLType = typeBnlpCustomer
        paymentMethod.returnUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.statusUpdateUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.cancelUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        
        guard let shippingAddress = shippingAddress, let businessAddress = businessAddress else { return }
        
        paymentMethod.authorize(amount: amount)
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
                if let error = error as? GatewayException {
                    self.showDataResponse.value = (.error, error)
                }
                return
            }
            
            if let urlMerchant = transaction.bnplResponse?.redirectUrl, let url = URL(string: urlMerchant), let transactionId = transaction.transactionId {
                self.openUrl.value = (url, transactionId)
            }
        }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .amount:
            amount = NSDecimalNumber(string: value)
        case .accountType:
            typeBnlpCustomer = BNPLType(value: value) ?? .AFFIRM
        case .countryCode:
            countryCode = value
        case .phoneNumber:
            phoneNumber = value
        case .phoneType:
            typeAddress = PhoneNumberType(value: value) ?? .Home
        default:
            break
        }
    }
    
    func onProductsPressed() {
        showProductsScreen.value = selectedProducts
    }
    
    func onBillingAddressPressed() {
        showAddressScreen.value = .business
    }
    
    func onShippingAddressPressed() {
        showAddressScreen.value = .shipping
    }
    
    func onCustomerPressed() {
        showCustomerScreen.value = customer
    }
}
