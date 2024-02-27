import Foundation

@objcMembers public class PayFacBuilder<TResult>: BaseBuilder<TResult> {
    let transactionType: TransactionType
    var transactionModifier: TransactionModifier?
    
    /// Primary Bank Account Information - Optional. Used to add a bank account to which funds can be settled
    var bankAccountData: BankAccountData?
    /// User/Merchant Personal Data
    var userPersonalData: UserPersonalData?
    var creditCardInformation: CreditCardData?
    var descriptionPayFac: String?
    var productData: [Product]?
    var personsData: [Person]?
    var page: Int?
    var pageSize: Int?
    var paymentStatistics: PaymentStatistics?
    var statusChangeReason: StatusChangeReason?
    var userReference: UserReference?
    var paymentMethodsFunctions: [String:PaymentMethodFunction]?
    var idempotencyKey: String?
    var userId: String?
    var amount: NSDecimalNumber?
    var accountNumber: String?
    var paymentMethodName: PaymentMethodName?
    var paymentMethodType: PaymentMethodType?
    var currency: String?
    var clientTransactionId: String?
    
    public func withBankAccountData(_ bankAccountData: BankAccountData, paymentMethodFunction: PaymentMethodFunction? = nil) -> PayFacBuilder {
        self.bankAccountData = bankAccountData
        if let paymentMethodFunction = paymentMethodFunction {
            if paymentMethodsFunctions == nil {
                paymentMethodsFunctions = [String: PaymentMethodFunction]()
            }
            paymentMethodsFunctions?[self.bankAccountData?.theClassName ?? ""] = paymentMethodFunction
        }
        return self
    }

    public func withDescription(_ description: String) -> PayFacBuilder {
        self.descriptionPayFac = description
        return self
    }

    public func withProductData(_ productData: [Product]) -> PayFacBuilder {
        self.productData = productData
        return self
    }
    
    public func withPersonsData(_ personsData: [Person]) -> PayFacBuilder {
        self.personsData = personsData
        return self
    }

    public func withUserReference(_ userReference: UserReference?) -> PayFacBuilder {
        self.userReference = userReference
        self.userId = userReference?.userId
        return self
    }

    public func withModifier(_ transactionModifier: TransactionModifier?) -> PayFacBuilder {
        self.transactionModifier = transactionModifier
        return self
    }

    public func withPaymentStatistics(_ paymentStatistics: PaymentStatistics) -> PayFacBuilder {
        self.paymentStatistics = paymentStatistics
        return self
    }

    public func withStatusChangeReason(_ statusChangeReason: StatusChangeReason) -> PayFacBuilder {
        self.statusChangeReason = statusChangeReason
        return self
    }

    /// <summary>
    /// Set the gateway paging criteria for the report
    /// </summary>
    /// <param name="page"></param>
    /// <param name="pageSize"></param>
    /// <returns></returns>
    public func withPaging(_ page: Int, pageSize: Int) -> PayFacBuilder {
        self.page = page
        self.pageSize = pageSize
        return self
    }

    public func withIdempotencyKey(_ value: String) -> PayFacBuilder {
        self.idempotencyKey = value
        return self
    }

    public func withUserPersonalData(_ userPersonalData: UserPersonalData) -> PayFacBuilder {
        self.userPersonalData = userPersonalData
        return self
    }

    public func withCreditCardData(_ creditCardInformation: CreditCardData?, paymentMethodFunction: PaymentMethodFunction? = nil) -> PayFacBuilder {
        self.creditCardInformation = creditCardInformation
        
        if let paymentMethodFunction = paymentMethodFunction {
            if paymentMethodsFunctions == nil {
                paymentMethodsFunctions = [String: PaymentMethodFunction]()
            }
            paymentMethodsFunctions?[self.creditCardInformation?.theClassName ?? ""] = paymentMethodFunction
        }
        return self
    }
    
    public func withAmount(_ amount: NSDecimalNumber? = nil) -> PayFacBuilder {
        self.amount = amount
        return self
    }
    
    public func withAccountNumber(_ accountNumber: String?) -> PayFacBuilder {
        self.accountNumber = accountNumber
        return self
    }
    
    public func withPaymentMethodName(_ paymentMethodName: PaymentMethodName?) -> PayFacBuilder {
        self.paymentMethodName = paymentMethodName
        return self
    }
    
    public func withPaymentMethodType(_ paymentMethodType: PaymentMethodType?) -> PayFacBuilder {
        self.paymentMethodType = paymentMethodType
        return self
    }
    
    public func withCurrency(_ currency: String?) -> PayFacBuilder {
        self.currency = currency
        return self
    }
    
    public func withClientTransactionId(_ clientTransactionId: String?) -> PayFacBuilder {
        self.clientTransactionId = clientTransactionId
        return self
    }

    public init(transactionType: TransactionType, transactionModifier: TransactionModifier? = nil) {
        self.transactionType = transactionType
        self.transactionModifier = transactionModifier
    }

    public override func execute(configName: String = "default",
                                 completion: ((TResult?, Error?) -> Void)?) {

        super.execute(configName: configName) { _, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            do {
                let client = try ServicesContainer.shared.payFacClient(configName: configName)
                client.processBoardingUser(builder: self, completion: completion)
            } catch {
                completion?(nil, error)
            }
        }
    }
    
    public override func setupValidations() {
        validations.of(transactionType: .create)
            .check(propertyName: "userPersonalData")?.isNotNil()
        
        validations.of(transactionType: [.fetch, .edit])
            .with(modifier: .merchant)
            .check(propertyName: "userId")?.isNotNil()
        
        validations.of(transactionType: [.fetch, .edit])
            .with(modifier: .account)
            .check(propertyName: "userId")?.isNotNil()
    }
}
