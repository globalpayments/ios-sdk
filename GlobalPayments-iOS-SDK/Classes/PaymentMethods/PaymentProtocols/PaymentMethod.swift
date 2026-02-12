import Foundation

public protocol PaymentMethod: NSObject {
    var paymentMethodType: PaymentMethodType { get set }
}

public class CommercialPaymentMethod: NSObject {
    public var firstName: String
    public var lastName: String
    public var card: CommercialCard?

    public init(firstName: String, lastName: String, card: CommercialCard?) {
        self.firstName = firstName
        self.lastName = lastName
        self.card = card
    }
}

public class CommercialCard: NSObject {
    public var category: String
    public var avsPostalCode: String

    public init(category: String, avsPostalCode: String) {
        self.category = category
        self.avsPostalCode = avsPostalCode
    }
}
