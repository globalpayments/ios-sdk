import XCTest
import GlobalPayments_iOS_SDK

final class GpApiBlikPayuCertification: XCTestCase {
    
    private let AMOUNT: NSDecimalNumber = 0.02
    private let returnUrl = "https://www.example.com/returnUrl"
    private let statusUpdateUrl = "https://www.example.com/statusUrl"
    private let Descriptor = "Test Transaction"
    
    override func setUp() {
        super.setUp()
        blikAndPayuSetup()
    }

    func blikAndPayuSetup() {
        let config = GpApiConfig(
            appId: "ZbFY1jAz6sqq0GAyIPZe1raLCC7cUlpD",
            appKey: "4NpIQJDCIDzfTKhA",
            channel: .cardNotPresent,
        )
        config.country = "PL"
        config.serviceUrl = "https://apis.globalpay.com/ucp"
        let accessTokenInfo =  AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "transaction_processing"
        accessTokenInfo.riskAssessmentAccountName = "EOS_RiskAssessment"
        config.accessTokenInfo = accessTokenInfo
        try? ServicesContainer.configureService(config: config)
    }
    
    func testBlikApmForSale() {
        let expectationCharge = expectation(description: "Blik charge Expectation")
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .BLIK
        paymentMethod.returnUrl = returnUrl
        paymentMethod.statusUpdateUrl = statusUpdateUrl
        paymentMethod.descriptor = Descriptor
        paymentMethod.country = "PL"
        paymentMethod.accountHolderName = "James Mason"
        
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
        XCTAssertEqual(responseCharge?.alternativePaymentResponse?.providerName?.uppercased(), "BLIK")
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
    }
    
    func testBlikApmForRefund_Full() {
        let transactionId = "TRN_Pkp0ZQYkJdBgZgY2YuQ9jMK9m4IGFp_1C170FD392E4"
        let transactionService = Transaction.fromId(transactionId: transactionId)
        
        let expectationRefund = expectation(description: "Blik Refund Expectation")
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
        XCTAssertEqual("SUCCESS", responseRefund?.responseCode)
    }
    
    func testBlikApmForRefund_Partial() {
        let transactionId = "TRN_8wtf8M87SOSl7qlTWg59Btic2DoXxH_72532CBBE7FE"
        let transactionService = Transaction.fromId(transactionId: transactionId)
        
        let expectationRefund = expectation(description: "Blik Refund Expectation")
        var responseRefund: Transaction?
        var errorRefund: Error?
        
        transactionService.refund(amount: 0.01)
            .withCurrency("PLN")
            .execute {
                responseRefund = $0
                errorRefund = $1
                expectationRefund.fulfill()
            }
        
        wait(for: [expectationRefund], timeout: 10.0)
        XCTAssertNil(errorRefund)
        XCTAssertNotNil(responseRefund)
        XCTAssertEqual("SUCCESS", responseRefund?.responseCode)
    }
    
    func testBlikApmForRefund_OverAmount() {
        let transactionId = "TRN_mytMzzoU3rVqEaagcP9l9et9STJYrX_99DE7725431D"
        let transactionService = Transaction.fromId(transactionId: transactionId)
        
        let expectationRefund = expectation(description: "Blik Refund Expectation")
        var responseRefund: Transaction?
        var errorRefund: Error?
        
        transactionService.refund(amount: 0.05)
            .withCurrency("PLN")
            .execute {
                responseRefund = $0
                errorRefund = $1
                expectationRefund.fulfill()
            }
        
        wait(for: [expectationRefund], timeout: 10.0)
        XCTAssertNil(errorRefund)
        XCTAssertNotNil(responseRefund)
        XCTAssertEqual("DECLINED", responseRefund?.responseCode)
    }
    
    func testPayuApmForSale() {
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .OB
        paymentMethod.returnUrl = returnUrl
        paymentMethod.statusUpdateUrl = statusUpdateUrl
        paymentMethod.descriptor = Descriptor
        paymentMethod.country = "PL"
        paymentMethod.accountHolderName = "James Mason"
        paymentMethod.bank = BankList.BANKPEKAOSA
        
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
    
    func testPayuApmForRefund_Full() {
        let transactionId = "TRN_j7CNDMb7isIzZixkXHGrHVLTD7G0XL_5AB5B41FA7D2"
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
        XCTAssertEqual("SUCCESS", responseRefund?.responseCode)
    }
    
    func testPayuApmForRefund_Partial() {
        let transactionId = "TRN_a004S7b0x3ljaK0tG3hhmcghn1ixmQ_1BA9AFF8B2D4"
        let transactionService = Transaction.fromId(transactionId: transactionId)
        
        let expectationRefund = expectation(description: "PayU Refund Expectation")
        var responseRefund: Transaction?
        var errorRefund: Error?
        
        transactionService.refund(amount: 0.01)
            .withCurrency("PLN")
            .execute {
                responseRefund = $0
                errorRefund = $1
                expectationRefund.fulfill()
            }
        
        wait(for: [expectationRefund], timeout: 10.0)
        XCTAssertNil(errorRefund)
        XCTAssertNotNil(responseRefund)
        XCTAssertEqual("SUCCESS", responseRefund?.responseCode)
    }
    
    func testPayuApmForRefund_OverAmount() {
        let transactionId = "TRN_0GrHdq2rq37HXpHZ5dVmdK5EFEnkTr_FDDC549C8921"
        let transactionService = Transaction.fromId(transactionId: transactionId)
        
        let expectationRefund = expectation(description: "PayU Refund Expectation")
        var responseRefund: Transaction?
        var errorRefund: Error?
        
        transactionService.refund(amount: 0.05)
            .withCurrency("PLN")
            .execute {
                responseRefund = $0
                errorRefund = $1
                expectationRefund.fulfill()
            }
        
        wait(for: [expectationRefund], timeout: 10.0)
        XCTAssertNil(errorRefund)
        XCTAssertNotNil(responseRefund)
        XCTAssertEqual("DECLINED", responseRefund?.responseCode)
    }
}
