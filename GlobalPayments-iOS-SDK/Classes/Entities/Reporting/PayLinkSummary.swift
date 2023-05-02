import Foundation

public class PayLinkSummary: NSObject {
    
    public var merchantId: String?
    public var merchantName: String?
    public var accountId: String?
    public var accountName: String?
    public var id: String?
    public var url: String?
    public var status: PayLinkStatus?
    public var type: PayLinkType?
    public var allowedPaymentMethods: [PaymentMethodName]?
    public var usageMode: PaymentMethodUsageMode?
    public var usageCount: String?
    public var usageLimit: String?
    public var reference: String?
    public var name: String?
    public var descriptionSummary: String?
    public var shippable: String?
    public var shippingAmount: String?
    public var viewedCount: String?
    public var expirationDate: Date?
    public var images: [String]?
    public var amount: NSDecimalNumber?
    public var currency: String?
    public var transactions: [TransactionSummary]?
}

extension PayLinkSummary {
    
    class func mapFromJson(_ doc: JsonDoc?) -> PayLinkSummary{
        let summary = PayLinkSummary()
        summary.id = doc?.getValue(key: "id")
        summary.url = doc?.getValue(key: "url")
        summary.status = PayLinkStatus(value: doc?.getValue(key: "status"))
        summary.type = PayLinkType(value: doc?.getValue(key: "type"))
        summary.usageMode = PaymentMethodUsageMode(value: doc?.getValue(key: "usage_mode"))
        summary.usageLimit = doc?.getValue(key: "usage_limit")
        summary.reference = doc?.getValue(key: "reference")
        summary.name = doc?.getValue(key: "name")
        summary.descriptionSummary = doc?.getValue(key: "description")
        summary.shippable = doc?.getValue(key: "shippable")
        summary.shippingAmount = doc?.getValue(key: "shipping_amount")
        summary.usageCount = doc?.getValue(key: "usage_count")
        summary.viewedCount = doc?.getValue(key: "viewed_count")
        summary.expirationDate = doc?.getValue(key: "expiration_date")
        summary.images = doc?.getValue(key: "images")
        
        if let transaction: JsonDoc = doc?.getValue(key: "transactions") {
            summary.amount = transaction.getValue(key: "amount")
            summary.allowedPaymentMethods = getAllowedPaymentMethods(doc: transaction)
            
            if let transactionList: [JsonDoc?] = transaction.getValue(key: "transaction_list") {
                var transactions = [TransactionSummary]()
                transactionList.forEach {
                    transactions.append(createTransactionSummary(doc: $0))
                }
                summary.transactions = transactions
            }
        }
        return summary
    }
    
    private static func getAllowedPaymentMethods(doc: JsonDoc?) -> [PaymentMethodName]? {
        var list: [PaymentMethodName]?
        
        if let paymentMethods: [String] = doc?.getValue(key: "allowed_payment_methods") {
            list = [PaymentMethodName]()
            
            paymentMethods.forEach {
                if let methodName = PaymentMethodName(value: $0) {
                    list?.append(methodName)
                }
            }
        }
        return list
    }
    
    private static func createTransactionSummary(doc: JsonDoc?) -> TransactionSummary {
        let transaction = TransactionSummary();
        transaction.transactionId = doc?.getValue(key: "id")
        transaction.transactionDate = doc?.getValue(key: "time_created")
        transaction.transactionStatus = doc?.getValue(key: "status")
        transaction.transactionType = doc?.getValue(key: "type")
        transaction.channel = doc?.getValue(key: "channel")
        transaction.amount = doc?.getValue(key: "amount")
        transaction.currency = doc?.getValue(key: "currency")
        transaction.referenceNumber = doc?.getValue(key: "reference")
        transaction.clientTransactionId = doc?.getValue(key: "reference")
        transaction.description = doc?.getValue(key: "description")
        
        if let paymentMethod: JsonDoc = doc?.getValue(key: "payment_method") {
            transaction.fingerprint = paymentMethod.getValue(key: "fingerprint")
            transaction.fingerprintIndicator = paymentMethod.getValue(key: "fingerprint_presence_indicator")
        }
        return transaction
    }
}
