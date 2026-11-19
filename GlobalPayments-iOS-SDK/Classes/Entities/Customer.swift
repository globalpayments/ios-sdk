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
    public var status: String?
    /// Customer's primary phone number
    public var phoneNumber: PhoneNumber?
    /// List of documents associated with the customer (e.g., ID, proof of address).
    public var documents: [CustomerDocument]?
    /// Customer's existing payment methods
    public var paymentMethods: [RecurringPaymentMethod]?
    ///Customer's preferred language code (e.g., "en-US", "fr-FR").
    public var language: String?
    /// Indicates if the shipping address is the same as the billing address
    public var isShippingAddressSameAsBilling: Bool?
    /// Time the payer was created (`time_created`).
    public var timeCreated: Date?
    /// Time the payer was last updated (`time_last_updated`).
    public var timeLastUpdated: Date?
    /// Merchant identifier the payer belongs to (`merchant_id`).
    public var merchantId: String?
    /// Merchant name the payer belongs to (`merchant_name`).
    public var merchantName: String?
    /// Tokenization account identifier (`account_id`).
    public var accountId: String?
    /// Tokenization account name (`account_name`).
    public var accountName: String?
    /// Action performed by the gateway for the last request (`action`).
    public var action: Action?

    /// Retrieves a single payer by its id.
    /// - Parameters:
    ///   - id: Payer id (`PYR_...`).
    ///   - masked: `true` (or `nil`, the gateway default) returns personally identifiable fields masked; `false` returns them unmasked.
    ///   - configName: Configuration to use.
    ///   - completion: The payer or the error.
    public static func get(id: String,
                           masked: Bool? = nil,
                           configName: String = "default",
                           completion: ((Customer?, Error?) -> Void)?) {
        let customer = Customer()
        customer.id = id
        RecurringBuilder<Customer>(type: .fetch, entity: customer)
            .withMasked(masked)
            .execute(configName: configName, completion: completion)
    }

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
    
    /// Adds a stored payment method to the payer.
    /// - Parameters:
    ///   - paymentId: The stored payment method id (`PMT_...`)
    ///   - paymentMethod: The payment method
    ///   - isDefault: Marks the payment method as the payer's default (`default: YES`).
    ///     When no payment method is flagged as default, the first one is sent as default.
    public func addRecurringPaymentMethod(paymentId: String?,
                                          paymentMethod: PaymentMethod,
                                          isDefault: Bool? = nil) {
        if paymentMethods.isNilOrEmpty {
            paymentMethods = []
        }
        
        let recurringPaymentMethod = RecurringPaymentMethod()
        recurringPaymentMethod.id = paymentId
        recurringPaymentMethod.paymentMethod = paymentMethod
        recurringPaymentMethod.preferredPayment = isDefault
        paymentMethods?.append(recurringPaymentMethod)
    }
}

extension Customer: JsonToObject {
    
    public static func mapToObject<T>(_ doc: JsonDoc) -> T? {
        let payer = Customer()
        payer.id = doc.getValue(key: "id")
        payer.key = doc.getValue(key: "reference")
        payer.firstName = doc.getValue(key: "first_name")
        payer.lastName = doc.getValue(key: "last_name")
        payer.email = doc.getValue(key: "email")
        payer.language = doc.getValue(key: "language")
        payer.merchantId = doc.getValue(key: "merchant_id")
        payer.merchantName = doc.getValue(key: "merchant_name")
        payer.accountId = doc.getValue(key: "account_id")
        payer.accountName = doc.getValue(key: "account_name")
        payer.status = doc.getValue(key: "status")

        let timeCreated: String? = doc.getValue(key: "time_created")
        payer.timeCreated = timeCreated?.format()
        let timeLastUpdated: String? = doc.getValue(key: "time_last_updated")
        payer.timeLastUpdated = timeLastUpdated?.format()
        
        var paymentDocs: [JsonDoc?]? = doc.getValue(key: "payment_methods")
        if paymentDocs == nil, let single = doc.get(valueFor: "payment_methods") {
            // The list response returns a single payment method object instead of an array.
            paymentDocs = [single]
        }
        if let payments = paymentDocs {
            payer.paymentMethods = payments.map({
                let paymentMethod = RecurringPaymentMethod()
                paymentMethod.id = $0?.getValue(key: "id")
                let isDefault: String? = $0?.getValue(key: "default")
                paymentMethod.key = isDefault
                paymentMethod.preferredPayment = isDefault.map { $0.uppercased() == "YES" }
                return paymentMethod
            })
        }
        
        if let actionDoc = doc.get(valueFor: "action") {
            let action = Action()
            action.Id = actionDoc.getValue(key: "id")
            action.Type = actionDoc.getValue(key: "type")
            action.TimeCreated = actionDoc.getValue(key: "time_created")
            action.ResultCode = actionDoc.getValue(key: "result_code")
            action.AppId = actionDoc.getValue(key: "app_id")
            action.AppName = actionDoc.getValue(key: "app_name")
            payer.action = action
        }
        return payer as? T
    }
}
