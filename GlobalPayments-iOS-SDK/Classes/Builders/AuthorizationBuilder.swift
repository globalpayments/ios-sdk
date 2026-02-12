import Foundation

/// Used to create charges, verifies, etc. for the supported payment method types.
 public class AuthorizationBuilder: TransactionBuilder<Transaction> {
    var accountType: AccountType?
    var alias: String?
    var aliasAction: AliasAction?
    var allowDuplicates: Bool?
    var allowPartialAuth: Bool = false
    var amount: NSDecimalNumber?
    var amountEstimated: Bool?
    var authAmount: NSDecimalNumber?
    var autoSubstantiation: AutoSubstantiation?
    var balanceInquiryType: InquiryType?
    var billingAddress: Address?
    var cashBackAmount: NSDecimalNumber?
    var clientTransactionId: String?
    var convenienceAmount: NSDecimalNumber?
    var commercialRequest: Bool?
    var commercialData: CommercialData?
    var currency: String?
    var customerId: String?
    var oneTimePayment: Bool?
    var customerData: Customer?
    var customer: Customer?
    var customData: [String]?
    var customerIpAddress: String?
    var cvn: String?
    var dccRateData: DccRateData?
    var requestDescription: String?
    var decisionManager: DecisionManager?
    var dynamicDescriptor: String?
    var ecommerceInfo: EcommerceInfo?
    var emvFallbackCondition: EmvFallbackCondition?
    var emvLastChipRead: EmvLastChipRead?
    var emvChipCondition: EmvChipCondition?
    var fraudFilterMode: FraudFilterMode?
    var fraudRules: FraudRuleCollection?
    var gratuity: NSDecimalNumber?
    var shippingAmt: NSDecimalNumber?
    var hostedPaymentData: HostedPaymentData?
    var invoiceNumber: String?
    var idempotencyKey: String?
    var lodgingData: LodgingData?
    var maskedDataResponse: Bool?
    var messageAuthenticationCode: String?
    var miscProductData: [Product]?
    var offlineAuthCode: String?
    var orderId: String?
    var orderDetails: OrderDetails?
    var payerDetails: PayerDetails?
    var paymentApplicationVersion: String?
    var paymentMethodUsageMode: PaymentMethodUsageMode?
    var posSequenceNumber: String?
    var productId: String?
    var recurringSequence: RecurringSequence?
    var recurringType: RecurringType?
    var requestMultiUseToken: Bool?
    var replacementCard: GiftCard?
    var reversalReasonCode: ReversalReasonCode?
    var scheduleId: String?
    var shippingAddress: Address?
    var storedCredential: StoredCredential?
    var supplementaryData: [String: [String]]?
    var tagData: String?
    var timestamp: String?
    var surchargeAmount: NSDecimalNumber?
    var firstName: String?
    var lastName: String?
    var id: String?
    var cardBrandTransactionId: String?
    var homePhone: PhoneNumber?
    var workPhone: PhoneNumber?
    var shippingPhone: PhoneNumber?
    var mobilePhone: PhoneNumber?
    var bnplShippingMethod: BNPLShippingMethod?
    var remittanceReferenceType: RemittanceReferenceType?
    var remittanceReferenceValue: String?
    var transactionInitiator: StoredCredentialInitiator?
    var merchantCategory: MerchantCategory?
    var installmentData: InstallmentData?

    var hasEmvFallbackData: Bool {
        return emvFallbackCondition != nil ||
            emvLastChipRead != nil ||
            !paymentApplicationVersion.isNilOrEmpty
    }

     /// Set the installment data
     /// - Parameter installmentData: InstallmentData
     /// - Returns: AuthorizationBuilder
     public func withInstallmentData(_ installmentData: InstallmentData) -> AuthorizationBuilder {
         self.installmentData = installmentData
         return self
     }
     
    /// Set the request amount
    /// - Parameter amount: Request amount
    /// - Returns: AuthorizationBuilder
    public func withAmount(_ amount: NSDecimalNumber?) -> AuthorizationBuilder {
        self.amount = amount
        return self
    }

    /// Sets the one-time payment flag; where applicable.
    /// This is only useful when using recurring payment profiles for one-time payments that are not a part of a recurring schedule.
    /// - Parameter value: The one-time flag
    /// - Returns: AuthorizationBuilder
    public func withOneTimePayment(_ value: Bool?) -> AuthorizationBuilder {
        self.oneTimePayment = value
        self.transactionModifier = .recurring
        return self
    }

    /// Indicates the type of account provided; see the associated Type enumerations for specific values supported.
    /// - Parameter type: AccountType
    /// - Returns: AuthorizationBuilder
    public func withAccountType(_ type: AccountType) -> AuthorizationBuilder {
        self.accountType = type
        return self
    }

    /// Sets an address value; where applicable.
    /// Currently supports billing and shipping addresses.
    /// - Parameters:
    ///   - address: The desired address information
    ///   - type: The desired address type
    /// - Returns: AuthorizationBuilder
    public func withAddress(_ address: Address,
                            type: AddressType = .billing) -> AuthorizationBuilder {
        address.type = type
        if type == .billing {
            billingAddress = address
        } else {
            shippingAddress = address
        }
        return self
    }

    /// Allows duplicate transactions by skipping the gateway's duplicate checking.
    /// - Parameter allowDuplicates: The duplicate skip flag
    /// - Returns: AuthorizationBuilder
    public func withAllowDuplicates(_ allowDuplicates: Bool) -> AuthorizationBuilder {
        self.allowDuplicates = allowDuplicates
        return self
    }

    /// Allows partial authorizations to occur.
    /// - Parameter allowPartialAuth: The allow partial flag
    /// - Returns: AuthorizationBuilder
    public func withAllowPartialAuth(_ allowPartialAuth: Bool) -> AuthorizationBuilder {
        self.allowPartialAuth = allowPartialAuth
        return self
    }

    /// Sets the transaction's authorization amount; where applicable.
    /// This is a specialized field. In most cases, `Authorization.withAmount` should be used.
    /// - Parameter authAmount: The authorization amount
    /// - Returns: AuthorizationBuilder
    public func withAuthAmount(_ authAmount: NSDecimalNumber?) -> AuthorizationBuilder {
        self.authAmount = authAmount
        return self
    }

    /// Sets the auto subtantiation values for the transaction.
    /// - Parameter autoSubstantiation: The auto substantiation object
    /// - Returns: AuthorizationBuilder
    public func withAutoSubstantiation(_ autoSubstantiation: AutoSubstantiation) -> AuthorizationBuilder {
        self.autoSubstantiation = autoSubstantiation
        return self
    }

    /// Sets the Multicapture value as true/false.
    /// - Returns: AuthorizationBuilder
    public func withMultiCapture(_ multiCapture: Bool = true) -> AuthorizationBuilder {
        self.multiCapture = multiCapture
        return self
    }

    /// Sets the cash back amount.
    /// This is a specialized field for debit or EBT transactions.
    /// - Parameter cashBack: The desired cash back amount
    /// - Returns: AuthorizationBuilder
    public func withCashBack(_ cashBack: NSDecimalNumber?) -> AuthorizationBuilder {
        self.cashBackAmount = cashBack
        return self
    }

    public func withChipCondition(_ chipCondition: EmvChipCondition?) -> AuthorizationBuilder {
        self.emvChipCondition = chipCondition
        return self
    }

    public func withDccRateData(_ value: DccRateData?) -> AuthorizationBuilder {
        self.dccRateData = value
        return self
    }

    public func withEmvLastChipRead(_ emvLastChipRead: EmvLastChipRead?) -> AuthorizationBuilder {
        self.emvLastChipRead = emvLastChipRead
        return self
    }

    /// Sets the client transaction ID.
    /// This is an application derived value that can be used to identify a
    /// transaction in case a gateway transaction ID is not returned, e.g.
    /// in cases of timeouts.
    /// The supplied value should be unique to the configured merchant or
    /// terminal account.
    /// - Parameter transactionId: The client transaction ID
    /// - Returns: AuthorizationBuilder
    public func withClientTransactionId(_ clientTransactionId: String?) -> AuthorizationBuilder {
        if transactionType != .reversal || transactionType != .refund {
            self.clientTransactionId = clientTransactionId
            return self
        }

        if !(paymentMethod is TransactionReference) {
            paymentMethod = TransactionReference(clientTransactionId: clientTransactionId)
        }

        return self
    }

    /// Sets the transaction's currency; where applicable.
    /// The formatting for the supplied value will currently depend on
    /// the configured gateway's requirements.
    /// - Parameter currency: The currency
    /// - Returns: AuthorizationBuilder
    public func withCurrency(_ currency: String?) -> AuthorizationBuilder {
        self.currency = currency
        return self
    }

    public func withCustomData(_ customData: [String]) -> AuthorizationBuilder {
        if self.customData == nil {
            self.customData = [String]()
        }
        self.customData?.append(contentsOf: customData)
        return self
    }

    public func withCustomerData(_ customerData: Customer?) -> AuthorizationBuilder {
        self.customerData = customerData
        return self
    }

    public func withCustomer(_ customer: Customer) -> AuthorizationBuilder {
        self.customer = customer
        return self
    }

    /// Sets the customer ID; where applicable.
    /// This is an application/merchant generated value.
    /// - Parameter customerId: The customer ID
    /// - Returns: AuthorizationBuilder
    public func withCustomerId(_ customerId: String) -> AuthorizationBuilder {
        self.customerId = customerId
        return self
    }

    /// Sets the customer's IP address; where applicable.
    /// This value should be obtained during the payment process.
    /// - Parameter customerIpAddress: The customer's IP address
    /// - Returns: AuthorizationBuilder
    public func withCustomerIpAddress(_ customerIpAddress: String) -> AuthorizationBuilder {
        self.customerIpAddress = customerIpAddress
        return self
    }

    /// Sets the CVN value for recurring payments; where applicable.
    /// - Parameter cvn: Cvn value to use in the request
    /// - Returns: AuthorizationBuilder
    public func withCvn(_ cvn: String) -> AuthorizationBuilder {
        self.cvn = cvn
        return self
    }

    public func withDecisionManager(_ decisionManager: DecisionManager) -> AuthorizationBuilder {
        self.decisionManager = decisionManager
        return self
    }

    /// Sets the transaction's description.
    /// This value is not guaranteed to be sent in the authorization
    /// - Parameter description: The description
    /// - Returns: AuthorizationBuilder
    public func withDescription(_ description: String) -> AuthorizationBuilder {
        self.requestDescription = description
        return self
    }

    /// Sets the transaction's dynamic descriptor.
    /// This value is sent during the authorization process and is displayed in the consumer's account.
    /// - Parameter dynamicDescriptor: The dynamic descriptor
    /// - Returns: AuthorizationBuilder
    public func withDynamicDescriptor(_ dynamicDescriptor: String) -> AuthorizationBuilder {
        self.dynamicDescriptor = dynamicDescriptor
        return self
    }

    /// Sets eCommerce specific data; where applicable.
    /// This can include:
    ///     - Consumer authentication (3DSecure) data
    ///     - Direct market data
    /// - Parameter ecommerceInfo: The eCommerce data
    /// - Returns: AuthorizationBuilder
    public func withEcommerceInfo(_ ecommerceInfo: EcommerceInfo) -> AuthorizationBuilder {
        self.ecommerceInfo = ecommerceInfo
        return self
    }
    
    public func withMaskedDataResponse(_ value: Bool) -> AuthorizationBuilder {
        self.maskedDataResponse = value
        return self
    }

    /// Sets the gratuity amount; where applicable.
    /// This value is information only and does not affect the authorization amount.
    /// - Parameter gratuity: This value is information only and does not affect the authorization amount.
    /// - Returns: AuthorizationBuilder
    public func withGratuity(_ gratuity: NSDecimalNumber?) -> AuthorizationBuilder {
        self.gratuity = gratuity
        return self
    }

    /// Sets the Convenience amount; where applicable.
    /// - Parameter convenienceAmount: The Convenience amount
    /// - Returns: AuthorizationBuilder
    public func withConvenienceAmount(_ convenienceAmount: NSDecimalNumber?) -> AuthorizationBuilder {
        self.convenienceAmount = convenienceAmount
        return self
    }

    /// Sets the Shipping amount; where applicable.
    /// - Parameter shippingAmt: The Shipping amount
    /// - Returns: AuthorizationBuilder
    public func withShippingAmt(_ shippingAmt: NSDecimalNumber?) -> AuthorizationBuilder {
        self.shippingAmt = shippingAmt
        return self
    }

    /// Additional hosted payment specific information for Realex HPP implementation.
    /// - Parameter hostedPaymentData: The hosted payment data
    /// - Returns: AuthorizationBuilder
    public func withHostedPaymentData(_ hostedPaymentData: HostedPaymentData) -> AuthorizationBuilder {
        self.hostedPaymentData = hostedPaymentData
        return self
    }

    /// Sets the invoice number; where applicable.
    /// - Parameter invoiceNumber: The invoice number
    /// - Returns: AuthorizationBuilder
    public func withInvoiceNumber(_ invoiceNumber: String) -> AuthorizationBuilder {
        self.invoiceNumber = invoiceNumber
        return self
    }

    /// Field submitted in the request that is used to ensure idempotency is maintained within the action
    /// - Parameter idempotencyKey: The idempotency key
    /// - Returns: AuthorizationBuilder
    public func withIdempotencyKey(_ idempotencyKey: String?) -> AuthorizationBuilder {
        self.idempotencyKey = idempotencyKey
        return self
    }

    public func withCommercialRequest(_ commercialRequest: Bool) -> AuthorizationBuilder {
        self.commercialRequest = commercialRequest
        return self
    }
     
     public func withCommercialData(_ commercialData: CommercialData) -> AuthorizationBuilder {
         self.commercialData = commercialData
         if commercialData.commercialIndicator == .level_II {
             transactionModifier = .levelII
         } else {
             transactionModifier = .levelIII
         }
         return self
     }
     
     public func withPayerDetails(payerDetails: PayerDetails) -> AuthorizationBuilder {
         self.payerDetails = payerDetails
         return self
     }
     
     public func withOrderDetails(orderDetails: OrderDetails) -> AuthorizationBuilder {
         self.orderDetails = orderDetails
         return self
     }

    /// Sets the message authentication code; where applicable.
    /// - Parameter messageAuthenticationCode: A special block of encrypted data added to every transaction when it is sent from the payment terminal to the payment processor
    /// - Returns: AuthorizationBuilder
    public func withMessageAuthenticationCode(_ messageAuthenticationCode: String) -> AuthorizationBuilder {
        self.messageAuthenticationCode = messageAuthenticationCode
        return self
    }

    public func withMiscProductData(_ miscProductData: [Product]) -> AuthorizationBuilder {
        if self.miscProductData == nil {
            self.miscProductData = [Product]()
        }
        self.miscProductData?.append(contentsOf: miscProductData)
        return self
    }

    /// Sets the offline authorization code; where applicable.
    /// The merchant is required to supply this value as obtained when calling the issuing bank for the authorization.
    /// - Parameter offlineAuthCode: The offline authorization code
    /// - Returns: AuthorizationBuilder
    public func withOfflineAuthCode(_ offlineAuthCode: String?) -> AuthorizationBuilder {
        self.offlineAuthCode = offlineAuthCode
        self.transactionModifier = .offline
        return self
    }

    /// Sets the one-time payment flag; where applicable.
    /// This is only useful when using recurring payment profiles for one-time payments that are not a part of a recurring schedule.
    /// - Parameter oneTimePayment: The one-time flag
    /// - Returns: AuthorizationBuilder
    public func withOneTimePayment(_ oneTimePayment: Bool) -> AuthorizationBuilder {
        self.oneTimePayment = oneTimePayment
        self.transactionModifier = .recurring
        return self
    }

    /// Sets the transaction's order ID; where applicable.
    /// - Parameter orderId: The order ID
    /// - Returns: AuthorizationBuilder
    public func withOrderId(_ orderId: String?) -> AuthorizationBuilder {
        self.orderId = orderId
        return self
    }

    public func withPaymentApplicationVersion(_ paymentApplicationVersion: String) -> AuthorizationBuilder {
        self.paymentApplicationVersion = paymentApplicationVersion
        return self
    }

    public func withPaymentMethodUsageMode(_ paymentMethodUsageMode: PaymentMethodUsageMode?) -> AuthorizationBuilder {
        self.paymentMethodUsageMode = paymentMethodUsageMode
        return self
    }

    /// Sets the transaction's payment method.
    /// - Parameter paymentMethod: The payment method
    /// - Returns: AuthorizationBuilder
    public func withPaymentMethod(_ paymentMethod: PaymentMethod?) -> AuthorizationBuilder {
        self.paymentMethod = paymentMethod
        if let paymentMethod = paymentMethod as? EBTCardData,
            paymentMethod.serialNumber != nil {
            transactionModifier = .voucher
        }
        if let paymentMethod = paymentMethod as? CreditCardData,
            paymentMethod.mobileType != nil {
            transactionModifier = .encryptedMobile
        }
        return self
    }

    /// Sets the POS Sequence Number; where applicable.
    /// - Parameter posSequenceNumber: POS sequence number for Canadian Debit transactions.
    /// - Returns: AuthorizationBuilder
    public func withPosSequenceNumber(_ posSequenceNumber: String?) -> AuthorizationBuilder {
        self.posSequenceNumber = posSequenceNumber
        return self
    }

    /// Requests multi-use tokenization / card storage.
    /// This will depend on a successful transaction. If there was a failure or decline, the multi-use tokenization / card storage will not be successful.
    /// - Parameter requestMultiUseToken: The request flag
    /// - Returns: AuthorizationBuilder
    public func withRequestMultiUseToken(_ requestMultiUseToken: Bool) -> AuthorizationBuilder {
        self.requestMultiUseToken = requestMultiUseToken
        return self
    }

    /// Sets the transaction's product ID; where applicable.
    /// - Parameter productId: The product ID
    /// - Returns: AuthorizationBuilder
    public func withProductId(_ productId: String?) -> AuthorizationBuilder {
        self.productId = productId
        return self
    }

    /// Sets the Recurring Info for Realex based recurring payments where applicable.
    /// - Parameters:
    ///   - recurringType: The value can be 'fixed' or 'variable' depending on whether
    ///   the amount will change for each transaction.
    ///   - recurringSequence: Indicates where in the recurring sequence the transaction occurs.
    ///   Must be 'first' for the first transaction for this card, 'subsequent' for transactions after that,
    ///   and 'last' for the final transaction of the set.
    /// - Returns: AuthorizationBuilder
    public func withRecurringInfo(recurringType: RecurringType?,
                                  recurringSequence: RecurringSequence?) -> AuthorizationBuilder {
        self.recurringSequence = recurringSequence
        self.recurringType = recurringType
        return self
    }

    public func withReversalReasonCode(_ reversalReasonCode: ReversalReasonCode?) -> AuthorizationBuilder {
        self.reversalReasonCode = reversalReasonCode
        return self
    }

    /// Sets the schedule ID associated with the transaction; where applicable.
    /// This is specific to transactions against recurring profiles that are a part of a recurring schedule.
    /// - Parameter scheduleId: The schedule ID
    /// - Returns: AuthorizationBuilder
    public func withScheduleId(_ scheduleId: String?) -> AuthorizationBuilder {
        self.scheduleId = scheduleId
        return self
    }

    public func withStoredCredential(_ storedCredential: StoredCredential?) -> AuthorizationBuilder {
        self.storedCredential = storedCredential
        return self
    }
    
    public func withCardBrandStorage(_ credentialInitiator: StoredCredentialInitiator, value: String?) -> AuthorizationBuilder {
        transactionInitiator = credentialInitiator
        cardBrandTransactionId = value
        return self
    }

    public func withSupplementaryData(type: String, values: [String]) -> AuthorizationBuilder {
        if supplementaryData == nil {
            supplementaryData = [String: [String]]()
        }
        if let keys = supplementaryData?.keys, !keys.contains(type) {
            supplementaryData?[type] = values
        }
        return self
    }

    /// Sets the related gateway transaction ID; where applicable.
    /// This value is used to associated a previous transaction with the current transaction.
    /// - Parameter transactionId: The gateway transaction ID
    /// - Returns: AuthorizationBuilder
    public func withTransactionId(_ transactionId: String?) -> AuthorizationBuilder {
        if let paymentMethod = paymentMethod as? TransactionReference {
            paymentMethod.transactionId = transactionId
        } else {
            paymentMethod = TransactionReference(transactionId: transactionId)
        }
        return self
    }

    /// Sets the EMV tag data to be sent along with an EMV transaction.
    /// - Parameter tagData: the EMV tag data
    /// - Returns: AuthorizationBuilder
    public func withTagData(_ tagData: String?) -> AuthorizationBuilder {
        self.tagData = tagData
        return self
    }

    /// Sets the timestamp; where applicable.
    /// - Parameter timestamp: The transaction's timestamp
    /// - Returns: AuthorizationBuilder
    public func withTimestamp(_ timestamp: String?) -> AuthorizationBuilder {
        self.timestamp = timestamp
        return self
    }

    /// Lodging data information for Portico
    /// - Parameter lodgingData: The lodging data
    /// - Returns: AuthorizationBuilder
    public func withLodgingData(_ lodgingData: LodgingData) -> AuthorizationBuilder {
        self.lodgingData = lodgingData
        return self
    }

    public func withAmountEstimated(_ amountEstimated: Bool?) -> AuthorizationBuilder {
        self.amountEstimated = amountEstimated
        return self
    }

    public func withAlias(action: AliasAction, value: String) -> AuthorizationBuilder {
        self.alias = value
        self.aliasAction = action
        return self
    }

    public func withBalanceInquiryType(_ balanceInquiryType: InquiryType) -> AuthorizationBuilder {
        self.balanceInquiryType = balanceInquiryType
        return self
    }

    public func withReplacementCard(_ replacementCard: GiftCard?) -> AuthorizationBuilder {
        self.replacementCard = replacementCard
        return self
    }

    public func withModifier(_ transactionModifier: TransactionModifier) -> AuthorizationBuilder {
        self.transactionModifier = transactionModifier
        return self
    }
    
    public func withPayByLinkData(_ payByLinkData: PayByLinkData) -> AuthorizationBuilder {
        self.payByLinkData = payByLinkData
        return self
    }
    
    public func withPaymentLink(_ paymentLinkId: String?) -> AuthorizationBuilder {
        self.paymentLinkId = paymentLinkId
        return self
    }
    
    public func withPhoneNumber(_ phoneCountryCode: String, number: String, type: PhoneNumberType) -> AuthorizationBuilder {
        let phoneNumber = PhoneNumber()
        phoneNumber.countryCode = phoneCountryCode
        phoneNumber.number = number
        
        switch type {
        case .Home:
            homePhone = phoneNumber
            break
        case .Work:
            workPhone = phoneNumber
            break
        case .Shipping:
            shippingPhone = phoneNumber
            break
        case .Mobile:
            mobilePhone = phoneNumber
            break
        }
        return self
    }
    
    public func withBNPLShippingMethod(_ value: BNPLShippingMethod) -> AuthorizationBuilder {
        guard paymentMethod is BNPL else { return self}
        bnplShippingMethod = value
        return self
    }
    
    public func withRemittanceReference(_ type: RemittanceReferenceType, value: String?) -> AuthorizationBuilder {
        remittanceReferenceType = type
        remittanceReferenceValue = value
        return self
    }

    /// Sets the surcharge amount; where applicable.
    /// - Parameter surchargeAmount: The surcharge amount
    /// - Returns: AuthorizationBuilder
    public func withSurchargeAmount(_ surchargeAmount: NSDecimalNumber?) -> AuthorizationBuilder {
        self.surchargeAmount = surchargeAmount
        return self
    }

    /// Sets the first name; where applicable.
    /// - Parameter firstName: The first name
    /// - Returns: AuthorizationBuilder
    public func withFirstName(_ firstName: String?) -> AuthorizationBuilder {
        self.firstName = firstName
        return self
    }
    
    public func withFraudFilter(_ fraudFilterMode: FraudFilterMode, fraudRules: FraudRuleCollection? = nil)-> AuthorizationBuilder {
        self.fraudFilterMode = fraudFilterMode
        if let rules = fraudRules {
            self.fraudRules = rules
        }
        return self
    }

    /// Sets the last name; where applicable.
    /// - Parameter firstName: The last name
    /// - Returns: AuthorizationBuilder
    public func withLastName(_ lastName: String?) -> AuthorizationBuilder {
        self.lastName = lastName
        return self
    }

    /// Sets unique reference of a stored payment method to use to create a Sale or Refund transaction, instead of the actual payment method details.
    /// - Parameter id: The ID
    /// - Returns: AuthorizationBuilder
    public func withId(_ id: String?) -> AuthorizationBuilder {
        self.id = id
        return self
    }
    
    public func withMerchantCategory(_ value: MerchantCategory) -> AuthorizationBuilder {
        self.merchantCategory = value
        return self
    }

    /// Executes the authorization builder against the gateway.
    /// - Returns: Transaction
    public override func execute(configName: String = "default",
                                 completion: ((Transaction?, Error?) -> Void)?) {

        super.execute(configName: configName) { _, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            do {
                let client = try ServicesContainer.shared.client(configName: configName)
                client.processAuthorization(self, completion: completion)
            } catch {
                completion?(nil, error)
            }
        }
    }

    public func serialize(configName: String = "default") throws -> String? {
        transactionModifier = .hostedRequest
        super.execute(completion: nil)

        let client = try ServicesContainer.shared.client(configName: configName)
        if client.supportsHostedPayments {
            return client.serializeRequest(self)
        }
        throw UnsupportedTransactionException(
            message: "You current gateway does not support hosted payments."
        )
    }

    public override func setupValidations() {

        validations.of(transactionType: [.auth, .sale, .refund, .addValue])
            .with(modifier: TransactionModifier.none)
            .check(propertyName: "amount")?.isNotNil()?
            .check(propertyName: "currency")?.isNotNil()?
            .check(propertyName: "paymentMethod")?.isNotNil()

        validations.of(transactionType: [.auth, .sale])
            .with(modifier: .hostedRequest)
            .check(propertyName: "amount")?.isNotNil()?
            .check(propertyName: "currency")?.isNotNil()

        validations.of(transactionType: .verify)
            .with(modifier: .hostedRequest)
            .check(propertyName: "amount")?.isNotNil()?
            .check(propertyName: "currency")?.isNotNil()

        validations.of(transactionType: [.auth, .sale])
            .with(modifier: .offline)
            .check(propertyName: "amount")?.isNotNil()?
            .check(propertyName: "currency")?.isNotNil()?
            .check(propertyName: "offlineAuthCode")?.isNotNil()

        validations.of(transactionType: .benefitWithdrawal)
            .with(modifier: .cashBack)
            .check(propertyName: "amount")?.isNotNil()?
            .check(propertyName: "currency")?.isNotNil()?
            .check(propertyName: "paymentMethod")?.isNotNil()

        validations.of(transactionType: .balance)
            .check(propertyName: "paymentMethod")?.isNotNil()

        validations.of(transactionType: .alias)
            .check(propertyName: "aliasAction")?.isNotNil()?
            .check(propertyName: "alias")?.isNotNil()

        validations.of(transactionType: .replace)
            .check(propertyName: "replacementCard")?.isNotNil()

        validations.of(paymentMethodType: .ach)
            .check(propertyName: "billingAddress")?.isNotNil()

        validations.of(paymentMethodType: .debit)
            .when(propertyName: "reversalReasonCode")?.isNotNil()?
            .check(propertyName: "transactionType")?.isEqualTo(expected: TransactionType.reversal)

        validations.of(transactionType: [.auth, .sale])
            .with(modifier: .encryptedMobile)
            .check(propertyName: "paymentMethod")?.isNotNil()
        
        validations.of(transactionType: [.auth, .sale])
            .with(modifier: .decryptedMobile)
            .check(propertyName: "paymentMethod")?.isNotNil()

        validations.of(paymentMethodType: .recurring)
            .check(propertyName: "shippingAmt")?.isNil()
        
        validations.of(transactionType: [.auth, .sale])
            .with(modifier: .alternativePaymentMethod)
            .check(propertyName: "paymentMethod")?.isNotNil()?
            .check(propertyName: "amount")?.isNotNil()?
            .check(propertyName: "currency")?.isNotNil()?
            .check(propertyName: "paymentMethod.returnUrl")?.isNotNil()?
            .check(propertyName: "paymentMethod.statusUpdateUrl")?.isNotNil()?
            .check(propertyName: "paymentMethod.accountHolderName")?.isNotNil()
    }
}
