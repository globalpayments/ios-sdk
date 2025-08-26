import XCTest
import GlobalPayments_iOS_SDK

final class GpApiPayUApmTest: XCTestCase {

    private let AMOUNT: NSDecimalNumber = 100.0
    private let returnUrl = "https://www.example.com/returnUrl"
    private let statusUpdateUrl = "https://www.example.com/statusUrl"
    private let Descriptor = "Test Transaction"
                
    override func setUp() {
        super.setUp()
        payUApmSetup()
    }
    
    // MARK: - Setup PayU APM Configuration
    
    func payUApmSetup() {
        ServicesContainer.shared.removeConfiguration(configName: "")
        
        let config = GpApiConfig(
            appId: "QDYRMaAMLxgOoM8yUsEKasdP3YMWs91U",
            appKey: "7sUJOmQGf8nkEmS0",
            channel: .cardNotPresent,
        )
        config.country = "PL"
        config.serviceUrl = "https://apis-sit.globalpay.com/ucp"
        let accessTokenInfo =  AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "Mer02_SIT_CNPPayu"
        accessTokenInfo.riskAssessmentAccountName = "EOS_RiskAssessment"
        config.accessTokenInfo = accessTokenInfo
        try? ServicesContainer.configureService(config: config)
    }
    
    // MARK: - GP API PayU APM Test Methods
    
    func test_PayUSale_WhenRequestIsValid_ShouldSucceed_WithBankName() {
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .OB
        paymentMethod.returnUrl = returnUrl
        paymentMethod.statusUpdateUrl = statusUpdateUrl
        paymentMethod.descriptor = Descriptor
        paymentMethod.country = "PL"
        paymentMethod.accountHolderName = "James Mason"
        paymentMethod.bank = BankList.MBANK
        
        let expectationCharge = expectation(description: "PayU charge Expectation")
        var responseCharge: Transaction?
        var errorCharge: Error?
        
        paymentMethod.charge(amount: AMOUNT)
            .withCurrency("PLN")
            .withDescription("New APM")
            .execute {
                responseCharge = $0
                errorCharge = $1
                expectationCharge.fulfill()
            }
        
        wait(for: [expectationCharge], timeout: 8.0)
        
        XCTAssertNil(errorCharge)
        XCTAssertNotNil(responseCharge)
        XCTAssertNotNil(responseCharge?.alternativePaymentResponse)
        XCTAssertNotNil(responseCharge?.alternativePaymentResponse?.redirectUrl)
        XCTAssertEqual("BANK_PAYMENT", responseCharge?.alternativePaymentResponse?.providerName?.uppercased())
    }
    
    // Verifies that a sale transaction using PayU APM throws an exception when the ReturnUrl is missing.
    func test_Payu_Apm_ForSaleWithoutReturnUrl() {
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .OB
        paymentMethod.statusUpdateUrl = statusUpdateUrl
        paymentMethod.descriptor = Descriptor
        paymentMethod.country = "PL"
        paymentMethod.accountHolderName = "James Mason"
        paymentMethod.bank = BankList.MBANK
        
        let expectationCharge = expectation(description: "PayU charge Expectation")
        var responseCharge: Transaction?
        var errorCharge: BuilderException?
        
        paymentMethod.charge(amount: AMOUNT)
            .withCurrency("PLN")
            .withDescription("New APM")
            .execute {
                responseCharge = $0
                if let error = $1 as? BuilderException {
                    errorCharge = error
                }
                expectationCharge.fulfill()
            }
        
        wait(for: [expectationCharge], timeout: 8.0)
        
        XCTAssertNotNil(errorCharge)
        XCTAssertNil(responseCharge)
        XCTAssertEqual("paymentMethod.returnUrl cannot be nil for this rule", errorCharge?.message)
    }
    
    // Verifies that a sale transaction using PayU APM throws an exception when the statusUpdateUrl is missing.
    func testPayu_Apm_ForSaleWithoutStatusUrl() {
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .OB
        paymentMethod.returnUrl = returnUrl
        paymentMethod.descriptor = Descriptor
        paymentMethod.country = "PL"
        paymentMethod.accountHolderName = "James Mason"
        paymentMethod.bank = BankList.MBANK
        
        let expectationCharge = expectation(description: "PayU charge Expectation")
        var responseCharge: Transaction?
        var errorCharge: BuilderException?
        
        paymentMethod.charge(amount: AMOUNT)
            .withCurrency("PLN")
            .withDescription("New APM")
            .execute {
                responseCharge = $0
                if let error = $1 as? BuilderException {
                    errorCharge = error
                }
                expectationCharge.fulfill()
            }
        
        wait(for: [expectationCharge], timeout: 8.0)
        
        XCTAssertNotNil(errorCharge)
        XCTAssertNil(responseCharge)
        XCTAssertEqual("paymentMethod.statusUpdateUrl cannot be nil for this rule", errorCharge?.message)
    }

    // Validates that the first refund attempt on a PayU APM transaction is approved successfully.
    func test_PayUApmRefund_WhenFirstTime_ShouldSucceed() {
        let transactionId = "TRN_ACtBnXWVTYtZRSRGVBI1c2WyJGwaNu_34C14BCF46C5"
        let transactionService = Transaction.fromId(transactionId: transactionId)
        
        let expectationRefund = expectation(description: "PayU Refund Expectation")
        var responseRefund: Transaction?
        var errorRefund: Error?
        
        transactionService.refund(amount: AMOUNT)
            .withCurrency("PLN")
            .execute {
                responseRefund = $0
                errorRefund = $1
                expectationRefund.fulfill()
            }
        
        wait(for: [expectationRefund], timeout: 10.0)
        XCTAssertNil(errorRefund)
        XCTAssertNotNil(responseRefund)
        XCTAssertEqual("BANK_PAYMENT", responseRefund?.alternativePaymentResponse?.providerName?.uppercased())
        XCTAssertEqual("SUCCESS", responseRefund?.responseCode)
        XCTAssertEqual("CAPTURED", responseRefund?.responseMessage)
    }
    
    // Ensures that a second refund attempt on the same PayU APM transaction returns a "Declined" response.
    func test_PayUApmRefund_WhenSecondTime_ShouldDecline() {
        let transactionId = "TRN_xKHwt1HotE9hKwh7086N643h16M3gT_EFB7EBC9BE12"
        let transactionService = Transaction.fromId(transactionId: transactionId)
        
        let expectationRefund = expectation(description: "PayU Refund Expectation")
        var responseRefund: Transaction?
        var errorRefund: Error?
        
        transactionService.refund(amount: AMOUNT)
            .withCurrency("PLN")
            .execute {
                responseRefund = $0
                errorRefund = $1
                expectationRefund.fulfill()
            }
        
        wait(for: [expectationRefund], timeout: 10.0)
        XCTAssertNil(errorRefund)
        XCTAssertNotNil(responseRefund)
        XCTAssertEqual("BANK_PAYMENT", responseRefund?.alternativePaymentResponse?.providerName?.uppercased())
        XCTAssertEqual("DECLINED", responseRefund?.responseMessage)
    }
}
