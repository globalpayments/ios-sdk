import Foundation

/// Use gift/loyaly/stored value account as a payment method.
public class GiftCard: NSObject, PaymentMethod, PrePaid, Balanceable, Reversable, Chargeable {

    /// Set to `PaymentMethodType.gift` for internal methods.
    public var paymentMethodType: PaymentMethodType = .gift

    /// The gift card's alias.
    public var alias: String? {
        didSet(newValue) {
            self.alias = newValue
            self.value = alias
            self.valueType = "Alias"
        }
    }
    public var cardType: String?
    public var expiry: String?
    /// The gift card's card number.
    public var number: String? {
        didSet(newValue) {
            self.value = newValue
            self.valueType = "CardNbr"
        }
    }
    public var pan: String?
    /// The gift card's PIN.
    public var pin: String?
    /// The token representing the gift card.
    public var token: String? {
        didSet(newValue) {
            self.token = newValue
            self.value = token
            self.valueType = "TokenValue"
        }
    }
    /// The gift card's track data
    public var trackData: String? {
        didSet(newValue) {
            self.trackData = newValue
            self.valueType = "TrackData"
        }
    }
    public var trackNumber: TrackNumber?
    public var value: String?
    public var valueType: String?

    /// Adds an alias to to an existing gift card.
    /// - Parameter phoneNumber: The phone number to add as an alias
    /// - Returns: AuthorizationBuilder
    public func addAlias(phoneNumber: String) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .alias, paymentMethod: self)
            .withAlias(action: .add, value: phoneNumber)
    }

    /// Activates an existing gift card.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func activate(amount: Decimal?) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .activate, paymentMethod: self)
            .withAmount(amount)
    }

    /// Adds value to to an activated gift card.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func addValue(amount: Decimal? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .addValue, paymentMethod: self)
            .withAmount(amount)
    }

    /// Completes a balance inquiry (lookup) on an activated gift card.
    /// - Parameter inquiry: The type of inquiry to make
    /// - Returns: AuthorizationBuilder
    public func balanceInquiry(inquiry: InquiryType) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .balance, paymentMethod: self)
    }

    /// Reverses a previous charge against an activated gift card.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func reverse(amount: Decimal? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .reversal, paymentMethod: self)
            .withAmount(amount)
    }

    /// Creates a charge (sale) transaction against an activated gift card.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func charge(amount: Decimal? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .sale, paymentMethod: self)
            .withAmount(amount)
    }

    /// Deactivates a gift card.
    /// - Returns: AuthorizationBuilder
    public func deactivate() -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .deactivate, paymentMethod: self)
    }

    /// Removes an alias from an existing gift card.
    /// - Parameter phoneNumber: The phone number alias to remove
    /// - Returns: AuthorizationBuilder
    public func removeAlias(phoneNumber: String) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .delete, paymentMethod: self)
    }

    /// Replaces an existing gift card with a new one,
    /// transferring the balance from the old card to the new card in the process.
    /// - Parameter newCard: The replacement gift card
    /// - Returns: AuthorizationBuilder
    public func replaceWith(newCard: GiftCard) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .replace, paymentMethod: self)
            .withReplacementCard(newCard)
    }

    /// Adds rewards points to an activated gift card.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func rewards(amount: Decimal? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .reward, paymentMethod: self)
            .withAmount(amount)
    }

    /// Creates a gift card with an alias.
    /// - Parameter phoneNumber: The phone number to be used as the alias
    /// - Returns: GiftCard
    public static func create(with phoneNumber: String,
                              completion: ((GiftCard?) -> Void)?) {

        let card = GiftCard()
        AuthorizationBuilder(transactionType: .alias, paymentMethod: card)
            .withAlias(action: .create, value: phoneNumber)
            .execute { transaction in
                if transaction?.responseCode == "00" {
                    completion?(transaction?.giftCard)
                } else {
                    completion?(nil)
                }
        }
    }
}
