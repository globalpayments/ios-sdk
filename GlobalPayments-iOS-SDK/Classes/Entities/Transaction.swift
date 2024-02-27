import Foundation

/// Transaction response.
public class Transaction: NSObject {

    public var alternativePaymentResponse: AlternativePaymentResponse? {
        get {
            if transactionReference != nil {
                return transactionReference?.alternativePaymentResponse
            }
            return nil
        }
        set(newValue) {
            if transactionReference == nil {
                transactionReference = TransactionReference()
            }
            transactionReference?.alternativePaymentResponse = newValue
        }
    }
    /// The authorized amount.
    public var authorizedAmount: NSDecimalNumber?
    public var autoSettleFlag: String?
    /// The authorization code provided by the issuer.
    public var authorizationCode: String? {
        get {
            if transactionReference != nil {
                return transactionReference?.authCode
            }
            return nil
        }
        set(newValue) {
            if transactionReference == nil {
                transactionReference = TransactionReference()
            }
            transactionReference?.authCode = newValue
        }
    }
    /// The available balance of the payment method.
    public var availableBalance: NSDecimalNumber?
    /// The address verification service (AVS) response code.
    public var avsResponseCode: String?
    /// The address verification service (AVS) address response.
    public var avsAddressResponse: String?
    /// The address verification service (AVS) response message.
    public var avsResponseMessage: String?
    /// The balance on the account after the transaction.
    public var balanceAmount: NSDecimalNumber?
    /// Summary of the batch.
    public var batchSummary: BatchSummary?
    
    public var cardBrandTransactionId: String?
    
    /// The type of card used in the transaction.
    public var cardType: String?
    /// The last four digits of the card number used in the transaction.
    public var cardLast4: String?
    
    public var cardDetails: Card?
    
    @available(*, deprecated, message: "Will soon be replaced with cardDetails.cardNumber")
    /// The card number used in the transaction.
    public var cardNumber: String?
    @available(*, deprecated, message: "Will soon be replaced with cardDetails.cardExpMonth")
    /// The card expiry month used in the transaction
    public var cardExpMonth: Int?
    @available(*, deprecated, message: "Will soon be replaced with cardDetails.cardExpYear")
    /// The card expiry year used in the transaction
    public var cardExpYear: Int?
    
    public var cardIssuerResponse: CardIssuerResponse?
    /// The consumer authentication (3DSecure) verification value response code.
    public var cavvResponseCode: String?
    /// The client transaction ID supplied in the request.
    public var clientTransactionId: String? {
        get {
            if transactionReference != nil {
                return transactionReference?.clientTransactionId
            }
            return nil
        }
        set(newValue) {
            if transactionReference == nil {
                transactionReference = TransactionReference()
            }
            transactionReference?.clientTransactionId = newValue
        }
    }
    /// The commercial indicator for Level II/III.
    public var commercialIndicator: String?
    /// The card verification number (CVN) response code.
    public var cvnResponseCode: String?
    /// The card verification number (CVN) response message.
    public var cvnResponseMessage: String?
    public var dccRateData: DccRateData?
    public var debitMac: DebitMac?
    /// The EMV response from the issuer.
    public var emvIssuerResponse: String?
    
    public var fraudResponse: FraudResponse?
    /// The host response date
    public var hostResponseDate: Date?
    /// The Auto settle Flag which comes in response
    public var multiCapture: Bool {
        return multiCapturePaymentCount != nil && multiCapturePaymentCount != nil
    }
    public var multiCapturePaymentCount: Int?
    public var multiCaptureSequence: Int?
    /// The order ID supplied in the request.
    public var orderId: String? {
        get {
            if transactionReference == nil {
                return transactionReference?.orderId
            }
            return nil
        }
        set(newValue) {
            if transactionReference == nil {
                transactionReference = TransactionReference()
            }
            transactionReference?.orderId = newValue
        }
    }
    /// The type of payment made in the request.
    public var paymentMethodType: PaymentMethodType {
        get {
            if let transactionReference = transactionReference {
                return transactionReference.paymentMethodType
            }
            return .credit
        }
        set(newValue) {
            if transactionReference == nil {
                transactionReference = TransactionReference()
            }
            transactionReference?.paymentMethodType = newValue
        }
    }
    
    public var payerDetails: PayerDetails?
    
    public var methodUsageMode: PaymentMethodUsageMode?
    
    /// The remaining points on the account after the transaction.
    public var pointsBalanceAmount: NSDecimalNumber?
    /// The recurring profile data code.
    public var recurringDataCode: String?
    /// The reference number provided by the issuer.
    public var referenceNumber: String?
    /// The original response code from the issuer/gateway.
    public var responseCode: String?
    /// The original response message from the issuer/gateway.
    public var responseMessage: String?
    /// A catch all for additional fields not mapped to a specific transaction properties.
    public var responseValues: [String: String]?
    public var schemeId: String?
    public var threeDSecure: ThreeDSecure?
    /// The timestamp of the transaction.
    public var timestamp: String?
    /// The transaction descriptor.
    public var transactionDescriptor: String?
    /// The gateway transaction ID of the transaction.
    public var transactionId: String? {
        get {
            if transactionReference != nil {
                return transactionReference?.transactionId
            }
            return nil
        }
        set(newValue) {
            if transactionReference == nil {
                transactionReference = TransactionReference()
            }
            transactionReference?.transactionId = newValue
        }
    }
    /// The payment token returned in the transaction.
    public var token: String?
    
    public var fingerPrint: String?
    public var fingerPrintIndicator: String?
    
    var giftCard: GiftCard?
    var transactionReference: TransactionReference?
    public var payLinkResponse: PayLinkResponse?
    public var bnplResponse: BNPLResponse?
    public var bankPaymentResponse: BankPaymentResponse?
    public var transfersFundsAccounts: [FundsAccountDetails]?

    /// Creates a `Transaction` object from a stored transaction ID.
    /// Used to expose management requests on the original transaction at a later date/time.
    /// - Parameters:
    ///   - transactionId: The original transaction ID
    ///   - paymentMethodType: The original payment method type. Defaults to `PaymentMethodType.credit`.
    /// - Returns: Transaction
    public static func fromId(transactionId: String,
                              paymentMethodType: PaymentMethodType = .credit) -> Transaction {

        let transactionReference = TransactionReference(
            paymentMethodType: paymentMethodType,
            transactionId: transactionId
        )
        let transaction = Transaction()
        transaction.transactionReference = transactionReference
        return transaction
    }

    /// Creates a `Transaction` object from a stored transaction ID.
    /// Used to expose management requests on the original transaction at a later date/time.
    /// - Parameters:
    ///   - transactionId: The original transaction ID
    ///   - orderId: The original transaction's order ID
    ///   - paymentMethodType: The original payment method type. Defaults to `PaymentMethodType.credit`.
    /// - Returns: Transaction
    public static func fromId(transactionId: String, orderId: String, paymentMethodType: PaymentMethodType = .credit) -> Transaction {
        let transactionReference = TransactionReference(
            paymentMethodType: paymentMethodType,
            orderId: orderId,
            transactionId: transactionId
        )
        let transaction = Transaction()
        transaction.transactionReference = transactionReference
        return transaction
    }

    /// Creates an additional authorization against the original transaction.
    /// - Parameter amount: The additional amount to authorize
    /// - Returns: ManagementBuilder
    public func additionalAuth(amount: NSDecimalNumber? = nil) -> ManagementBuilder {
        guard let transactionReference = transactionReference else {
            fatalError("transactionReference cannot be nil!")
        }
        return ManagementBuilder(transactionType: .auth)
            .withPaymentMethod(transactionReference)
            .withAmount(amount)
    }

    /// Captures the original transaction.
    /// - Parameter amount: The amount to capture
    /// - Returns: ManagementBuilder
    public func capture(amount: NSDecimalNumber? = nil) -> ManagementBuilder {
        guard let transactionReference = transactionReference else {
            fatalError("transactionReference cannot be nil!")
        }
        var builder = ManagementBuilder(transactionType: .capture)
            .withPaymentMethod(transactionReference)
            .withAmount(amount)
        if multiCapture {
            builder = builder.withMultiCapture(
                sequence: multiCaptureSequence,
                paymentCount: multiCapturePaymentCount
            )
        }
        return builder
    }
    
    /// Confirm an original transaction. For now it is used for the APM transactions with PayPal
    /// - Returns: ManagementBuilder
    public func confirm(_ amount: NSDecimalNumber? = nil) -> ManagementBuilder {
        return ManagementBuilder(transactionType: .confirm)
            .withPaymentMethod(self.transactionReference)
            .withAmount(amount)
    }

    /// Edits the original transaction.
    /// - Returns: ManagementBuilder
    public func edit() -> ManagementBuilder {
        guard let transactionReference = transactionReference else {
            fatalError("transactionReference cannot be nil!")
        }
        return ManagementBuilder(transactionType: .edit)
            .withPaymentMethod(transactionReference)
    }

    /// Places the original transaction on hold.
    /// - Returns: ManagementBuilder
    public func hold() -> ManagementBuilder {
        guard let transactionReference = transactionReference else {
            fatalError("transactionReference cannot be nil!")
        }
        return ManagementBuilder(transactionType: .hold)
            .withPaymentMethod(transactionReference)
    }

    /// Refunds/returns the original transaction.
    /// - Parameter amount: The amount to refund/return
    /// - Returns: ManagementBuilder
    public func refund(amount: NSDecimalNumber? = nil) -> ManagementBuilder {
        guard let transactionReference = transactionReference else {
            fatalError("transactionReference cannot be nil!")
        }
        return ManagementBuilder(transactionType: .refund)
            .withPaymentMethod(transactionReference)
            .withAmount(amount)
    }

    /// Releases the original transaction from a hold.
    /// - Returns: ManagementBuilder
    public func releaseTransaction() -> ManagementBuilder {
        guard let transactionReference = transactionReference else {
            fatalError("transactionReference cannot be nil!")
        }
        return ManagementBuilder(transactionType: .release)
            .withPaymentMethod(transactionReference)
    }

    /// Reverses the original transaction.
    /// - Parameter amount: The original authorization amount
    /// - Returns: ManagementBuilder
    public func reverse(amount: NSDecimalNumber? = nil) -> ManagementBuilder {
        guard let transactionReference = transactionReference else {
            fatalError("transactionReference cannot be nil!")
        }
        return ManagementBuilder(transactionType: .reversal)
            .withPaymentMethod(transactionReference)
            .withAmount(amount)
    }

    public func increment(amount: NSDecimalNumber? = nil) -> ManagementBuilder {
        guard let transactionReference = transactionReference else {
            fatalError("transactionReference cannot be nil!")
        }
        return ManagementBuilder(transactionType: .increment)
            .withAmount(amount)
            .withPaymentMethod(transactionReference)
    }

    /// Reauthorize the original transaction.
    /// - Parameter amount: The original authorization amount
    /// - Returns: ManagementBuilder
    public func reauthorize(amount: NSDecimalNumber? = nil) -> ManagementBuilder {
        guard let transactionReference = transactionReference else {
            fatalError("transactionReference cannot be nil!")
        }
        return ManagementBuilder(transactionType: .reauth)
            .withPaymentMethod(transactionReference)
            .withAmount(amount ?? balanceAmount)
    }
    
    /// Transfer part of transaction amount by a merchant to the partner account
    /// - Parameter amount: The original authorization amount
    /// - Returns: ManagementBuilder
    public func split(amount: NSDecimalNumber? = nil) -> ManagementBuilder {
        guard let transactionReference = transactionReference else {
            fatalError("transactionReference cannot be nil!")
        }
        return  ManagementBuilder(transactionType: .splitFunds)
            .withPaymentMethod(transactionReference)
            .withAmount(amount)
    }
}
