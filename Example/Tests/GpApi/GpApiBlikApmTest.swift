import XCTest
import GlobalPayments_iOS_SDK

final class GpApiBlikApmTest: XCTestCase {

    override func setUp() {
        super.setUp()
        blikApmSetup()
    }
    
    // MARK: - Setup Blik APM Configuration
    
    func blikApmSetup() {
        ServicesContainer.shared.removeConfiguration(configName: "")
        
        let config = GpApiConfig(
            appId: "p2GgW0PntEUiUh4qXhJHPoDqj3G5GFGI",
            appKey: "lJk4Np5LoUEilFhH",
            channel: .cardNotPresent,
        )
        config.country = "PL"
        config.serviceUrl = "https://apis-sit.globalpay.com/ucp"
        let accessTokenInfo =  AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "GPECOM_BLIK_APM_Transaction_Processing"
        accessTokenInfo.riskAssessmentAccountName = "EOS_RiskAssessment"
        config.accessTokenInfo = accessTokenInfo
        try? ServicesContainer.configureService(config: config)
    }

    // MARK: - GP API Blik APM Test Methods
    
    func test_BlikApmSale_WhenRequestIsValid_ShouldSucceed() {
        let expectationCharge = expectation(description: "Blik charge Expectation")
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .BLIK
        paymentMethod.returnUrl = "https://www.example.com/returnUrl"
        paymentMethod.statusUpdateUrl = "https://www.example.com/statusUrl"
        paymentMethod.descriptor = "Test Transaction"
        paymentMethod.country = "PL"
        paymentMethod.accountHolderName = "James Mason"
        
        var responseCharge: Transaction?
        var errorCharge: Error?
        
        paymentMethod.charge(amount: 19.99)
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
        XCTAssertEqual(responseCharge?.alternativePaymentResponse?.providerName?.uppercased(), "BLIK")
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
    }
    
    // Verifies that a sale transaction using Blik APM throws an exception when the ReturnUrl is missing.
    func test_BlikApmSale_WhenReturnUrlMissing_ShouldThrowException() {
        let expectationCharge = expectation(description: "Blik charge Expectation")
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .BLIK
        paymentMethod.statusUpdateUrl = "https://www.example.com/statusUrl"
        paymentMethod.descriptor = "Test Transaction"
        paymentMethod.country = "PL"
        paymentMethod.accountHolderName = "James Mason"
        
        var responseCharge: Transaction?
        var errorCharge: BuilderException?
        
        paymentMethod.charge(amount: 19.99)
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
    
    // Verifies that a sale transaction using Blik APM throws an exception when the statusUpdateUrl is missing.
    func test_BlikApmSale_WhenStatusUpdateUrlMissing_ShouldThrowException() {
        let expectationCharge = expectation(description: "Blik charge Expectation")
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .BLIK
        paymentMethod.returnUrl = "https://www.example.com/returnUrl"
        paymentMethod.descriptor = "Test Transaction"
        paymentMethod.country = "PL"
        paymentMethod.accountHolderName = "James Mason"
        
        var responseCharge: Transaction?
        var errorCharge: BuilderException?
        
        paymentMethod.charge(amount: 19.99)
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
    
    // Validates that the first refund attempt on a Blik APM transaction is approved successfully.
    func test_BlikApmRefund_WhenFirstTime_ShouldSucceed() {
        let transactionId = "TRN_KAcnUhAplnf2Pdw6VylJwX8sJjVuxl_412191212769"
        let transactionService = Transaction.fromId(transactionId: transactionId)
        
        let expectationRefund = expectation(description: "Blik Refund Expectation")
        var responseRefund: Transaction?
        var errorRefund: Error?
        
        transactionService.refund(amount: 19.99)
            .withCurrency("PLN")
            .execute {
                responseRefund = $0
                errorRefund = $1
                expectationRefund.fulfill()
            }
        
        wait(for: [expectationRefund], timeout: 10.0)
        XCTAssertNil(errorRefund)
        XCTAssertNotNil(responseRefund)
        XCTAssertEqual("BLIK", responseRefund?.alternativePaymentResponse?.providerName?.uppercased())
        XCTAssertEqual("SUCCESS", responseRefund?.responseCode)
        XCTAssertEqual("CAPTURED", responseRefund?.responseMessage)
    }
    
    // Ensures that a second refund attempt on the same Blik APM transaction returns a "Declined" response.
    func test_BlikApmRefund_WhenSecondTime_ShouldDecline() {
        let transactionId = "TRN_KAcnUhAplnf2Pdw6VylJwX8sJjVuxl_412191212769"
        let transactionService = Transaction.fromId(transactionId: transactionId)
        
        let expectationRefund = expectation(description: "Blik Refund Expectation")
        var responseRefund: Transaction?
        var errorRefund: Error?
        
        transactionService.refund(amount: 19.99)
            .withCurrency("PLN")
            .execute {
                responseRefund = $0
                errorRefund = $1
                expectationRefund.fulfill()
            }
        
        wait(for: [expectationRefund], timeout: 10.0)
        XCTAssertNil(errorRefund)
        XCTAssertNotNil(responseRefund)
        XCTAssertEqual("BLIK", responseRefund?.alternativePaymentResponse?.providerName?.uppercased())
        XCTAssertEqual("DECLINED", responseRefund?.responseMessage)
    }

}
