import Foundation

public class FundsAccountDetails {
    
    public var id: String?
    public var status: String?
    public var timeCreated: String?
    public var timeLastUpdated: String?
    public var amount: NSDecimalNumber?
    public var reference: String?
    public var description: String?
    public var currency: String?
    public var paymentMethodType: String?
    public var paymentMethodName: String?
    public var account: UserAccount?
}

extension FundsAccountDetails: JsonToObject {
    
    public static func mapToObject<T>(_ doc: JsonDoc) -> T? {
        let transfer = FundsAccountDetails()
        transfer.id = doc.getValue(key: "id")
        transfer.status = doc.getValue(key: "status")
        transfer.timeCreated = doc.getValue(key: "time_created")
        if let amount: String = doc.getValue(key: "amount") {
            transfer.amount = NSDecimalNumber(string: amount).amount
        }
        transfer.reference = doc.getValue(key: "reference")
        transfer.description = doc.getValue(key: "description")
        return transfer as? T
    }
}
