import Foundation

public class TransactionReference: NSObject, PaymentMethod {
    public var paymentMethodType: PaymentMethodType
    public var authCode: String?
    public var batchNumber: String?
    public var orderId: String?
    public var transactionId: String?
    public var clientTransactionId: String?
    public var alternativePaymentType: String?
    
    public required init(paymentMethodType: PaymentMethodType = .reference,
                         authCode: String? = nil,
                         batchNumber: String? = nil,
                         orderId: String? = nil,
                         transactionId: String? = nil,
                         clientTransactionId: String? = nil,
                         alternativePaymentType: String? = nil) {
        
        self.paymentMethodType = paymentMethodType
        self.authCode = authCode
        self.batchNumber = batchNumber
        self.orderId = orderId
        self.transactionId = transactionId
        self.clientTransactionId = clientTransactionId
        self.alternativePaymentType = alternativePaymentType
    }
}
