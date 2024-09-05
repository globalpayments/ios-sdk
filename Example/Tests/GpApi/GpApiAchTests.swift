import XCTest
import GlobalPayments_iOS_SDK

final class GpApiAchTests: XCTestCase {
    
    private static let ACH_CONFIG = "ach_config"
    private static let ACH_APP_ID = "A1feRdMmEB6m0Y1aQ65H0bDi9ZeAEB2t"
    private static let ACH_APP_KEY = "5jPt1OpB6LLitgi7"
    
    private static var achConfig: GpApiConfig = {
        GpApiConfig(
            appId: ACH_APP_ID,
            appKey: ACH_APP_KEY,
            channel: .cardNotPresent
        )
    }()

    private var eCheckData: eCheck!
    private var address: Address!
    private var customer: Customer!

    private let CURRENCY = "USD"
    private let AMOUNT: NSDecimalNumber = 10.0

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent
        ))
        
        try? ServicesContainer.configureService(config: achConfig, configName: ACH_CONFIG)
    }

    override func setUp() {
        super.setUp()

        address = Address()
        address.streetAddress1 = "Apartment 852"
        address.streetAddress2 = "Complex 741"
        address.streetAddress3 = "no"
        address.city = "Chicago"
        address.postalCode = "5001"
        address.state = "IL"
        address.countryCode = "US"

        let bankAddress = Address()
        bankAddress.streetAddress1 = "12000 Smoketown Rd"
        bankAddress.streetAddress2 = "Apt 3B"
        bankAddress.streetAddress3 = "no"
        bankAddress.city = "Mesa"
        bankAddress.postalCode = "22192"
        bankAddress.state = "AZ"
        bankAddress.countryCode = "US"

        eCheckData = eCheck()
        eCheckData.accountNumber = "1234567890"
        eCheckData.routingNumber = "122000030"
        eCheckData.accountType = .saving
        eCheckData.secCode = SecCode.web.mapped(for: .gpApi)
        eCheckData.checkReference = "123"
        eCheckData.merchantNotes = "123"
        eCheckData.bankName = "First Union"
        eCheckData.checkHolderName = "Jane Doe"
        eCheckData.bankAddress = bankAddress

        customer = Customer()
        customer.key = "e193c21a-ce64-4820-b5b6-8f46715de931"
        customer.firstName = "James"
        customer.lastName = "Mason"
        customer.dateOfBirth = "1980-01-01"
        customer.mobilePhone = "+35312345678"
        customer.homePhone = "+11234589"
    }

    func test_check_sale() {
        // GIVEN
        let expectation = expectation(description: "eCheck Charge Expectation")
        var response: Transaction?
        var error: Error?

        // WHEN
        eCheckData.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withAddress(address)
            .withCustomer(customer)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        assertResponse(response, transactionStatus: .captured)
    }

    func test_check_refund() {
        // GIVEN
        let expectation = expectation(description: "eCheck Charge Expectation")
        var response: Transaction?
        var error: Error?

        // WHEN
        eCheckData.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withAddress(address)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        assertResponse(response, transactionStatus: .captured)
    }

    func test_check_refund_existing_sale() {
        // GIVEN
        let amount: NSDecimalNumber = 1.29
        let reportingExecuteExpectation = expectation(description: "Check Refund Expectation")
        let startDate = Date().addYears(-1)
        let endDate = Date().addDays(-2)
        let paymentType = PaymentType.sale
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionsSummary: TransactionSummary?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(paymentType)
            .and(searchCriteria: .startDate, value: startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .and(searchCriteria: .paymentMethodName, value: PaymentMethodName.bankTransfer)
            .and(dataServiceCriteria: .amount, value: amount)
            .execute {
                transactionsSummary = $0?.results.first
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNil(transactionsSummaryError)
        XCTAssertNotNil(transactionsSummary)
        XCTAssertEqual(amount, transactionsSummary?.amount)

        // GIVEN
        let refundExpectation = expectation(description: "Refund Expectation")
        var response: Transaction?
        var error: Error?
        let transaction = Transaction()
        transaction.transactionId = transactionsSummary?.transactionId
        transaction.paymentMethodType = .ach

        // WHEN
        transaction.refund()
            .withCurrency(CURRENCY)
            .execute {
                response = $0
                error = $1
                refundExpectation.fulfill()
            }

        // THEN
        wait(for: [refundExpectation], timeout: 10.0)
        XCTAssertNil(error)
        assertResponse(response, transactionStatus: .captured)
    }

    func test_check_reauthorize() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "Reauth Check Expectation")
        let startDate = Date().addYears(-1)
        let endDate = Date().addDays(-2)
        let paymentType = PaymentType.sale
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        let eCheckReauth = eCheck()
        eCheckReauth.secCode = SecCode.ppd.mapped(for: .gpApi)
        eCheckReauth.accountNumber = "051904524"
        eCheckReauth.routingNumber = "123456780"
        let amount: NSDecimalNumber = 1.29

        var transactionsSummary: TransactionSummary?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(paymentType)
            .and(searchCriteria: .startDate, value: startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .and(searchCriteria: .paymentMethodName, value: PaymentMethodName.bankTransfer)
            .and(dataServiceCriteria: .amount, value: amount)
            .execute {
                transactionsSummary = $0?.results.first
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNil(transactionsSummaryError)
        XCTAssertNotNil(transactionsSummary)
        XCTAssertEqual(amount, transactionsSummary?.amount)

        // GIVEN
        let reauthExpectation = expectation(description: "Reauth Expectation")
        var response: Transaction?
        var error: Error?
        let transaction = Transaction()
        transaction.transactionId = transactionsSummary?.transactionId
        transaction.paymentMethodType = .ach

        // WHEN
        transaction.reauthorize()
            .withDescription("Resubmitting \(transaction.referenceNumber ?? "")")
            .WithBankTransferData(eCheckReauth)
            .execute {
                response = $0
                error = $1
                reauthExpectation.fulfill()
            }

        // THEN
        wait(for: [reauthExpectation], timeout: 10.0)
        XCTAssertNil(error)
        assertResponse(response, transactionStatus: .captured)
    }
    
   func test_credit_sale_then_split() {
       // GIVEN
       let merchantsExpectation = expectation(description: "Get Merchants Expectation")
       var merchantSummary: MerchantSummary?
       var merchantSplitting: MerchantSummary?
       var merchantsError: Error?
       
       // WHEN
       getMerchants {
           merchantSummary = $0?.results.first
           merchantSplitting = $0?.results.first(where: { merchant in
               merchant.id != merchantSummary?.id
           })
           merchantsError = $1
           merchantsExpectation.fulfill()
       }
       
       // THEN
       wait(for: [merchantsExpectation], timeout: 10.0)
       XCTAssertNil(merchantsError)
       XCTAssertNotNil(merchantSummary)
       XCTAssertNotNil(merchantSplitting)
       
       let merchantId = merchantSummary?.id ?? ""
       let accountProcessing = getAccountByType(merchantId: merchantId, type: .TRANSACTION_PROCESSING)
       
       // GIVEN
       let config = Self.achConfig
       let merchantConfigName = "config_" + merchantId
       config.merchantId = merchantId
       config.accessTokenInfo = AccessTokenInfo(transactionProcessingAccountID: accountProcessing?.id)
       try? ServicesContainer.configureService(config: config, configName: merchantConfigName)
      
       let eCheckExpectation = expectation(description: "eCheck Charge Expectation")
       var eCheckResponse: Transaction?
       var eCheckError: Error?

       // WHEN
       eCheckData.charge(amount: AMOUNT)
           .withCurrency(CURRENCY)
           .withAddress(address)
           .withCustomer(customer)
           .execute(configName: merchantConfigName) {
               eCheckResponse = $0
               eCheckError = $1
               eCheckExpectation.fulfill()
           }

       // THEN
       wait(for: [eCheckExpectation], timeout: 10.0)
       XCTAssertNil(eCheckError)
       assertResponse(eCheckResponse, transactionStatus: .captured)
       
       // WHEN
       let accountRecipient = getAccountByType(merchantId: merchantId, type: .FUND_MANAGEMENT)
       let accountSplitting = getAccountByType(merchantId: merchantSplitting?.id ?? "", type: .FUND_MANAGEMENT)
       
       // THEN
       XCTAssertNotNil(accountRecipient)
       XCTAssertNotNil(accountSplitting)
       
       // GIVEN
       let fundsData = FundsData()
       fundsData.merchantId = merchantId
       fundsData.recipientAccountId = accountSplitting?.id
       let splitExpectation = expectation(description: "Transaction Split Expectation")
       var splitResponse: Transaction?
       var splitError: Error?
       
       
       // WHEN
       eCheckResponse?.split(amount: 8.00)
           .withFundsData(fundsData)
           .withReference("Split Identifier")
           .withDescription("Split Test")
           .execute(configName: merchantConfigName) {
               splitResponse = $0
               splitError = $1
               splitExpectation.fulfill()
           }
       
       // THEN
       wait(for: [splitExpectation], timeout: 10.0)
       XCTAssertNil(splitError)
       XCTAssertNotNil(splitResponse)
       assertResponse(splitResponse, transactionStatus: .captured)
       ServicesContainer.shared.removeConfiguration(configName: merchantConfigName)
    }
    
    func  test_credit_sale_then_split_then_reverse_with_fundsData() {
        // GIVEN
        let merchantsExpectation = expectation(description: "Get Merchants Expectation")
        var merchantSummary: MerchantSummary?
        var merchantSplitting: MerchantSummary?
        var merchantsError: Error?
        
        // WHEN
        getMerchants {
            merchantSummary = $0?.results.first
            merchantSplitting = $0?.results.first(where: { merchant in
                merchant.id != merchantSummary?.id
            })
            merchantsError = $1
            merchantsExpectation.fulfill()
        }
        
        // THEN
        wait(for: [merchantsExpectation], timeout: 10.0)
        XCTAssertNil(merchantsError)
        XCTAssertNotNil(merchantSummary)
        XCTAssertNotNil(merchantSplitting)
        
        let merchantId = merchantSummary?.id ?? ""
        let accountSummary = getAccountByType(merchantId: merchantId, type: .TRANSACTION_PROCESSING)
        
        
        // GIVEN
        let config = Self.achConfig
        let merchantConfigName = "config_" + merchantId
        config.merchantId = merchantId
        config.accessTokenInfo = AccessTokenInfo(transactionProcessingAccountID: accountSummary?.id)
        try? ServicesContainer.configureService(config: config, configName: merchantConfigName)
       
        let eCheckExpectation = expectation(description: "eCheck Charge Expectation")
        var eCheckResponse: Transaction?
        var eCheckError: Error?

        // WHEN
        eCheckData.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withAddress(address)
            .withCustomer(customer)
            .execute(configName: merchantConfigName) {
                eCheckResponse = $0
                eCheckError = $1
                eCheckExpectation.fulfill()
            }

        // THEN
        wait(for: [eCheckExpectation], timeout: 10.0)
        XCTAssertNil(eCheckError)
        assertResponse(eCheckResponse, transactionStatus: .captured)
        
        // WHEN
        let accountRecipient = getAccountByType(merchantId: merchantId, type: .FUND_MANAGEMENT)
        let accountSplitting = getAccountByType(merchantId: merchantSplitting?.id ?? "", type: .FUND_MANAGEMENT)
        
        // THEN
        XCTAssertNotNil(accountRecipient)
        XCTAssertNotNil(accountSplitting)
        
        // GIVEN
        let fundsData = FundsData()
        fundsData.merchantId = merchantId
        fundsData.recipientAccountId = accountSplitting?.id
        let splitExpectation = expectation(description: "Transaction Split Expectation")
        var splitResponse: Transaction?
        var splitError: Error?
        let transferAmount: NSDecimalNumber = 8.00
        let transferReference = "Split Identifier"
        let transferDescription = "Split Test"
        
        // WHEN
        eCheckResponse?.split(amount: transferAmount)
            .withFundsData(fundsData)
            .withReference(transferReference)
            .withDescription(transferDescription)
            .execute(configName: merchantConfigName) {
                splitResponse = $0
                splitError = $1
                splitExpectation.fulfill()
            }
        
        // THEN
        wait(for: [splitExpectation], timeout: 10.0)
        XCTAssertNil(splitError)
        XCTAssertNotNil(splitResponse)
        assertResponse(splitResponse, transactionStatus: .captured)
        XCTAssertNotNil(splitResponse?.transfersFundsAccounts)
        let transferFund = splitResponse?.transfersFundsAccounts?.first
        
        XCTAssertEqual("SUCCESS", transferFund?.status)
        XCTAssertEqual(transferAmount, transferFund?.amount)
        XCTAssertEqual(transferReference, transferFund?.reference)
        XCTAssertEqual(transferDescription, transferFund?.description)
        
        sleep(2)
        // GIVEN
        let reverseTransaction = Transaction.fromId(transactionId: transferFund?.id ?? "",  paymentMethodType: .accountFunds)
        let reverseExpectation = expectation(description: "Transaction Reverse Expectation")
        var reverseResponse: Transaction?
        var reverseError: Error?
        
        // WHEN
        reverseTransaction.reverse()
            .withFundsData(fundsData)
            .execute(configName: merchantConfigName) {
                reverseResponse = $0
                reverseError = $1
                reverseExpectation.fulfill()
            }

        // THEN
        wait(for: [reverseExpectation], timeout: 10.0)
        XCTAssertNil(reverseError)
        XCTAssertNotNil(reverseResponse)
        assertResponse(reverseResponse, transactionStatus: .funded)
        ServicesContainer.shared.removeConfiguration(configName: merchantConfigName)
    }
    
    
    func test_transfer_funds() {
        // GIVEN
        let merchantsExpectation = expectation(description: "Get Merchants Expectation")
        var merchantSender: MerchantSummary?
        var merchantRecipient: MerchantSummary?
        var merchantsError: Error?
        
        // WHEN
        getMerchants {
            merchantSender = $0?.results.first
            merchantRecipient = $0?.results.first(where: { merchant in
                merchant.id != merchantSender?.id
            })
            merchantsError = $1
            merchantsExpectation.fulfill()
        }
        
        // THEN
        wait(for: [merchantsExpectation], timeout: 10.0)
        XCTAssertNil(merchantsError)
        XCTAssertNotNil(merchantSender)
        XCTAssertNotNil(merchantRecipient)
        
        // GIVEN
        let merchantId = merchantSender?.id ?? ""
        
        // WHEN
        let accountSender = getAccountByType(merchantId: merchantId, type: .FUND_MANAGEMENT)
        let accountRecipient = getAccountByType(merchantId: merchantRecipient?.id ?? "", type: .FUND_MANAGEMENT)
        
        // THEN
        XCTAssertNotNil(accountSender)
        XCTAssertNotNil(accountRecipient)

        // GIVEN
        let transferFundsExpectation = expectation(description: "Transfer Funds Expectation")
        var transferFundsResponse: Transaction?
        var transferFundsError: Error?
        
        let funds = AccountFunds()
        funds.accountId = accountSender?.id
        funds.accountName = accountSender?.name
        funds.recipientAccountId = accountRecipient?.id
        funds.merchantId = merchantSender?.id
        funds.usableBalanceMode = .AVAILABLE_AND_PENDING_BALANCE
        let description = "Test Transfer Funds"

        // WHEN
        funds.transfer(amount: 1.0)
            .withClientTransactionId("")
            .withDescription(description)
            .execute {
                transferFundsResponse = $0
                transferFundsError = $1
                transferFundsExpectation.fulfill()
            }
        
        // THEN
        wait(for: [transferFundsExpectation], timeout: 10.0)
        XCTAssertNil(transferFundsError)
        XCTAssertNotNil(transferFundsResponse)
        XCTAssertNotNil(transferFundsResponse?.transactionId)
        XCTAssertEqual(1.0, transferFundsResponse?.balanceAmount)
        XCTAssertEqual("SUCCESS", transferFundsResponse?.responseMessage)
        XCTAssertEqual("SUCCESS", transferFundsResponse?.responseCode)
    }
    
    func test_transfer_funds_without_sender_account_name() {
        // GIVEN
        let merchantsExpectation = expectation(description: "Get Merchants Expectation")
        var merchantSender: MerchantSummary?
        var merchantRecipient: MerchantSummary?
        var merchantsError: Error?
        
        // WHEN
        getMerchants {
            merchantSender = $0?.results.first
            merchantRecipient = $0?.results.first(where: { merchant in
                merchant.id != merchantSender?.id
            })
            merchantsError = $1
            merchantsExpectation.fulfill()
        }
        
        // THEN
        wait(for: [merchantsExpectation], timeout: 10.0)
        XCTAssertNil(merchantsError)
        XCTAssertNotNil(merchantSender)
        XCTAssertNotNil(merchantRecipient)
        
        // GIVEN
        let merchantId = merchantSender?.id ?? ""
        
        // WHEN
        let accountSender = getAccountByType(merchantId: merchantId, type: .FUND_MANAGEMENT)
        let accountRecipient = getAccountByType(merchantId: merchantRecipient?.id ?? "", type: .FUND_MANAGEMENT)
        
        // THEN
        XCTAssertNotNil(accountSender)
        XCTAssertNotNil(accountRecipient)

        // GIVEN
        let transferFundsExpectation = expectation(description: "Transfer Funds Expectation")
        var transferFundsResponse: Transaction?
        var transferFundsError: Error?
        
        let funds = AccountFunds()
        funds.accountId = accountSender?.id
        funds.accountName = accountSender?.name
        funds.recipientAccountId = accountRecipient?.id
        funds.merchantId = merchantSender?.id
        funds.usableBalanceMode = .AVAILABLE_AND_PENDING_BALANCE
        let description = "Test Transfer Funds"

        // WHEN
        funds.transfer(amount: 0.01)
            .withClientTransactionId("")
            .withDescription(description)
            .execute {
                transferFundsResponse = $0
                transferFundsError = $1
                transferFundsExpectation.fulfill()
            }
        
        // THEN
        wait(for: [transferFundsExpectation], timeout: 10.0)
        XCTAssertNil(transferFundsError)
        XCTAssertNotNil(transferFundsResponse)
        XCTAssertNotNil(transferFundsResponse?.transactionId)
        XCTAssertEqual(0.01, transferFundsResponse?.balanceAmount)
        XCTAssertEqual("SUCCESS", transferFundsResponse?.responseMessage)
        XCTAssertEqual("SUCCESS", transferFundsResponse?.responseCode)
    }
    
    func test_transfer_funds_without_usable_balance_mode() {
        // GIVEN
        let merchantsExpectation = expectation(description: "Get Merchants Expectation")
        var merchantSender: MerchantSummary?
        var merchantRecipient: MerchantSummary?
        var merchantsError: Error?
        
        // WHEN
        getMerchants {
            merchantSender = $0?.results.first
            merchantRecipient = $0?.results.first(where: { merchant in
                merchant.id != merchantSender?.id
            })
            merchantsError = $1
            merchantsExpectation.fulfill()
        }
        
        // THEN
        wait(for: [merchantsExpectation], timeout: 10.0)
        XCTAssertNil(merchantsError)
        XCTAssertNotNil(merchantSender)
        XCTAssertNotNil(merchantRecipient)
        
        // GIVEN
        let merchantId = merchantSender?.id ?? ""
        
        // WHEN
        let accountSender = getAccountByType(merchantId: merchantId, type: .FUND_MANAGEMENT)
        let accountRecipient = getAccountByType(merchantId: merchantRecipient?.id ?? "", type: .FUND_MANAGEMENT)
        
        // THEN
        XCTAssertNotNil(accountSender)
        XCTAssertNotNil(accountRecipient)

        // GIVEN
        let transferFundsExpectation = expectation(description: "Transfer Funds Expectation")
        var transferFundsResponse: Transaction?
        var transferFundsError: Error?
        
        let funds = AccountFunds()
        funds.accountId = accountSender?.id
        funds.accountName = accountSender?.name
        funds.recipientAccountId = accountRecipient?.id
        funds.merchantId = merchantSender?.id
        let description = "Test Transfer Funds"

        // WHEN
        funds.transfer(amount: 0.01)
            .withClientTransactionId("")
            .withDescription(description)
            .execute {
                transferFundsResponse = $0
                transferFundsError = $1
                transferFundsExpectation.fulfill()
            }
        
        // THEN
        wait(for: [transferFundsExpectation], timeout: 10.0)
        XCTAssertNil(transferFundsError)
        XCTAssertNotNil(transferFundsResponse)
        XCTAssertNotNil(transferFundsResponse?.transactionId)
        XCTAssertEqual(0.01, transferFundsResponse?.balanceAmount)
        XCTAssertEqual("SUCCESS", transferFundsResponse?.responseMessage)
        XCTAssertEqual("SUCCESS", transferFundsResponse?.responseCode)
    }
    
    func test_transfer_funds_without_sender_accountId() {
        // GIVEN
        let merchantsExpectation = expectation(description: "Get Merchants Expectation")
        var merchantSender: MerchantSummary?
        var merchantRecipient: MerchantSummary?
        var merchantsError: Error?
        
        // WHEN
        getMerchants {
            merchantSender = $0?.results.first
            merchantRecipient = $0?.results.first(where: { merchant in
                merchant.id != merchantSender?.id
            })
            merchantsError = $1
            merchantsExpectation.fulfill()
        }
        
        // THEN
        wait(for: [merchantsExpectation], timeout: 10.0)
        XCTAssertNil(merchantsError)
        XCTAssertNotNil(merchantSender)
        XCTAssertNotNil(merchantRecipient)
        
        // GIVEN
        let merchantId = merchantSender?.id ?? ""
        
        // WHEN
        let accountSender = getAccountByType(merchantId: merchantId, type: .FUND_MANAGEMENT)
        let accountRecipient = getAccountByType(merchantId: merchantRecipient?.id ?? "", type: .FUND_MANAGEMENT)
        
        // THEN
        XCTAssertNotNil(accountSender)
        XCTAssertNotNil(accountRecipient)

        // GIVEN
        let transferFundsExpectation = expectation(description: "Transfer Funds Expectation")
        var transferFundsResponse: Transaction?
        var transferFundsError: Error?
        
        let funds = AccountFunds()
        funds.accountName = accountSender?.name
        funds.recipientAccountId = accountRecipient?.id
        funds.merchantId = merchantSender?.id
        funds.usableBalanceMode = .AVAILABLE_AND_PENDING_BALANCE
        let description = "Test Transfer Funds"

        // WHEN
        funds.transfer(amount: 0.01)
            .withClientTransactionId("")
            .withDescription(description)
            .execute {
                transferFundsResponse = $0
                transferFundsError = $1
                transferFundsExpectation.fulfill()
            }
        
        // THEN
        wait(for: [transferFundsExpectation], timeout: 10.0)
        XCTAssertNil(transferFundsError)
        XCTAssertNotNil(transferFundsResponse)
        XCTAssertNotNil(transferFundsResponse?.transactionId)
        XCTAssertEqual(0.01, transferFundsResponse?.balanceAmount)
        XCTAssertEqual("SUCCESS", transferFundsResponse?.responseMessage)
        XCTAssertEqual("SUCCESS", transferFundsResponse?.responseCode)
    }
    
    func test_transfer_funds_only_mandatory_fields() {
        // GIVEN
        let merchantsExpectation = expectation(description: "Get Merchants Expectation")
        var merchantSender: MerchantSummary?
        var merchantRecipient: MerchantSummary?
        var merchantsError: Error?
        
        // WHEN
        getMerchants {
            merchantSender = $0?.results.first
            merchantRecipient = $0?.results.first(where: { merchant in
                merchant.id != merchantSender?.id
            })
            merchantsError = $1
            merchantsExpectation.fulfill()
        }
        
        // THEN
        wait(for: [merchantsExpectation], timeout: 10.0)
        XCTAssertNil(merchantsError)
        XCTAssertNotNil(merchantSender)
        XCTAssertNotNil(merchantRecipient)
        
        // GIVEN
        let merchantId = merchantSender?.id ?? ""
        
        // WHEN
        let accountSender = getAccountByType(merchantId: merchantId, type: .FUND_MANAGEMENT)
        let accountRecipient = getAccountByType(merchantId: merchantRecipient?.id ?? "", type: .FUND_MANAGEMENT)
        
        // THEN
        XCTAssertNotNil(accountSender)
        XCTAssertNotNil(accountRecipient)

        // GIVEN
        let transferFundsExpectation = expectation(description: "Transfer Funds Expectation")
        var transferFundsResponse: Transaction?
        var transferFundsError: Error?
        
        let funds = AccountFunds()
        funds.accountId = accountSender?.id
        funds.accountName = accountSender?.name
        funds.recipientAccountId = accountRecipient?.id
        funds.merchantId = merchantSender?.id
        funds.usableBalanceMode = .AVAILABLE_AND_PENDING_BALANCE

        // WHEN
        funds.transfer(amount: 0.11)
            .execute {
                transferFundsResponse = $0
                transferFundsError = $1
                transferFundsExpectation.fulfill()
            }
        
        // THEN
        wait(for: [transferFundsExpectation], timeout: 10.0)
        XCTAssertNil(transferFundsError)
        XCTAssertNotNil(transferFundsResponse)
        XCTAssertNotNil(transferFundsResponse?.transactionId)
        XCTAssertEqual(0.11, transferFundsResponse?.balanceAmount)
        XCTAssertEqual("SUCCESS", transferFundsResponse?.responseMessage)
        XCTAssertEqual("SUCCESS", transferFundsResponse?.responseCode)
    }
    
    func test_transfer_funds_with_idempotency() {
        // GIVEN
        let merchantsExpectation = expectation(description: "Get Merchants Expectation")
        var merchantSender: MerchantSummary?
        var merchantRecipient: MerchantSummary?
        var merchantsError: Error?
        
        // WHEN
        getMerchants {
            merchantSender = $0?.results.first
            merchantRecipient = $0?.results.first(where: { merchant in
                merchant.id != merchantSender?.id
            })
            merchantsError = $1
            merchantsExpectation.fulfill()
        }
        
        // THEN
        wait(for: [merchantsExpectation], timeout: 10.0)
        XCTAssertNil(merchantsError)
        XCTAssertNotNil(merchantSender)
        XCTAssertNotNil(merchantRecipient)
        
        // GIVEN
        let merchantId = merchantSender?.id ?? ""
        
        // WHEN
        let accountSender = getAccountByType(merchantId: merchantId, type: .FUND_MANAGEMENT)
        let accountRecipient = getAccountByType(merchantId: merchantRecipient?.id ?? "", type: .FUND_MANAGEMENT)
        
        // THEN
        XCTAssertNotNil(accountSender)
        XCTAssertNotNil(accountRecipient)

        // GIVEN
        let transferFundsExpectation = expectation(description: "Transfer Funds Expectation")
        var transferFundsResponse: Transaction?
        var transferFundsError: Error?
        
        let funds = AccountFunds()
        funds.accountId = accountSender?.id
        funds.accountName = accountSender?.name
        funds.recipientAccountId = accountRecipient?.id
        funds.merchantId = merchantSender?.id
        funds.usableBalanceMode = .AVAILABLE_AND_PENDING_BALANCE
        let description = "Test Transfer Funds"
        let idempotencyKey = UUID().uuidString

        // WHEN
        funds.transfer(amount: 1.0)
            .withClientTransactionId("")
            .withDescription(description)
            .withIdempotencyKey(idempotencyKey)
            .execute(configName: Self.ACH_CONFIG) {
                transferFundsResponse = $0
                transferFundsError = $1
                transferFundsExpectation.fulfill()
            }
        
        // THEN
        wait(for: [transferFundsExpectation], timeout: 10.0)
        XCTAssertNil(transferFundsError)
        XCTAssertNotNil(transferFundsResponse)
        XCTAssertNotNil(transferFundsResponse?.transactionId)
        XCTAssertEqual(1.0, transferFundsResponse?.balanceAmount)
        XCTAssertEqual("SUCCESS", transferFundsResponse?.responseMessage)
        XCTAssertEqual("SUCCESS", transferFundsResponse?.responseCode)
        
        // GIVEN
        let transferFundsIdempotencyExpectation = expectation(description: "Dublicate Idempotency Expectation")
        var transferFundsIdempotencyResponse: Transaction?
        var transferFundsIdempotencyError: GatewayException?
        let transactionId = transferFundsResponse?.transactionId ?? ""

        // WHEN
        funds.transfer(amount: 1.0)
            .withClientTransactionId("")
            .withDescription(description)
            .withIdempotencyKey(idempotencyKey)
            .execute(configName: Self.ACH_CONFIG) {
                transferFundsIdempotencyResponse = $0
                if let error = $1 as? GatewayException {
                    transferFundsIdempotencyError = error
                }
                
                transferFundsIdempotencyExpectation.fulfill()
            }

        // THEN
        wait(for: [transferFundsIdempotencyExpectation], timeout: 10.0)
        XCTAssertNil(transferFundsIdempotencyResponse)
        XCTAssertNotNil(transferFundsIdempotencyError)
        XCTAssertEqual(transferFundsIdempotencyError?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(transferFundsIdempotencyError?.responseMessage, "40039")
        XCTAssertEqual("Status Code: 409 - Idempotency Key seen before: id=\(transactionId), status=SUCCESS", transferFundsIdempotencyError?.message)
    }
    
    func test_credit_sale_then_split_without_fundsData() {
        // GIVEN
        let transferExpectation = expectation(description: "Sale Split Without FundsData Expectation")
        var transferResponse: Transaction?
        var transferError: BuilderException?
        let transaction = Transaction.fromId(transactionId: UUID().uuidString)

        // WHEN
        transaction.split(amount: 8.00)
            .withReference("Split Identifier")
            .withDescription("Split Test")
            .execute(configName: Self.ACH_CONFIG) {
                transferResponse = $0
                transferError = $1 as? BuilderException
                transferExpectation.fulfill()
            }
        
        // THEN
        wait(for: [transferExpectation], timeout: 10.0)
        XCTAssertNil(transferResponse)
        XCTAssertNotNil(transferError)
        XCTAssertEqual("fundsData cannot be nil for this rule", transferError?.message)
    }
    
    func test_credit_sale_then_split_without_amount() {
        // GIVEN
        let transferExpectation = expectation(description: "Sale Split Without Amount Expectation")
        var transferResponse: Transaction?
        var transferError: BuilderException?
        let transaction = Transaction.fromId(transactionId: UUID().uuidString)
        let funds = FundsData()
        funds.recipientAccountId = UUID().uuidString
        funds.merchantId = UUID().uuidString

        // WHEN
        transaction.split()
            .withFundsData(funds)
            .withReference("Split Identifier")
            .withDescription("Split Test")
            .execute(configName: Self.ACH_CONFIG) {
                transferResponse = $0
                transferError = $1 as? BuilderException
                transferExpectation.fulfill()
            }
        
        // THEN
        wait(for: [transferExpectation], timeout: 10.0)
        XCTAssertNil(transferResponse)
        XCTAssertNotNil(transferError)
        XCTAssertEqual("amount cannot be nil for this rule", transferError?.message)
    }
    
    func test_add_funds() {
        // GIVEN
        let transferFundsExpectation = expectation(description: "Transfer Funds Expectation")
        var transferFundsResponse: User?
        var transferFundsError: Error?
        let amount: NSDecimalNumber = 10.0
        let currency = "USD"
        let accountId = "FMA_a78b841dfbd14803b3a31e4e0c514c72"
        let merchantId = "MER_5096d6b88b0b49019c870392bd98ddac";
        let merchant = User.fromId(from: merchantId, userType: .merchant)
    
        // WHEN
        merchant.addFunds()
            .withAmount(amount)
            .withAccountNumber(accountId)
            .withPaymentMethodName(.bankTransfer)
            .withPaymentMethodType(.credit)
            .withCurrency(currency)
            .execute {
                transferFundsResponse = $0
                transferFundsError = $1
                transferFundsExpectation.fulfill()
            }
        
        // THEN
        wait(for: [transferFundsExpectation], timeout: 10.0)
        XCTAssertNil(transferFundsError)
        XCTAssertNotNil(transferFundsResponse)
        XCTAssertEqual("SUCCESS", transferFundsResponse?.responseCode)
        XCTAssertNotNil(transferFundsResponse?.fundsAccountDetails)
        XCTAssertEqual(FundsStatus.captured.rawValue, transferFundsResponse?.fundsAccountDetails?.status)
        XCTAssertEqual(amount, transferFundsResponse?.fundsAccountDetails?.amount)
        XCTAssertEqual(currency, transferFundsResponse?.fundsAccountDetails?.currency)
        XCTAssertEqual("CREDIT", transferFundsResponse?.fundsAccountDetails?.paymentMethodType)
        XCTAssertEqual("BANK_TRANSFER", transferFundsResponse?.fundsAccountDetails?.paymentMethodName)
        XCTAssertNotNil(transferFundsResponse?.fundsAccountDetails?.account)
        XCTAssertEqual(accountId, transferFundsResponse?.fundsAccountDetails?.account?.id)
    }
    
    func test_get_account_by_type() {
        // GIVEN
        let merchantsExpectation = expectation(description: "Get Merchants Expectation")
        var merchantSender: MerchantSummary?
        var merchantsError: Error?
        
        // WHEN
        getMerchants {
            merchantSender = $0?.results.first
            merchantsError = $1
            merchantsExpectation.fulfill()
        }
        
        // THEN
        wait(for: [merchantsExpectation], timeout: 10.0)
        XCTAssertNil(merchantsError)
        XCTAssertNotNil(merchantSender)
        
        // WHEN
        let merchantId = merchantSender?.id ?? ""
        let accountSender = getAccountByType(merchantId: merchantId, type: .FUND_MANAGEMENT)
        
        // THEN
        XCTAssertNotNil(accountSender)
    }

    private func assertResponse(_ response: Transaction?, transactionStatus: TransactionStatus) {
        XCTAssertNotNil(response)
        XCTAssertEqual("SUCCESS", response?.responseCode)
        XCTAssertEqual(transactionStatus.rawValue, response?.responseMessage)
    }
    
    private func getMerchants(completion: ((PagedResult<MerchantSummary>?, Error?) -> Void)?) {
        let startDate = Date().addYears(-1)
        ReportingService.findMerchants(1, pageSize: 10)
            .orderBy(transactionSortProperty: .timeCreated, SortDirection.ascending)
            .withMerchantStatus(.ACTIVE)
            .withStartDate(startDate)
            .withEndDate(Date())
            .execute(configName: Self.ACH_CONFIG, completion: completion)
    }
    
    private func getAccountService(merchantId: String, completion: ((PagedResult<AccountSummary>?, Error?) -> Void)?) {
        let startDate = Date().addYears(-1)
        ReportingService.findAccounts(1, pageSize: 10)
            .orderBy(transactionSortProperty: .timeCreated, .ascending)
            .withStartDate(startDate)
            .withMerchantId(merchantId)
            .withMerchantStatus(.ACTIVE)
            .execute(configName: Self.ACH_CONFIG, completion: completion)
    }
    
    private func getAccountByType(merchantId: String, type: MerchantAccountType) -> AccountSummary? {
        // GIVEN
        let accountByTypeExpectation = expectation(description: "Get Account By Type Expectation")
        var accountByType: AccountSummary?
        var accountByTypeError: Error?
        
        // WHEN
        getAccountService(merchantId: merchantId) {
            accountByType = $0?.results.first(where: { account in
                account.type == type.rawValue
            })
            accountByTypeError = $1
            accountByTypeExpectation.fulfill()
        }
        
        // THEN
        wait(for: [accountByTypeExpectation], timeout: 10.0)
        XCTAssertNil(accountByTypeError)
        XCTAssertNotNil(accountByType)
        return accountByType
    }
}
