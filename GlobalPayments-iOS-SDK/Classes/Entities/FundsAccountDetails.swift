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
    // split_amount_response fields
    public var merchantId: String?
    public var merchantName: String?
    public var accountId: String?
    public var accountName: String?
    public var recipientMerchantId: String?
    public var recipientMerchantName: String?
    public var recipientAccountName: String?
    public var providerResult: String?
    public var providerMessage: String?
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
        transfer.merchantId = doc.getValue(key: "merchant_id")
        transfer.merchantName = doc.getValue(key: "merchant_name")
        transfer.accountId = doc.getValue(key: "account_id")
        transfer.accountName = doc.getValue(key: "account_name")
        transfer.recipientMerchantId = doc.getValue(key: "recipient_merchant_id")
        transfer.recipientMerchantName = doc.getValue(key: "recipient_merchant_name")
        transfer.recipientAccountName = doc.getValue(key: "recipient_account_name")
        if let provider: JsonDoc = doc.get(valueFor: "provider") {
            transfer.providerResult = provider.getValue(key: "result")
            transfer.providerMessage = provider.getValue(key: "message")
        }
        return transfer as? T
    }
}
