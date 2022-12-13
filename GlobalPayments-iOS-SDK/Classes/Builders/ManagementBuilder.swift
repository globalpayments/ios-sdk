import Foundation

/// Used to follow up transactions for the supported payment method types.
@objcMembers public class ManagementBuilder: TransactionBuilder<Transaction> {
    /// Request amount
    var amount: NSDecimalNumber?
    /// Request authorization amount
    var authAmount: NSDecimalNumber?
    var authorizationCode: String? {
        guard let paymentMethod = paymentMethod as? TransactionReference else {
            return nil
        }
        return paymentMethod.authCode
    }
    var clientTransactionId: String? {
        guard let paymentMethod = paymentMethod as? TransactionReference else {
            return nil
        }
        return paymentMethod.clientTransactionId
    }
    var batchReference: String?
    var commercialData: CommercialData?
    /// Request currency
    var currency: String?
    var customerId: String?
    var managementBuilderDescription: String?
    /// Request gratuity
    var gratuity: NSDecimalNumber?
    var idempotencyKey: String?
    /// Request purchase order number
    var poNumber: String?
    /// Request tax amount
    var taxAmount: NSDecimalNumber?
    var taxType: TaxType?
    /// Previous request's transaction reference
    var alternativePaymentType: String?
    var orderId: String? {
        guard let paymentMethod = paymentMethod as? TransactionReference else {
            return nil
        }
        return paymentMethod.orderId
    }
    var payerAuthenticationResponse: String?
    var reasonCode: ReasonCode?
    var supplementaryData: [String: [String]]?
    var multiCapturePaymentCount: Int?
    var multiCaptureSequence: Int?
    var invoiceNumber: String?
    var lodgingData: LodgingData?
    var tagData: String?
    var transactionId: String? {
        guard let paymentMethod = paymentMethod as? TransactionReference else {
            return nil
        }
        return paymentMethod.transactionId
    }
    var voidReason: VoidReason?

    /// Sets the current transaction's amount.
    /// - Parameter amount: The amount
    /// - Returns: ManagementBuilder
    public func withAmount(_ amount: NSDecimalNumber?) -> ManagementBuilder {
        self.amount = amount
        return self
    }

    /// Sets the current transaction's authorized amount; where applicable.
    /// - Parameter authAmount: The authorized amount
    /// - Returns: ManagementBuilder
    public func withAuthAmount(_ authAmount: NSDecimalNumber?) -> ManagementBuilder {
        self.authAmount = authAmount
        return self
    }

    /// Sets the Multicapture value as true/false.
    /// - Parameters:
    /// - Returns: ManagementBuilder
    public func withMultiCapture(sequence: Int? = 1, paymentCount: Int? = 1) -> ManagementBuilder {
        self.multiCapture = true
        self.multiCaptureSequence = sequence
        self.multiCapturePaymentCount = paymentCount
        return self
    }

    /// Sets the current batch reference
    /// - Parameter batchReference: The batch reference
    /// - Returns: ManagementBuilder
    public func withBatchReference(_ batchReference: String?) -> ManagementBuilder {
        self.batchReference = batchReference
        return self
    }

    public func withCommercialData(_ commercialData: CommercialData) -> ManagementBuilder {
        self.commercialData = commercialData
        if commercialData.commercialIndicator == .level_II {
            transactionModifier = .levelII
        } else {
            transactionModifier = .levelIII
        }
        return self
    }

    /// Sets the currency.
    /// The formatting for the supplied value will currently depend on the configured gateway's requirements.
    /// - Parameter currency: The currency
    /// - Returns: ManagementBuilder
    public func withCurrency(_ currency: String?) -> ManagementBuilder {
        self.currency = currency
        return self
    }

    /// Sets the customer ID; where applicable.
    /// - Parameter customerId: The customer ID
    /// - Returns: ManagementBuilder
    public func withCustomerId(_ customerId: String) -> ManagementBuilder {
        self.customerId = customerId
        return self
    }

    /// Sets the transaction's description.
    /// - Parameter description: This value is not guaranteed to be sent in the authorization or settlement process.
    /// - Returns: ManagementBuilder
    public func withDescription(_ description: String) -> ManagementBuilder {
        self.managementBuilderDescription = description
        return self
    }

    /// Sets the gratuity amount; where applicable.
    /// - Parameter gratuity: This value is information only and does not affect the authorization amount.
    /// - Returns: ManagementBuilder
    public func withGratuity(_ gratuity: NSDecimalNumber?) -> ManagementBuilder {
        self.gratuity = gratuity
        return self
    }

    /// Field submitted in the request that is used to ensure idempotency is maintained within the action
    /// - Parameter idempotencyKey: The idempotency key
    /// - Returns: ManagementBuilder
    public func withIdempotencyKey(_ idempotencyKey: String?) -> ManagementBuilder {
        self.idempotencyKey = idempotencyKey
        return self
    }

    /// Sets the invoice number; where applicable.
    /// - Parameter invoiceNumber: The invoice number
    /// - Returns: ManagementnBuilder
    public func withInvoiceNumber(_ invoiceNumber: String) -> ManagementBuilder {
        self.invoiceNumber = invoiceNumber
        return self
    }

    public func withPayerAuthenticationResponse(_ response: String) -> ManagementBuilder {
        self.payerAuthenticationResponse = response
        return self
    }

    func withPaymentMethod(_ paymentMethod: PaymentMethod) -> ManagementBuilder {
        self.paymentMethod = paymentMethod
        return self
    }

    /// Sets the reason code for the transaction.
    /// - Parameter reasonCode: The reason code
    /// - Returns: ManagementBuilder
    public func withReasonCode(_ reasonCode: ReasonCode?) -> ManagementBuilder {
        self.reasonCode = reasonCode
        return self
    }

    public func withSupplementaryData(type: String, values: [String]) -> ManagementBuilder {
        if supplementaryData == nil {
            supplementaryData = [String: [String]]()
        }
        supplementaryData?[type] = values
        return self
    }

    public func withModifier(_ modifier: TransactionModifier) -> ManagementBuilder {
        self.transactionModifier = modifier
        return self
    }

    /// Lodging data information for Portico implementation
    /// - Parameter lodgingData: The lodging data
    /// - Returns: ManagementBuilder
    public func withLodgingData(_ lodgingData: LodgingData) -> ManagementBuilder {
        self.lodgingData = lodgingData
        return self
    }
    
    /// Sets the EMV tag data to be sent along with an EMV transaction.
    /// - Parameter tagData: the EMV tag data
    /// - Returns: ManagementBuilder
    public func withTagData(_ tagData: String?) -> ManagementBuilder {
        self.tagData = tagData
        return self
    }

    public func withVoidReason(_ voidReason: VoidReason?) -> ManagementBuilder {
        self.voidReason = voidReason
        return self
    }

    public override func execute(configName: String = "default",
                                 completion: ((Transaction?, Error?) -> Void)?) {

        super.execute(configName: configName) { _, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            do {
                try ServicesContainer.shared
                    .client(configName: configName)
                    .manageTransaction(self, completion: { transaction, error in
                        completion?(transaction, error)
                    })
            } catch {
                completion?(nil, error)
            }
        }
    }

    public override func setupValidations() {

        validations.of(transactionType: [.capture, .edit, .hold, .release])
            .check(propertyName: "transactionId")?.isNotNil()

        validations.of(transactionType: .refund)
            .when(propertyName: "amount")?.isNotNil()?
            .check(propertyName: "currency")?.isNotNil()

        validations.of(transactionType: .verifySignature)
            .check(propertyName: "payerAuthenticationResponse")?.isNotNil()?
            .check(propertyName: "amount")?.isNotNil()?
            .check(propertyName: "currency")?.isNotNil()?
            .check(propertyName: "orderId")?.isNotNil()

        validations.of(transactionType: [.tokenDelete, .tokenUpdate])
            .check(propertyName: "paymentMethod")?.isNotNil()

        validations.of(transactionType: .tokenUpdate)
            .check(propertyName: "paymentMethod")?.isInstanceOf(type: CreditCardData.self)

        validations.of(transactionType: [.capture, .edit, .hold, .release, .tokenUpdate, .tokenDelete, .verifySignature, .refund])
            .check(propertyName: "voidReason")?.isNil()
    }
}

extension ManagementBuilder: CustomReflectable {

    public var customMirror: Mirror {
        return Mirror(self, children: [
            "authorizationCode": authorizationCode as Any,
            "clientTransactionId": transactionId as Any,
            "orderId": orderId as Any,
            "transactionId": transactionId as Any
            ]
        )
    }
}
