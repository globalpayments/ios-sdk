import Foundation

@objcMembers public class Secure3dBuilder: BaseBuilder<ThreeDSecure> {
    var accountAgeIndicator: AgeIndicator?
    var accountChangeDate: Date?
    var accountCreateDate: Date?
    var accountChangeIndicator: AgeIndicator?
    var addressMatchIndicator: Bool?
    var amount: NSDecimalNumber?
    var applicationId: String?
    var authenticationSource: AuthenticationSource = .browser
    var authenticationRequestType: AuthenticationRequestType = .paymentTransaction
    var billingAddress: Address?
    var currency: String?
    var customerAccountId: String?
    var customerAuthenticationData: String?
    var customerAuthenticationMethod: CustomerAuthenticationMethod?
    var customerAuthenticationTimestamp: Date?
    var customerEmail: String?
    var deliveryEmail: String?
    var deliveryTimeFrame: DeliveryTimeFrame?
    var encodedData: String?
    var ephemeralPublicKey: JsonDoc?
    var giftCardCount: Int?
    var giftCardCurrency: String?
    var giftCardAmount: NSDecimalNumber?
    var homeCountryCode: String?
    var homeNumber: String?
    var maxNumberOfInstallments: Int?
    var maximumTimeout: Int?
    var merchantData: MerchantDataCollection?
    var messageCategory: MessageCategory = .paymentAuthentication
    var merchantInitiatedRequestType: AuthenticationRequestType?
    var messageVersion: String?
    var methodUrlCompletion: MethodUrlCompletion?
    var mobileCountryCode: String?
    var mobileNumber: String?
    var numberOfAddCardAttemptsInLast24Hours: Int?
    var numberOfPurchasesInLastSixMonths: Int?
    var numberOfTransactionsInLast24Hours: Int?
    var numberOfTransactionsInLastYear: Int?
    var orderCreateDate: Date?
    var orderId: String?
    var orderTransactionType: OrderTransactionType?
    var passwordChangeDate: Date?
    var passwordChangeIndicator: AgeIndicator?
    var paymentAccountCreateDate: Date?
    var paymentAgeIndicator: AgeIndicator?
    var payerAuthenticationResponse: String?
    var paymentMethod: PaymentMethod?
    var preOrderAvailabilityDate: Date?
    var preOrderIndicator: PreOrderIndicator?
    var previousSuspiciousActivity: Bool?
    var priorAuthenticationData: String?
    var priorAuthenticationMethod: PriorAuthenticationMethod?
    var priorAuthenticationTransactionId: String?
    var priorAuthenticationTimestamp: Date?
    var recurringAuthorizationExpiryDate: Date?
    var recurringAuthorizationFrequency: Int?
    var referenceNumber: String?
    var reorderIndicator: ReorderIndicator?
    var sdkInterface: SdkInterface?
    var sdkTransactionId: String?
    var sdkUiTypes: [SdkUiType]?
    var serverTransactionId: String? {
        get {
            if threeDSecure != nil {
                return threeDSecure?.serverTransactionId
            }
            return nil
        }
    }
    var shippingAddress: Address?
    var shippingAddressCreateDate: Date?
    var shippingAddressUsageIndicator: AgeIndicator?
    var shippingMethod: ShippingMethod?
    var shippingNameMatchesCardHolderName: Bool?
    var threeDSecure: ThreeDSecure?
    var transactionType: TransactionType?
    var secure3dVersion: Secure3dVersion? {
        get {
            if threeDSecure != nil {
                return threeDSecure?.version
            }
            return nil
        }
    }
    var workCountryCode: String?
    var workNumber: String?

    public func withAddress(_ address: Address?) -> Secure3dBuilder {
        return withAddress(address, .billing)
    }

    public func withAddress(_ address: Address?,
                            _ addressType: AddressType?) -> Secure3dBuilder {
        if addressType == .billing {
            self.billingAddress = address
        } else {
            self.shippingAddress = address
        }
        return self
    }

    public func withAccountAgeIndicator(_ accountAgeIndicator: AgeIndicator?) -> Secure3dBuilder {
        self.accountAgeIndicator = accountAgeIndicator
        return self
    }

    public func withAccountChangeDate(_ accountChangeDate: Date?) -> Secure3dBuilder {
        self.accountChangeDate = accountChangeDate
        return self
    }

    public func withAccountCreateDate(_ accountCreateDate: Date?) -> Secure3dBuilder {
        self.accountCreateDate = accountCreateDate
        return self
    }

    public func withAccountChangeIndicator(_ accountChangeIndicator: AgeIndicator?) -> Secure3dBuilder {
        self.accountChangeIndicator = accountChangeIndicator
        return self
    }

    public func withAddressMatchIndicator(_ addressMatchIndicator: Bool?) -> Secure3dBuilder {
        self.addressMatchIndicator = addressMatchIndicator
        return self
    }

    public func withAmount(_ amount: NSDecimalNumber?) -> Secure3dBuilder {
        self.amount = amount
        return self
    }

    public func withApplicationId(_ applicationId: String?) -> Secure3dBuilder {
        self.applicationId = applicationId
        return self
    }

    public func withAuthenticationSource(_ authenticationSource: AuthenticationSource) -> Secure3dBuilder {
        self.authenticationSource = authenticationSource
        return self
    }

    public func withAuthenticationRequestType(_ authenticationRequestType: AuthenticationRequestType) -> Secure3dBuilder {
        self.authenticationRequestType = authenticationRequestType
        return self
    }

    public func withCurrency(_ currency: String?) -> Secure3dBuilder {
        self.currency = currency
        return self
    }

    public func withCustomerAccountId(_ customerAccountId: String?) -> Secure3dBuilder {
        self.customerAccountId = customerAccountId
        return self
    }

    public func withCustomerAuthenticationData(_ customerAuthenticationData: String?) -> Secure3dBuilder {
        self.customerAuthenticationData = customerAuthenticationData
        return self
    }

    public func withCustomerAuthenticationMethod(_ customerAuthenticationMethod: CustomerAuthenticationMethod) -> Secure3dBuilder {
        self.customerAuthenticationMethod = customerAuthenticationMethod
        return self
    }

    public func withCustomerAuthenticationTimestamp(_ customerAuthenticationTimestamp: Date?) -> Secure3dBuilder {
        self.customerAuthenticationTimestamp = customerAuthenticationTimestamp
        return self
    }

    public func withCustomerEmail(_ customerEmail: String) -> Secure3dBuilder {
        self.customerEmail = customerEmail
        return self
    }

    public func withDeliveryEmail(_ deliveryEmail: String?) -> Secure3dBuilder {
        self.deliveryEmail = deliveryEmail
        return self
    }

    public func withDeliveryTimeFrame(_ deliveryTimeFrame: DeliveryTimeFrame?) -> Secure3dBuilder {
        self.deliveryTimeFrame = deliveryTimeFrame
        return self
    }

    public func withEncodedData(_ encodedData: String?) -> Secure3dBuilder {
        self.encodedData = encodedData
        return self
    }

    //    public Secure3dBuilder WithEphemeralPublicKey(string ephemeralPublicKey) {
    //        EphemeralPublicKey = JsonDoc.Parse(ephemeralPublicKey);
    //        return this;
    //    }

    public func withGiftCardCount(_ giftCardCount: Int?) -> Secure3dBuilder {
        self.giftCardCount = giftCardCount
        return self
    }

    public func withGiftCardCurrency(_ giftCardCurrency: String?) -> Secure3dBuilder {
        self.giftCardCurrency = giftCardCurrency
        return self
    }

    public func withGiftCardAmount(_ giftCardAmount: NSDecimalNumber?) -> Secure3dBuilder {
        self.giftCardAmount = giftCardAmount
        return self
    }

    public func withHomeNumber(_ homeNumber: String?,
                               _ homeCountryCode: String?) -> Secure3dBuilder {
        self.homeNumber = homeNumber
        self.homeCountryCode = homeCountryCode
        return self
    }

    public func withMaxNumberOfInstallments(_ maxNumberOfInstallments: Int?) -> Secure3dBuilder {
        self.maxNumberOfInstallments = maxNumberOfInstallments
        return self
    }

    public func withMaximumTimeout(_ maximumTimeout: Int?) -> Secure3dBuilder {
        self.maximumTimeout = maximumTimeout
        return self
    }

    public func withMerchantData(_ merchantData: MerchantDataCollection) -> Secure3dBuilder {
        self.merchantData = merchantData
        if self.merchantData != nil {
            if self.threeDSecure == nil {
                self.threeDSecure = ThreeDSecure()
            }
            self.threeDSecure?.merchantData = merchantData
        }
        return self
    }

    public func withMessageCategory(_ messageCategory: MessageCategory) -> Secure3dBuilder {
        self.messageCategory = messageCategory
        return self
    }

    public func withMerchantInitiatedRequestType(_ merchantInitiatedRequestType: AuthenticationRequestType?) -> Secure3dBuilder {
        self.merchantInitiatedRequestType = merchantInitiatedRequestType
        return self
    }

    public func withMessageVersion(_ messageVersion: String?) -> Secure3dBuilder {
        self.messageVersion = messageVersion
        return self
    }

    public func withMethodUrlCompletion(_ methodUrlCompletion: MethodUrlCompletion?) -> Secure3dBuilder {
        self.methodUrlCompletion = methodUrlCompletion
        return self
    }

    public func withMobileNumber(_ mobileNumber: String?,
                                 _ mobileCountryCode: String?) -> Secure3dBuilder {
        self.mobileNumber = mobileNumber
        self.mobileCountryCode = mobileCountryCode
        return self
    }

    public func withNumberOfAddCardAttemptsInLast24Hours(_ numberOfAddCardAttemptsInLast24Hours: Int?) -> Secure3dBuilder {
        self.numberOfAddCardAttemptsInLast24Hours = numberOfAddCardAttemptsInLast24Hours
        return self
    }

    public func withNumberOfPurchasesInLastSixMonths(_ numberOfPurchasesInLastSixMonths: Int?) -> Secure3dBuilder {
        self.numberOfPurchasesInLastSixMonths = numberOfPurchasesInLastSixMonths
        return self
    }

    public func withNumberOfTransactionsInLast24Hours(_ numberOfTransactionsInLast24Hours: Int?) -> Secure3dBuilder {
        self.numberOfTransactionsInLast24Hours = numberOfTransactionsInLast24Hours
        return self
    }

    public func withNumberOfTransactionsInLastYear(_ numberOfTransactionsInLastYear: Int?) -> Secure3dBuilder {
        self.numberOfTransactionsInLastYear = numberOfTransactionsInLastYear
        return self
    }

    public func withOrderCreateDate(_ orderCreateDate: Date?) -> Secure3dBuilder {
        self.orderCreateDate = orderCreateDate
        return self
    }

    public func withOrderId(_ orderId: String?) -> Secure3dBuilder {
        self.orderId = orderId
        return self
    }

    public func withOrderTransactionType(_ orderTransactionType: OrderTransactionType?) -> Secure3dBuilder {
        self.orderTransactionType = orderTransactionType
        return self
    }

    public func withPasswordChangeDate(_ passwordChangeDate: Date?) -> Secure3dBuilder {
        self.passwordChangeDate = passwordChangeDate
        return self
    }

    public func withPasswordChangeIndicator(_ passwordChangeIndicator: AgeIndicator?) -> Secure3dBuilder {
        self.passwordChangeIndicator = passwordChangeIndicator
        return self
    }

    public func withPaymentAccountCreateDate(_ paymentAccountCreateDate: Date?) -> Secure3dBuilder {
        self.paymentAccountCreateDate = paymentAccountCreateDate
        return self
    }

    public func withPaymentAccountAgeIndicator(_ paymentAgeIndicator: AgeIndicator) -> Secure3dBuilder {
        self.paymentAgeIndicator = paymentAgeIndicator
        return self
    }

    public func withPayerAuthenticationResponse(_ payerAuthenticationResponse: String?) -> Secure3dBuilder {
        self.payerAuthenticationResponse = payerAuthenticationResponse
        return self
    }

    public func withPaymentMethod(_ paymentMethod: PaymentMethod?) -> Secure3dBuilder {
        self.paymentMethod = paymentMethod
        if let paymentMethod = paymentMethod as? Secure3d,
            let secureEcom = paymentMethod.threeDSecure {
            threeDSecure = secureEcom
        }
        return self
    }

    public func withPreOrderAvailabilityDate(_ preOrderAvailabilityDate: Date?) -> Secure3dBuilder {
        self.preOrderAvailabilityDate = preOrderAvailabilityDate
        return self
    }

    public func withPreOrderIndicator(_ preOrderIndicator: PreOrderIndicator?) -> Secure3dBuilder {
        self.preOrderIndicator = preOrderIndicator
        return self
    }

    public func withPreviousSuspiciousActivity(_ previousSuspiciousActivity: Bool?) -> Secure3dBuilder {
        self.previousSuspiciousActivity = previousSuspiciousActivity
        return self
    }

    public func withPriorAuthenticationData(_ priorAuthenticationData: String?) -> Secure3dBuilder {
        self.priorAuthenticationData = priorAuthenticationData
        return self
    }

    public func withPriorAuthenticationMethod(_ priorAuthenticationMethod: PriorAuthenticationMethod?) -> Secure3dBuilder {
        self.priorAuthenticationMethod = priorAuthenticationMethod
        return self
    }

    public func withPriorAuthenticationTransactionId(_ priorAuthenticationTransactionId: String?) -> Secure3dBuilder {
        self.priorAuthenticationTransactionId = priorAuthenticationTransactionId
        return self
    }

    public func withPriorAuthenticationTimestamp(_ priorAuthenticationTimestamp: Date?) -> Secure3dBuilder {
        self.priorAuthenticationTimestamp = priorAuthenticationTimestamp
        return self
    }

    public func withRecurringAuthorizationExpiryDate(_ recurringAuthorizationExpiryDate: Date?) -> Secure3dBuilder {
        self.recurringAuthorizationExpiryDate = recurringAuthorizationExpiryDate
        return self
    }

    public func withRecurringAuthorizationFrequency(_ recurringAuthorizationFrequency: Int?) -> Secure3dBuilder {
        self.recurringAuthorizationFrequency = recurringAuthorizationFrequency
        return self
    }

    public func withReferenceNumber(_ referenceNumber: String?) -> Secure3dBuilder {
        self.referenceNumber = referenceNumber
        return self
    }

    public func withReorderIndicator(_ reorderIndicator: ReorderIndicator?) -> Secure3dBuilder {
        self.reorderIndicator = reorderIndicator
        return self
    }

    public func withSdkInterface(_ sdkInterface: SdkInterface?) -> Secure3dBuilder {
        self.sdkInterface = sdkInterface
        return self
    }

    public func withSdkTransactionId(_ sdkTransactionId: String?) -> Secure3dBuilder {
        self.sdkTransactionId = sdkTransactionId
        return self
    }

    public func withSdkUiTypes(_ sdkUiTypes: [SdkUiType]?) -> Secure3dBuilder {
        self.sdkUiTypes = sdkUiTypes
        return self
    }

    public func withServerTransactionId(_ serverTransactionId: String?) -> Secure3dBuilder {
        if self.threeDSecure == nil {
            self.threeDSecure = ThreeDSecure()
        }
        threeDSecure?.serverTransactionId = serverTransactionId
        return self
    }

    public func withShippingAddressCreateDate(_ shippingAddressCreateDate: Date?) -> Secure3dBuilder {
        self.shippingAddressCreateDate = shippingAddressCreateDate
        return self
    }

    public func withShippingAddressUsageIndicator(_ shippingAddressUsageIndicator: AgeIndicator?) -> Secure3dBuilder {
        self.shippingAddressUsageIndicator = shippingAddressUsageIndicator
        return self
    }

    public func withShippingMethod(_ shippingMethod: ShippingMethod?) -> Secure3dBuilder {
        self.shippingMethod = shippingMethod
        return self
    }

    public func withShippingNameMatchesCardHolderName(_ shippingNameMatchesCardHolderName: Bool?) -> Secure3dBuilder {
        self.shippingNameMatchesCardHolderName = shippingNameMatchesCardHolderName
        return self
    }

    public func withThreeDSecure(_ threeDSecure: ThreeDSecure?) -> Secure3dBuilder {
        self.threeDSecure = threeDSecure
        return self
    }

    public func withTransactionType(_ transactionType: TransactionType?) -> Secure3dBuilder {
        self.transactionType = transactionType
        return self
    }

    public func withWorkNumber(_ workNumber: String?,
                               _ workCountryCode: String?) -> Secure3dBuilder {
        self.workNumber = workNumber
        self.workCountryCode = workCountryCode
        return self
    }

    public required init(transactionType: TransactionType) {
        self.transactionType = transactionType
    }

    // HELPER METHOD FOR THE CONNECTOR
    public var hasMobileFields: Bool {
        return !applicationId.isNilOrEmpty ||
            maximumTimeout != nil ||
            referenceNumber != nil ||
            !sdkTransactionId.isNilOrEmpty ||
            !encodedData.isNilOrEmpty ||
            sdkInterface != nil ||
            sdkUiTypes != nil
    }

    public var hasPriorAuthenticationData: Bool {
        return priorAuthenticationMethod != nil ||
            !priorAuthenticationTransactionId.isNilOrEmpty ||
            priorAuthenticationTimestamp != nil ||
            !priorAuthenticationData.isNilOrEmpty
    }

    public var hasRecurringAuthData: Bool {
        return maxNumberOfInstallments != nil ||
            recurringAuthorizationFrequency != nil ||
            recurringAuthorizationExpiryDate != nil
    }

    public var hasPayerLoginData: Bool {
        return !customerAuthenticationData.isNilOrEmpty ||
            customerAuthenticationTimestamp != nil ||
            customerAuthenticationMethod != nil
    }

    public override func execute(configName: String = "default",
                                 completion: ((ThreeDSecure?, Error?) -> Void)?) {
        execute(version: .any, configName: configName, completion: completion)
    }

    public func execute(version: Secure3dVersion,
                        configName: String = "default",
                        completion: ((ThreeDSecure?, Error?) -> Void)?) {

        var version: Secure3dVersion = version
        do {
            try validations.validate(builder: self)
        } catch {
            completion?(nil, error)
        }

        // setup return object
        var rvalue = threeDSecure
        if rvalue == nil {
            rvalue = ThreeDSecure()
            rvalue?.version = version
        }

        // working version
        if let workingVersion = rvalue?.version {
            version = workingVersion
        }

        // get the provider
        let provider = try? ServicesContainer.shared.secure3DProvider(
            configName: configName,
            version: version
        )
        if provider != nil {
            var canDowngrade = false
            if provider?.getVersion() == .two && version == .any {
                do {
                    _ = try ServicesContainer.shared.secure3DProvider(
                        configName: configName,
                        version: .one
                    )
                    canDowngrade = true
                } catch { /* NOT CONFIGURED */ }
            }

            /// process the request, capture any exceptions which might have been thrown
            provider?.processSecure3d(self, completion: { response in
                if response == nil && canDowngrade {
                    return execute(version: .one, completion: completion)
                }

                if let response = response,
                    let transactionType = transactionType {

                    switch transactionType {
                    case .verifyEnrolled:
                        if let threeDSecure = response.threeDSecure,
                            let version = provider?.getVersion() {
                            rvalue = threeDSecure
                            if ["True", "Y"].contains(rvalue?.enrolled) {
                                rvalue?.amount = amount
                                rvalue?.currency = currency
                                rvalue?.orderId = response.orderId
                                rvalue?.version = version
                            } else if canDowngrade {
                                return execute(version: .one, completion: completion)
                            }
                        } else if canDowngrade {
                            return execute(version: .one, completion: completion)
                        }
                    case .initiateAuthentication,
                         .verifySignature:
                        rvalue?.merge(secureEcom: response.threeDSecure)
                    default:
                        break
                    }
                }
            })
        }

        completion?(rvalue, nil)
    }

    public override func setupValidations() {

        validations.of(transactionType: .verifyEnrolled)
            .check(propertyName: "paymentMethod")?.isNotNil()

        validations.of(transactionType: .verifyEnrolled)
            .when(propertyName: "paymentMethod")?.isNotNil()?
            .check(propertyName: "paymentMethod")?.conformsTo(protocol: Secure3d.self)

        validations.of(transactionType: .verifySignature)
            .when(propertyName: "version")?.isEqualTo(expected: Secure3dVersion.one)?
            .check(propertyName: "threeDSecure")?.isNotNil()?
            .when(propertyName: "version")?.isEqualTo(expected: Secure3dVersion.one)?
            .check(propertyName: "payerAuthenticationResponse")?.isNotNil()

        validations.of(transactionType: .verifySignature)
            .when(propertyName: "version")?.isEqualTo(expected: Secure3dVersion.two)?
            .check(propertyName: "serverTransactionId")?.isNotNil()

        validations.of(transactionType: .initiateAuthentication)
            .check(propertyName: "threeDSecure")?.isNotNil()

        validations.of(transactionType: .initiateAuthentication)
            .when(propertyName: "paymentMethod")?.isNotNil()?
            .check(propertyName: "paymentMethod")?.conformsTo(protocol: Secure3d.self)

        validations.of(transactionType: .initiateAuthentication)
            .when(propertyName: "merchantInitiatedRequestType")?.isNotNil()?
            .check(propertyName: "merchantInitiatedRequestType")?.isNotEqualTo(expected: AuthenticationRequestType.paymentTransaction)

        validations.of(transactionType: .initiateAuthentication)
            .when(propertyName: "accountAgeIndicator")?.isNotNil()?
            .check(propertyName: "accountAgeIndicator")?.isNotEqualTo(expected: AgeIndicator.noChange)
        
        validations.of(transactionType: .initiateAuthentication)
            .when(propertyName: "passwordChangeIndicator")?.isNotNil()?
            .check(propertyName: "passwordChangeIndicator")?.isNotEqualTo(expected: AgeIndicator.noAccount)

        validations.of(transactionType: .initiateAuthentication)
            .when(propertyName: "shippingAddressUsageIndicator")?.isNotNil()?
            .check(propertyName: "shippingAddressUsageIndicator")?.isNotEqualTo(expected: AgeIndicator.noChange)?
            .when(propertyName: "shippingAddressUsageIndicator")?.isNotNil()?
            .check(propertyName: "shippingAddressUsageIndicator")?.isNotEqualTo(expected: AgeIndicator.noAccount)
    }
}
