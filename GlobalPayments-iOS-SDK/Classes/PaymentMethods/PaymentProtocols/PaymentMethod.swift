import Foundation

public protocol PaymentMethod: NSObject {
    var paymentMethodType: PaymentMethodType { get set }
}

public class CommercialPaymentMethod: NSObject {
    public var firstName: String
    public var lastName: String
    public var entryMethod: EntryMethod?
    public var card: CommercialCard?

    public init(firstName: String, lastName: String, entryMethod: EntryMethod?, card: CommercialCard?) {
        self.firstName = firstName
        self.lastName = lastName
        self.card = card
        self.entryMethod = entryMethod
    }
}

public class CommercialCard: NSObject {
    public var category: String
    public var avsPostalCode: String
    public var track: String?
    public var trackNumber: String?

    public init(category: String, avsPostalCode: String, track: String?, trackNumber: String? = nil) {
        self.category = category
        self.track = track
        self.avsPostalCode = avsPostalCode
        self.trackNumber = trackNumber
    }
}
