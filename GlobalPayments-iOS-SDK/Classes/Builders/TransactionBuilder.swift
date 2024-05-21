import Foundation

 public class TransactionBuilder<TResult>: BaseBuilder<TResult> {
    public var transactionType: TransactionType
    public var transactionModifier: TransactionModifier
    public var paymentMethod: PaymentMethod?
    public var payLinkData: PayLinkData?
    public var multiCapture: Bool = false
    public var paymentLinkId: String?

    public init(transactionType: TransactionType,
                transactionModifier: TransactionModifier = .none,
                paymentMethod: PaymentMethod? = nil) {

        self.transactionType = transactionType
        self.transactionModifier = transactionModifier
        self.paymentMethod = paymentMethod

        super.init()
    }
}
