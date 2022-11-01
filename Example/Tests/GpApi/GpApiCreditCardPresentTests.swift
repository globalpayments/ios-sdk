import XCTest
import GlobalPayments_iOS_SDK

class GpApiCreditCardPresentTests: XCTestCase {
    var card: CreditCardData!
    
    let amount: NSDecimalNumber = 12.02
    let currency = "USD"
    let expectedResponseCode = "SUCCESS"

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc",
            appKey: "DYcEE2GpSzblo0ib",
            channel: .cardPresent
        ))
    }

    override func setUp() {
        super.setUp()

        card = CreditCardData()
        card.number = "4263970000005262"
        card.expMonth = 5
        card.expYear = 2025
        card.cvn = "852"
    }

    override func tearDown() {
        super.tearDown()

        card = nil
    }

    func test_credit_charge_with_chip() {
        // GIVEN
        let creditTrackData = CreditTrackData()
        creditTrackData.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        creditTrackData.entryMethod = .swipe

        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var chargeResult: Transaction?
        var chargeStatus: String?
        var chargeError: Error?

        // WHEN
        creditTrackData
            .charge(amount: 19)
            .withCurrency("GBP")
            .withEmvLastChipRead(.successful)
            .withAllowDuplicates(true)
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

    func test_credit_authorize() {
        // GIVEN
        let creditTrackData = CreditTrackData()
        creditTrackData.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        creditTrackData.entryMethod = .swipe

        let creditAuthorizeExpectation = expectation(description: "Credit Authorize Expectation")
        var authorizeResult: Transaction?
        var authorizeStatus: String?
        var authorizeError: Error?

        // WHEN
        creditTrackData
            .authorize(amount: 14)
            .withCurrency("GBP")
            .withOrderId("124214-214221")
            .withAllowDuplicates(true)
            .execute {
                authorizeResult = $0
                authorizeError = $1
                authorizeStatus = $0?.responseMessage
                creditAuthorizeExpectation.fulfill()
            }

        // THEN
        wait(for: [creditAuthorizeExpectation], timeout: 10)
        XCTAssertNil(authorizeError)
        XCTAssertNotNil(authorizeResult)
        XCTAssertNotNil(authorizeStatus)
        XCTAssertEqual(authorizeResult?.responseCode, "SUCCESS")
        XCTAssertEqual(authorizeStatus, TransactionStatus.preauthorized.rawValue)
    }

    func test_credit_authorization_and_capture() {
        // GIVEN
        let creditTrackData = CreditTrackData()
        creditTrackData.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        creditTrackData.entryMethod = .swipe

        let authorizeExpectation = expectation(description: "Authorize Expectation")
        var creditAuthorize: Transaction?
        var creditAuthorizeStatus: String?
        var creditAuthorizeError: Error?

        // WHEN
        creditTrackData
            .authorize(amount: 14)
            .withCurrency("GBP")
            .withAllowDuplicates(true)
            .execute {
                creditAuthorize = $0
                creditAuthorizeError = $1
                creditAuthorizeStatus = $0?.responseMessage
                authorizeExpectation.fulfill()
            }

        // THEN
        wait(for: [authorizeExpectation], timeout: 10)
        XCTAssertNil(creditAuthorizeError)
        XCTAssertNotNil(creditAuthorize)
        XCTAssertNotNil(creditAuthorizeStatus)
        XCTAssertEqual(creditAuthorize?.responseCode, "SUCCESS")
        XCTAssertEqual(creditAuthorizeStatus, TransactionStatus.preauthorized.rawValue)

        // GIVEN
        let transactionCaptureExpectation = expectation(description: "Transaction Capture Expectation")
        var captureResponse: Transaction?
        var captureError: Error?
        var captureStatus: String?

        // WHEN
        creditAuthorize?
            .capture(amount: 14)
            .withCurrency("GBP")
            .execute(completion: {
                captureResponse = $0
                captureError = $1
                captureStatus = $0?.responseMessage
                transactionCaptureExpectation.fulfill()
            })

        // THEN
        wait(for: [transactionCaptureExpectation], timeout: 10.0)
        XCTAssertNil(captureError)
        XCTAssertNotNil(captureResponse)
        XCTAssertEqual(captureStatus, TransactionStatus.captured.rawValue)
    }

    func test_credit_refund() {
        // GIVEN
        let creditTrackData = CreditTrackData()
        creditTrackData.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        creditTrackData.entryMethod = .swipe

        let creditRefundExpectation = expectation(description: "Credit Refund Expectation")
        var refundResult: Transaction?
        var refundStatus: String?
        var refundError: Error?

        // WHEN
        creditTrackData
            .refund(amount: 15.99)
            .withCurrency("GBP")
            .withAllowDuplicates(true)
            .execute {
                refundResult = $0
                refundError = $1
                refundStatus = $0?.responseMessage
                creditRefundExpectation.fulfill()
            }

        // THEN
        wait(for: [creditRefundExpectation], timeout: 10)
        XCTAssertNil(refundError)
        XCTAssertNotNil(refundResult)
        XCTAssertNotNil(refundStatus)
        XCTAssertEqual(refundResult?.responseCode, "SUCCESS")
        XCTAssertEqual(refundStatus, TransactionStatus.captured.rawValue)
    }

    func test_credit_verify() {
        // GIVEN
        let verifyExpectation = expectation(description: "Verify Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card?.cvn = "123"
        card?.cardPresent = true
        card?.verify()
            .withCurrency("GBP")
            .execute(completion: {
                transactionResult = $0
                transactionError = $1
                verifyExpectation.fulfill()
            })

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, "VERIFIED")
    }

    func test_credit_verify_cvn_not_matched() {
        // GIVEN
        let verifyExpectation = expectation(description: "Verify Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card?.number = "30450000000985"
        card?.cvn = "098"
        card?.cardPresent = true
        card?.verify()
            .withCurrency("GBP")
            .execute(completion: {
                transactionResult = $0
                transactionError = $1
                verifyExpectation.fulfill()
            })

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "NOT_VERIFIED")
        XCTAssertEqual(transactionResult?.responseMessage, "NOT_VERIFIED")
    }
    
    func test_incremental_auth() {
        // GIVEN
        let incrementalExpectation = expectation(description: "Incremental Expectation")
        var incrementalResult: Transaction?
        var incrementalError: Error?
        
        card?.number = "4263970000005262"
        card?.cvn = "123"
        card?.cardPresent = true
        
        // WHEN
        card?.authorize()
            .withAmount(amount)
            .withCurrency(currency)
            .execute(completion: {
                incrementalResult = $0
                incrementalError = $1
                incrementalExpectation.fulfill()
            })
        
        // THEN
        wait(for: [incrementalExpectation], timeout: 10.0)
        XCTAssertNil(incrementalError)
        XCTAssertNotNil(incrementalResult)
        XCTAssertEqual(expectedResponseCode, incrementalResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, incrementalResult?.responseMessage)

        // GIVEN
        let additionalExpectation = expectation(description: "Additional Expectation")
        var additionalResult: Transaction?
        var additionalError: Error?
        
        let lodgingInfo = LodgingData()
        lodgingInfo.bookingReference = "s9RpaDwXq1sPRkbP"
        lodgingInfo.stayDuration = 10
        lodgingInfo.checkInDate = Date()
        lodgingInfo.checkOutDate = Date().addDays(7)
        lodgingInfo.rate = 1349
        
        let item1 = LodgingItem()
        item1.types = LodgingItemType.NO_SHOW.rawValue
        item1.reference = "item_1"
        item1.totalAmount = "1349"
        item1.paymentMethodProgramCodes = [PaymentMethodProgram.ASSURED_RESERVATION.rawValue]
        lodgingInfo.items = [item1]

        // WHEN
        incrementalResult?.additionalAuth(amount: 10)
            .withCurrency(currency)
            .withLodgingData(lodgingInfo)
            .execute(completion: {
                additionalResult = $0
                additionalError = $1
                additionalExpectation.fulfill()
            })
        
        // THEN
        wait(for: [additionalExpectation], timeout: 10.0)
        XCTAssertNil(additionalError)
        XCTAssertNotNil(additionalResult)
        XCTAssertEqual(expectedResponseCode, additionalResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, additionalResult?.responseMessage)
        XCTAssertEqual(12.12, additionalResult?.authorizedAmount)
        
        // GIVEN
        let captureExpectation = expectation(description: "Capture Expectation")
        var captureResult: Transaction?
        var captureError: Error?
        
        // WHEN
        additionalResult?.capture()
            .execute(completion: {
                captureResult = $0
                captureError = $1
                captureExpectation.fulfill()
            })
        
        // THEN
        wait(for: [captureExpectation], timeout: 10.0)
        XCTAssertNil(captureError)
        XCTAssertNotNil(captureResult)
        XCTAssertEqual(expectedResponseCode, captureResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, captureResult?.responseMessage)
    }
}
