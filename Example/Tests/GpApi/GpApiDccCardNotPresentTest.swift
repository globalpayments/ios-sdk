import XCTest
import GlobalPayments_iOS_SDK

class GpApiDccCardNotPresentTest: XCTestCase {

    private var card: CreditCardData!
    private let CURRENCY = "EUR"
    private let AMOUNT: NSDecimalNumber = 10.0

    override class func setUp() {
        super.setUp()

        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "dcc"

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "mivbnCh6tcXhrc6hrUxb3SU8bYQPl9pd",
            appKey: "Yf6MJDNJKiqObYAb",
            channel: .cardNotPresent,
            accessTokenInfo: accessTokenInfo
        ))
    }

    override func setUp() {
        super.setUp()
        card = CreditCardData()
        card.number = "4006097467207025"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cardPresent = true
    }

    func test_credit_get_dcc_info() {
        // GIVEN
        let creditExpectation = expectation(description: "Credit Expectation")
        var creditResponse: Transaction?
        var creditError: Error?

        // WHEN
        card.getDccRate()
            .withAmount(AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditResponse = $0
                creditError = $1
                creditExpectation.fulfill()
            }

        // THEN
        wait(for: [creditExpectation], timeout: 10.0)
        XCTAssertNil(creditError)
        let expectedDccAmountValue = getDccAmount(creditResponse)
        assertDccInfoResponse(creditResponse, expectedDccAmountValue: expectedDccAmountValue)

        sleep(2)

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeResponse: Transaction?
        var chargeError: Error?

        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withDccRateData(creditResponse?.dccRateData)
            .execute {
                chargeResponse = $0
                chargeError = $1
                chargeExpectation.fulfill()
            }
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeError)
        assertTransactionResponse(chargeResponse, transactionStatus: .captured)
    }

    func test_credit_dcc_rate_authorize() {
        // GIVEN
        let creditExpectation = expectation(description: "Credit Expectation")
        var creditResponse: Transaction?
        var creditError: Error?

        // WHEN
        card.getDccRate()
            .withAmount(AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditResponse = $0
                creditError = $1
                creditExpectation.fulfill()
            }

        // THEN
        wait(for: [creditExpectation], timeout: 10.0)
        XCTAssertNil(creditError)
        let expectedDccAmountValue = getDccAmount(creditResponse)
        assertDccInfoResponse(creditResponse, expectedDccAmountValue: expectedDccAmountValue)

        sleep(2)

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeResponse: Transaction?
        var chargeError: Error?

        // WHEN
        card.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withDccRateData(creditResponse?.dccRateData)
            .execute {
                chargeResponse = $0
                chargeError = $1
                chargeExpectation.fulfill()
            }
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeError)
        assertTransactionResponse(chargeResponse, transactionStatus: .preauthorized)
    }

    func test_credit_rate_refund_standalone() {
        // GIVEN
        let creditExpectation = expectation(description: "Credit Expectation")
        var creditResponse: Transaction?
        var creditError: Error?

        // WHEN
        card.getDccRate()
            .withAmount(AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditResponse = $0
                creditError = $1
                creditExpectation.fulfill()
            }

        // THEN
        wait(for: [creditExpectation], timeout: 10.0)
        XCTAssertNil(creditError)
        let expectedDccAmountValue = getDccAmount(creditResponse)
        assertDccInfoResponse(creditResponse, expectedDccAmountValue: expectedDccAmountValue)

        sleep(2)

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeResponse: Transaction?
        var chargeError: Error?

        // WHEN
        card.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withDccRateData(creditResponse?.dccRateData)
            .execute {
                chargeResponse = $0
                chargeError = $1
                chargeExpectation.fulfill()
            }
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeError)
        assertTransactionResponse(chargeResponse, transactionStatus: .captured)
    }

    func test_credit_dcc_rate_reversal() {
        // GIVEN
        let creditExpectation = expectation(description: "Credit Expectation")
        var creditResponse: Transaction?
        var creditError: Error?

        // WHEN
        card.getDccRate()
            .withAmount(AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditResponse = $0
                creditError = $1
                creditExpectation.fulfill()
            }

        // THEN
        wait(for: [creditExpectation], timeout: 10.0)
        XCTAssertNil(creditError)
        let expectedDccAmountValue = getDccAmount(creditResponse)
        assertDccInfoResponse(creditResponse, expectedDccAmountValue: expectedDccAmountValue)

        sleep(2)

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeResponse: Transaction?
        var chargeError: Error?

        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withDccRateData(creditResponse?.dccRateData)
            .execute {
                chargeResponse = $0
                chargeError = $1
                chargeExpectation.fulfill()
            }
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeError)
        assertTransactionResponse(chargeResponse, transactionStatus: .captured)

        // GIVEN
        let reverseExpectation = expectation(description: "Charge Expectation")
        var reverseResponse: Transaction?
        var reverseError: Error?

        // WHEN
        chargeResponse?.reverse(amount: AMOUNT)
            .withDccRateData(creditResponse?.dccRateData)
            .execute {
                reverseResponse = $0
                reverseError = $1
                reverseExpectation.fulfill()
            }
        wait(for: [reverseExpectation], timeout: 10.0)
        XCTAssertNil(reverseError)
        assertTransactionResponse(reverseResponse, transactionStatus: .reversed)
    }

    func test_credit_dcc_rate_refund() {
        // GIVEN
        let creditExpectation = expectation(description: "Credit Expectation")
        var creditResponse: Transaction?
        var creditError: Error?

        // WHEN
        card.getDccRate()
            .withAmount(AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditResponse = $0
                creditError = $1
                creditExpectation.fulfill()
            }

        // THEN
        wait(for: [creditExpectation], timeout: 10.0)
        XCTAssertNil(creditError)
        let expectedDccAmountValue = getDccAmount(creditResponse)
        assertDccInfoResponse(creditResponse, expectedDccAmountValue: expectedDccAmountValue)

        sleep(2)

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeResponse: Transaction?
        var chargeError: Error?

        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withDccRateData(creditResponse?.dccRateData)
            .execute {
                chargeResponse = $0
                chargeError = $1
                chargeExpectation.fulfill()
            }
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeError)
        assertTransactionResponse(chargeResponse, transactionStatus: .captured)

        // GIVEN
        let reverseExpectation = expectation(description: "Charge Expectation")
        var reverseResponse: Transaction?
        var reverseError: Error?

        // WHEN
        card.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withDccRateData(creditResponse?.dccRateData)
            .execute {
                reverseResponse = $0
                reverseError = $1
                reverseExpectation.fulfill()
            }
        wait(for: [reverseExpectation], timeout: 10.0)
        XCTAssertNil(reverseError)
        assertTransactionResponse(reverseResponse, transactionStatus: .captured)
    }

    func test_credit_dcc_rate_authorization_then_capture() {
        // GIVEN
        let creditExpectation = expectation(description: "Credit Expectation")
        var creditResponse: Transaction?
        var creditError: Error?

        // WHEN
        card.getDccRate()
            .withAmount(AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditResponse = $0
                creditError = $1
                creditExpectation.fulfill()
            }

        // THEN
        wait(for: [creditExpectation], timeout: 10.0)
        XCTAssertNil(creditError)
        let expectedDccAmountValue = getDccAmount(creditResponse)
        assertDccInfoResponse(creditResponse, expectedDccAmountValue: expectedDccAmountValue)

        sleep(2)

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeResponse: Transaction?
        var chargeError: Error?

        // WHEN
        card.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withDccRateData(creditResponse?.dccRateData)
            .execute {
                chargeResponse = $0
                chargeError = $1
                chargeExpectation.fulfill()
            }
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeError)
        assertTransactionResponse(chargeResponse, transactionStatus: .preauthorized)

        // GIVEN
        let reverseExpectation = expectation(description: "Charge Expectation")
        var reverseResponse: Transaction?
        var reverseError: Error?

        // WHEN
        chargeResponse?.capture()
            .withDccRateData(creditResponse?.dccRateData)
            .execute {
                reverseResponse = $0
                reverseError = $1
                reverseExpectation.fulfill()
            }
        wait(for: [reverseExpectation], timeout: 10.0)
        XCTAssertNil(reverseError)
        assertTransactionResponse(reverseResponse, transactionStatus: .captured)
    }

    func test_credit_dcc_info_with_idempotency_key() {
        // GIVEN
        let creditExpectation = expectation(description: "Credit Expectation")
        let idempotencyKey = UUID().uuidString
        var creditResponse: Transaction?
        var creditError: Error?

        // WHEN
        card.getDccRate()
            .withAmount(AMOUNT)
            .withCurrency(CURRENCY)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                creditResponse = $0
                creditError = $1
                creditExpectation.fulfill()
            }

        // THEN
        wait(for: [creditExpectation], timeout: 10.0)
        XCTAssertNil(creditError)
        let expectedDccAmountValue = getDccAmount(creditResponse)
        assertDccInfoResponse(creditResponse, expectedDccAmountValue: expectedDccAmountValue)

        // GIVEN
        let duplicatedExpectation = expectation(description: "Credit Expectation")
        var duplicatedResponse: Transaction?
        var duplicatedError: GatewayException?

        // WHEN
        card.getDccRate()
            .withAmount(AMOUNT)
            .withCurrency(CURRENCY)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                duplicatedResponse = $0
                if let error = $1 as? GatewayException {
                    duplicatedError = error
                }
                duplicatedExpectation.fulfill()
            }

        // THEN
        wait(for: [duplicatedExpectation], timeout: 10.0)
        XCTAssertNil(duplicatedResponse)
        XCTAssertNotNil(duplicatedError)
        XCTAssertEqual("DUPLICATE_ACTION", duplicatedError?.responseCode)
        XCTAssertEqual("40039", duplicatedError?.responseMessage)
        XCTAssertEqual("Status Code: 409 - Idempotency Key seen before: id=\(creditResponse?.transactionId ?? ""), status=AVAILABLE", duplicatedError?.message)
    }

    func test_credit_get_dcc_info_rate_not_available() {
        // GIVEN
        let creditExpectation = expectation(description: "Credit Expectation")
        var creditResponse: Transaction?
        var creditError: Error?

        card.number = "4263970000005262"

        // WHEN
        card.getDccRate()
            .withAmount(AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditResponse = $0
                creditError = $1
                creditExpectation.fulfill()
            }

        // THEN
        wait(for: [creditExpectation], timeout: 10.0)
        XCTAssertNil(creditError)
        XCTAssertNotNil(creditResponse)
        XCTAssertEqual("SUCCESS", creditResponse?.responseCode)
        XCTAssertEqual("NOT_AVAILABLE", creditResponse?.responseMessage)
        XCTAssertNotNil(creditResponse?.dccRateData)

        sleep(2)

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeResponse: Transaction?
        var chargeError: Error?

        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withDccRateData(creditResponse?.dccRateData)
            .execute {
                chargeResponse = $0
                chargeError = $1
                chargeExpectation.fulfill()
            }
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeError)
        assertTransactionResponse(chargeResponse, transactionStatus: .captured)
    }

    private func assertDccInfoResponse(_ response: Transaction?, expectedDccAmountValue: NSDecimalNumber) {
        XCTAssertNotNil(response)
        XCTAssertEqual("SUCCESS", response?.responseCode)
        XCTAssertEqual("AVAILABLE", response?.responseMessage)
        XCTAssertNotNil(response?.dccRateData)
        XCTAssertEqual(expectedDccAmountValue, response?.dccRateData?.cardHolderAmount)
    }

    private func assertTransactionResponse(_ response: Transaction?, transactionStatus: TransactionStatus) {
        XCTAssertNotNil(response)
        XCTAssertEqual("SUCCESS", response?.responseCode)
        XCTAssertEqual(transactionStatus.rawValue, response?.responseMessage)
    }

    private func getDccAmount(_ dccDetails: Transaction?) -> NSDecimalNumber {
        let rate = dccDetails?.dccRateData?.cardHolderRate ?? 0.0
        return AMOUNT.multiplying(by: rate)
    }

}
