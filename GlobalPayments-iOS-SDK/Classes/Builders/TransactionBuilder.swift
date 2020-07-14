import Foundation

public class TransactionBuilder<TResult>: BaseBuilder<TResult> {
    public var transactionType: TransactionType
    public var transactionModifier: TransactionModifier?
    public var paymentMethod: PaymentMethod?
    public var multiCapture: Bool?

    public init(transactionType: TransactionType,
                transactionModifier: TransactionModifier? = nil,
                paymentMethod: PaymentMethod? = nil,
                multiCapture: Bool? = nil) {

        self.transactionType = transactionType
        self.transactionModifier = transactionModifier
        self.paymentMethod = paymentMethod
        self.multiCapture = multiCapture

        super.init()
    }
}
