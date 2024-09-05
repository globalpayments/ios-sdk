import Foundation

/// A customer resource. Mostly used in recurring scenarios.
public class Customer: RecurringEntity<Customer> {
    /// Customer's title
    var title: String?
    /// Customer's first name
    public var firstName: String?
    /// Customer's last name
    public var lastName: String?
    /// Customer's company
    var company: String?
    /// Customer's password
    var customerPassword: String?
    /// Customer's date of birth
    public var dateOfBirth: String?
    /// Customer's domain name
    var domainName: String?
    /// Customer's device finger print
    public var deviceFingerPrint: String?
    /// Customer's address
    public var address: Address?
    /// Customer's home phone number
    public var homePhone: String?
    /// Customer's work phone number
    var workPhone: String?
    /// Customer's fax phone number
    var fax: String?
    /// Customer's mobile phone number
    public var mobilePhone: String?
    /// Customer's email address
    public var email: String?
    /// Customer comments
    var comments: String?
    /// Customer's department within its organization
    var department: String?
    /// Customer resource's status
    var status: String?
    
    public var phoneNumber: PhoneNumber?
    
    public var documents: [CustomerDocument]?
    
    public var paymentMethods: [RecurringPaymentMethod]?

    /// Adds a payment method to the customer
    /// - Parameters:
    ///   - paymentId: An application derived ID for the payment method
    ///   - paymentMethod: The payment method
    /// - Returns: RecurringPaymentMethod
    public func addPaymentMethod(paymentId: String?,
                                 paymentMethod: PaymentMethod) -> RecurringPaymentMethod {

        var nameOnAccount = "\(firstName ?? .empty) \(lastName ?? .empty)"
            .replacingOccurrences(of: "", with: String.empty)
        if nameOnAccount.isEmpty {
            nameOnAccount = company ?? .empty
        }
        
        let payment = RecurringPaymentMethod()
        payment.address = address
        payment.customerKey = key
        payment.id = paymentId
        payment.nameOnAccount = nameOnAccount

        return payment
    }
    
    public func addRecurringPaymentMethod(paymentId: String?, paymentMethod: PaymentMethod) {
        if paymentMethods.isNilOrEmpty {
            paymentMethods = []
        }
        
        let paymentMethod = RecurringPaymentMethod()
        paymentMethod.id = paymentId
        paymentMethod.paymentMethod = paymentMethod
        paymentMethods?.append(paymentMethod)
    }
}

extension Customer: JsonToObject {
    
    public static func mapToObject<T>(_ doc: JsonDoc) -> T? {
        let payer = Customer()
        payer.id = doc.getValue(key: "id")
        payer.key = doc.getValue(key: "reference")
        payer.firstName = doc.getValue(key: "first_name")
        payer.lastName = doc.getValue(key: "last_name")
        
        if let payments: [JsonDoc?] = doc.getValue(key: "payment_methods") {
            payer.paymentMethods = payments.map({
                let paymentMethod = RecurringPaymentMethod()
                paymentMethod.id = $0?.getValue(key: "id")
                paymentMethod.key = $0?.getValue(key: "default")
                return paymentMethod
            })
        }
        return payer as? T
    }
}
