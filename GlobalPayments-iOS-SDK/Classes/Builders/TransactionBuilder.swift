import Foundation

@objcMembers public class TransactionBuilder<TResult>: BaseBuilder<TResult> {
    public var transactionType: TransactionType
    public var transactionModifier: TransactionModifier?
    public var paymentMethod: PaymentMethod?
    public var multiCapture: Bool = false

    public init(transactionType: TransactionType,
                transactionModifier: TransactionModifier? = nil,
                paymentMethod: PaymentMethod? = nil) {

        self.transactionType = transactionType
        self.transactionModifier = transactionModifier
        self.paymentMethod = paymentMethod

        super.init()
    }
}
