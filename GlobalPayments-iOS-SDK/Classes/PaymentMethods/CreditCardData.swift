import Foundation

/// Use credit tokens or manual entry data as a payment method.
public class CreditCardData: Credit, CardData {
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

    public func verifyEnrolled(amount: Decimal,
                               currency: String,
                               orderId: String? = nil,
                               completion: ((Bool) -> Void)?) {
        AuthorizationBuilder(transactionType: .verifyEnrolled, paymentMethod: self)
            .withAmount(amount)
            .withCurrency(currency)
            .withOrderId(orderId)
            .execute { [weak self] transaction in
                guard let result = transaction,
                    let threeDSecure = result.threeDSecure else {
                    completion?(false)
                    return
                }
                threeDSecure.amount = amount
                threeDSecure.currency = currency
                threeDSecure.orderId = orderId
                if ["N", "U"].contains(threeDSecure.enrolled) {
                    threeDSecure.xid = nil
                    if threeDSecure.enrolled == "N" {
                        threeDSecure.eci = self?.cardType == "MC" ? 1 : 6
                    } else if threeDSecure.enrolled == "U" {
                        threeDSecure.eci = self?.cardType == "MC" ? 0 : 7
                    }
                    completion?(threeDSecure.enrolled == "Y")
                }
                completion?(false)
        }
    }

    public func verifySignature(authorizationResponse: String,
                                amount: Decimal? = nil,
                                currency: String,
                                orderId: String,
                                completion: ((Bool) -> Void)?) {
        if threeDSecure == nil {
            threeDSecure = ThreeDSecure()
        }
        threeDSecure?.amount = amount
        threeDSecure?.currency = currency
        threeDSecure?.orderId = orderId

        return verifySignature(authorizationResponse: authorizationResponse,
                               completion: completion)
    }

    public func verifySignature(authorizationResponse: String,
                                merchantData: MerchantDataCollection? = nil,
                                completion: ((Bool) -> Void)?) {
        if threeDSecure == nil {
            threeDSecure = ThreeDSecure()
        }
        if merchantData != nil {
            threeDSecure?.merchantData = merchantData
        }
        ManagementBuilder(transactionType: .verifySignature)
            .withAmount(threeDSecure?.amount)
            .withCurrency(threeDSecure?.currency)
            .withPayerAuthenticationResponse(authorizationResponse)
            .withPaymentMethod(TransactionReference(orderId: threeDSecure?.orderId))
            .execute { [weak self] transaction in

                self?.threeDSecure?.status = transaction?.threeDSecure?.status
                self?.threeDSecure?.cavv = transaction?.threeDSecure?.cavv
                self?.threeDSecure?.algorithm = transaction?.threeDSecure?.algorithm
                self?.threeDSecure?.xid = transaction?.threeDSecure?.xid

                if ["A", "Y"].contains(self?.threeDSecure?.status)
                    && transaction?.responseCode == "00" {
                    self?.threeDSecure?.eci = transaction?.threeDSecure?.eci
                    completion?(true)
                } else {
                    self?.threeDSecure?.eci = self?.cardType == "MC" ? 0 : 7
                    completion?(false)
                }
        }
    }
}
