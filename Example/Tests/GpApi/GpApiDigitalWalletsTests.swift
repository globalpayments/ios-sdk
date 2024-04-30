import XCTest
import GlobalPayments_iOS_SDK

class GpApiDigitalWalletsTests: XCTestCase {
    
    var card: CreditCardData!

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc",
            appKey: "DYcEE2GpSzblo0ib",
            channel: .cardNotPresent
        ))
    }
    
    override func setUp() {
        super.setUp()

        card = CreditCardData()
        card.cardHolderName = "James Mason#"
    }

    override func tearDown() {
        super.tearDown()

        card = nil
    }
    
    func test_pay_with_decrypted_flow() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var chargeResult: Transaction?
        var chargeStatus: String?
        var chargeError: Error?

        // WHEN
        card.token = "5167300431085507"
        card.mobileType = EncryptedMobileType.APPLE_PAY.rawValue
        card.expMonth = 05
        card.expYear = 2025
        card.cryptogram = "234234234"
        
        card.charge(amount: 5)
            .withCurrency("EUR")
            .withModifier(.decryptedMobile)
            .execute {
                chargeResult = $0
                chargeError = $1
                chargeStatus = $0?.responseMessage
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10)
        XCTAssertNil(chargeError)
        XCTAssertNotNil(chargeResult)
        XCTAssertNotNil(chargeStatus)
        XCTAssertEqual(chargeResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeStatus, TransactionStatus.captured.rawValue)
    }
    
    func test_pay_with_encrypted() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var chargeResult: Transaction?
        var chargeStatus: String?
        var chargeError: Error?
        card.token = "9113329269393758302"
        card.mobileType = EncryptedMobileType.CLICK_PAY.rawValue

        // WHEN
        
        card.charge(amount: 10)
            .withCurrency("EUR")
            .withModifier(.encryptedMobile)
            .withMaskedDataResponse(true)
            .execute {
                chargeResult = $0
                chargeError = $1
                chargeStatus = $0?.responseMessage
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10)
        XCTAssertNil(chargeError)
        XCTAssertNotNil(chargeResult)
        XCTAssertNotNil(chargeStatus)
        XCTAssertEqual(chargeResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeStatus, TransactionStatus.captured.rawValue)
        XCTAssertTrue(!(chargeResult?.transactionId?.isEmpty ?? false))
        assertClickToPayPayerDetails(chargeResult)
    }
    
    //You need a valid ApplePay token that it is valid only for 60 sec
    func  test_pay_with_apple_pay_encrypted() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var chargeResult: Transaction?
        var chargeStatus: String?
        var chargeError: Error?
        
        // WHEN
        card.token = """
        You need a valid ApplePay token that it is valid only for 60 sec.
        """

        card.mobileType = EncryptedMobileType.APPLE_PAY.rawValue
        card.charge(amount: 10)
            .withCurrency("USD")
            .withModifier(.encryptedMobile)
            .execute {
                chargeResult = $0
                chargeError = $1
                chargeStatus = $0?.responseMessage
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10)
        XCTAssertNil(chargeError)
        XCTAssertNotNil(chargeResult)
        XCTAssertNotNil(chargeStatus)
        XCTAssertEqual(chargeResult?.responseCode, "SUCCESS")
        XCTAssertEqual("123456", chargeResult?.authorizationCode)
        XCTAssertEqual(chargeStatus, TransactionStatus.captured.rawValue)
    }
    
    //You need a valid ApplePay token that it is valid only for 60 sec
    func  test_pay_with_apple_pay_encrypted_reverse() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var chargeResult: Transaction?
        var chargeStatus: String?
        var chargeError: Error?
        card.mobileType = EncryptedMobileType.APPLE_PAY.rawValue
        card.token = """
        You need a valid ApplePay token that it is valid only for 60 sec.
        """
        // WHEN
        card.charge(amount: 10)
            .withCurrency("GBP")
            .withModifier(.encryptedMobile)
            .execute {
                chargeResult = $0
                chargeError = $1
                chargeStatus = $0?.responseMessage
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10)
        XCTAssertNil(chargeError)
        XCTAssertNotNil(chargeResult)
        XCTAssertNotNil(chargeStatus)
        XCTAssertEqual(chargeResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeStatus, TransactionStatus.captured.rawValue)
        
        // GIVEN
        let creditReverseExpectation = expectation(description: "Credit reverse expectation")
        var reverseResponse: Transaction?
        var reverseError: Error?
        
        // WHEN
        chargeResult?.reverse()
            .withCurrency("USD")
            .execute{
                reverseResponse = $0
                reverseError = $1
                creditReverseExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditReverseExpectation], timeout: 10.0)
        XCTAssertNil(reverseError)
        XCTAssertNotNil(reverseResponse)
        XCTAssertEqual("SUCCESS", reverseResponse?.responseCode)
        XCTAssertEqual(TransactionStatus.reversed.rawValue, reverseResponse?.responseMessage)
    }
    
    private func assertClickToPayPayerDetails(_ response: Transaction?) {
        XCTAssertNotNil(response?.payerDetails)
        XCTAssertNotNil(response?.payerDetails?.email)
        XCTAssertNotNil(response?.payerDetails?.billingAddress)
        XCTAssertNotNil(response?.payerDetails?.shippingAddress)
        XCTAssertNotNil(response?.payerDetails?.firstName)
        XCTAssertNotNil(response?.payerDetails?.firstName)
    }
}
