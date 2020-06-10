import Foundation

/// Use credit tokens or manual entry data as a payment method.
@objcMembers public class CreditCardData: Credit, CardData {
    /// Use credit tokens or manual entry data as a payment method.
    public var cardPresent: Bool = false
    /// The card's card verification number (CVN).
    /// When set, `CreditCardData.CvnPresenceIndicator` is set to `CvnPresenceIndicator.present`.
    public var cvn: String? {
        didSet(newValue) {
            if !newValue.isNilOrEmpty {
                cvnPresenceIndicator = .present
            }
        }
    }
    /// The name on the front of the card.
    public var cardHolderName: String?
    /// Indicates card verification number (CVN) presence.
    /// Default value is `CvnPresenceIndicator.notRequested`.
    public var cvnPresenceIndicator: CvnPresenceIndicator = .notRequested
    /// The card's number.
    public var number: String? {
        didSet(newValue) {
            cardType = CardUtils.mapCardType(cardNumber: newValue)
        }
    }
    /// The card's expiration month.
    public var expMonth: Int = .zero
    /// The card's expiration year.
    public var expYear: Int = .zero
    /// Indicates if a card reader was used when accepting the card data.
    /// Default value is `false`.
    public var readerPresent: Bool = false
    //    var month = (ExpMonth.HasValue) ? ExpMonth.ToString().PadLeft(2, '0') : string.Empty;
    //    var year = (ExpYear.HasValue) ? ExpYear.ToString().PadLeft(4, '0').Substring(2, 2) : string.Empty;
    //    return month + year;
    public var shortExpiry: String {
        return .empty
    }

    public func verifyEnrolled(amount: Decimal, currency: String, orderId: String? = nil) -> Bool {
        let transaction = AuthorizationBuilder(transactionType: .verifyEnrolled, paymentMethod: self)
            .withAmount(amount)
            .withCurrency(currency)
            .withOrderId(orderId)
            .execute()

        guard let result = transaction as? Transaction,
            let threeDSecure = result.threeDSecure else {
            return false
        }
        threeDSecure.amount = amount
        threeDSecure.currency = currency
        threeDSecure.orderId = orderId
        if ["N", "U"].contains(threeDSecure.enrolled) {
            threeDSecure.xid = nil
            if threeDSecure.enrolled == "N" {
                threeDSecure.eci = cardType == "MC" ? 1 : 6
            } else if threeDSecure.enrolled == "U" {
                threeDSecure.eci = cardType == "MC" ? 0 : 7
            }
            return threeDSecure.enrolled == "Y"
        }
        return false
    }

    public func verifySignature(authorizationResponse: String,
                                amount: Decimal? = nil,
                                currency: String,
                                orderId: String) -> Bool {
        if threeDSecure == nil {
            threeDSecure = ThreeDSecure()
        }
        threeDSecure?.amount = amount
        threeDSecure?.currency = currency
        threeDSecure?.orderId = orderId

        return verifySignature(authorizationResponse: authorizationResponse)
    }

    public func verifySignature(authorizationResponse: String,
                                merchantData: MerchantDataCollection? = nil) -> Bool {
        if threeDSecure == nil {
            threeDSecure = ThreeDSecure()
        }
        if merchantData != nil {
            threeDSecure?.merchantData = merchantData
        }
        let transaction = ManagementBuilder(transactionType: .verifySignature)
            .withAmount(threeDSecure?.amount)
            .withCurrency(threeDSecure?.currency)
            .withPayerAuthenticationResponse(authorizationResponse)
            .withPaymentMethod(TransactionReference(orderId: threeDSecure?.orderId))
            .execute() as? Transaction

        threeDSecure?.status = transaction?.threeDSecure?.status
        threeDSecure?.cavv = transaction?.threeDSecure?.cavv
        threeDSecure?.algorithm = transaction?.threeDSecure?.algorithm
        threeDSecure?.xid = transaction?.threeDSecure?.xid

        if ["A", "Y"].contains(threeDSecure?.status)
            && transaction?.responseCode == "00" {
            threeDSecure?.eci = transaction?.threeDSecure?.eci
            return true
        } else {
            threeDSecure?.eci = cardType == "MC" ? 0 : 7
            return false
        }
    }
}
