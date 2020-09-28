import XCTest
import GlobalPayments_iOS_SDK

class GpApiCreditTests: XCTestCase {
    var card: CreditCardData!

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig (
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent
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

    func test_credit_authorization() {
        // GIVEN
        let cardExecuteExpectation = expectation(description: "Card")
        var transactionResponse: Transaction?
        var transactionErrorResponse: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        card.authorize(amount: 14)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionErrorResponse = error
                if let responseMessage = transactionResponse?.responseMessage {
                    transactionStatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                cardExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [cardExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionErrorResponse)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatusResponse, TransactionStatus.preauthorized)

        // GIVEN
        let transactionExecuteExpectation = expectation(description: "Transaction")
        var captureResponse: Transaction?
        var captureErrorResponse: Error?
        var captureStatusResponse: TransactionStatus?

        // WHEN
        transactionResponse?
            .capture(amount: 16)
            .withGratuity(2)
            .execute(completion: { capture, error in
                captureResponse = capture
                captureErrorResponse = error
                if let responseMessage = captureResponse?.responseMessage {
                    captureStatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                transactionExecuteExpectation.fulfill()
            })

        //THEN
        wait(for: [transactionExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(captureResponse)
        XCTAssertNil(captureErrorResponse)
        XCTAssertEqual(captureStatusResponse, TransactionStatus.captured)
    }

    func test_card_sale() {
        // GIVEN
        let executeExpectation = expectation(description: "Card Sale")
        let address = Address()
        address.streetAddress1 = "123 Main St."
        address.city = "Downtown"
        address.state = "NJ"
        address.country = "US"
        address.postalCode = "12345"
        var transactionResponse: Transaction?
        var transactionErrorResponse: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        card.charge(amount: 19.99)
            .withCurrency("USD")
            .withAddress(address)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionErrorResponse = error
                if let responseMessage = transactionResponse?.responseMessage {
                    transactionStatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionErrorResponse)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatusResponse, TransactionStatus.captured)
    }

    func test_credit_capture() {
        // GIVEN
        let authorizeExpectation = expectation(description: "Authorize Expectation")
        var authorizeTransaction: Transaction?
        var authorizeError: Error?

        // WHEN
        card.authorize(amount: 14)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transaction, error in
                authorizeTransaction = transaction
                authorizeError = error
                authorizeExpectation.fulfill()
            }

        // THEN
        wait(for: [authorizeExpectation], timeout: 10.0)
        XCTAssertNotNil(authorizeTransaction)
        XCTAssertNil(authorizeError)

        // GIVEN
        let captureExpectation = expectation(description: "Capture Expectation")
        var captureTransaction: Transaction?
        var captureError: Error?

        // WHEN
        authorizeTransaction?
            .capture(amount: 16)
            .withGratuity(2)
            .execute(completion: { transaction, error in
                captureTransaction = transaction
                captureError = error
                captureExpectation.fulfill()
            })

        // THEN
        wait(for: [captureExpectation], timeout: 10.0)
        XCTAssertNotNil(captureTransaction)
        XCTAssertNil(captureError)
    }

    func test_credit_refund() {
        // GIVEN
        let executeExpectation = expectation(description: "Credit Refund")
        var transactionResponse: Transaction?
        var transactionErrorResponse: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        card.refund(amount: 16)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionErrorResponse = error
                if let responseMessage = transactionResponse?.responseMessage {
                    transactionStatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionErrorResponse)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatusResponse, TransactionStatus.captured)
    }

    func test_credit_refund_transaction() {
        // GIVEN
        let transactionExecuteExpectation = expectation(description: "Credit Refund")
        var transactionResponse: Transaction?
        var transactionErrorResponse: Error?
        var transactionStatus: TransactionStatus?

        // WHEN
        card.charge(amount: 10.95)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionErrorResponse = error
                if let responseMessage = transaction?.responseMessage {
                    transactionStatus = TransactionStatus(rawValue: responseMessage)
                }
                transactionExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [transactionExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionErrorResponse)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatus, TransactionStatus.captured)

        // GIVEN
        let cardExecuteExpectation = expectation(description: "Credit Refund")
        var statusResponse: TransactionStatus?
        var cardResponse: Transaction?
        var cardErrorResponse: Error?

        // WHEN
        transactionResponse?.refund(amount: 10.95)
            .withCurrency("USD")
            .execute(completion: { transaction, error in
                cardResponse = transaction
                cardErrorResponse = error
                if let responseMessage = cardResponse?.responseMessage {
                    statusResponse = TransactionStatus(rawValue: responseMessage)
                }
                cardExecuteExpectation.fulfill()
            })

        // THEN
        wait(for: [cardExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(cardResponse)
        XCTAssertNil(cardErrorResponse)
        XCTAssertEqual(cardResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(statusResponse, TransactionStatus.captured)
    }

    func test_credit_reverse_transaction() {
        // GIVEN
        let transactionExpectation = expectation(description: "Transaction")
        var transactionResponse: Transaction?
        var transactionError: Error?
        var transactionStatus: TransactionStatus?

        // WHEN
        card.charge(amount: 12.99)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionError = error
                if let responseMessage = transaction?.responseMessage {
                    transactionStatus = TransactionStatus(rawValue: responseMessage)
                }
                transactionExpectation.fulfill()
            }

        // THEN
        wait(for: [transactionExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatus, TransactionStatus.captured)

        // GIVEN
        let reverseExpectation = expectation(description: "Response")
        var reverseResponse: Transaction?
        var reverseError: Error?
        var statusResponse: TransactionStatus?

        // WHEN
        transactionResponse?
            .reverse(amount: 12.99)
            .execute { transaction, error in
                reverseResponse = transaction
                reverseError = error
                if let responseMessage = reverseResponse?.responseMessage {
                    statusResponse = TransactionStatus(rawValue: responseMessage)
                }
                reverseExpectation.fulfill()
            }

        // THEN
        wait(for: [reverseExpectation], timeout: 10.0)
        XCTAssertNotNil(reverseResponse)
        XCTAssertNil(reverseError)
        XCTAssertEqual(reverseResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(statusResponse, TransactionStatus.reversed)
    }

    func test_credit_partial_reverse_transaction() {
        // GIVEN
        let transactionExpectation = expectation(description: "Transaction")
        var transactionResponse: Transaction?
        var transactionError: Error?
        var transactionStatus: TransactionStatus?

        // WHEN
        card.charge(amount: 3.99)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionError = error
                if let responseMessage = transaction?.responseMessage {
                    transactionStatus = TransactionStatus(rawValue: responseMessage)
                }
                transactionExpectation.fulfill()
            }

        // THEN
        wait(for: [transactionExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatus, TransactionStatus.captured)

        // GIVEN
        let errorExpectation = expectation(description: "Error Expectation")
        var failedTransaction: Transaction?
        var failedError: GatewayException?

        // WHEN
        transactionResponse?
            .reverse(amount: 1.29)
            .execute { transaction, error in
                failedTransaction = transaction
                if let error = error as? GatewayException {
                    failedError = error
                }
                errorExpectation.fulfill()
            }

        // THEN
        wait(for: [errorExpectation], timeout: 10.0)
        XCTAssertNil(failedTransaction)
        XCTAssertNotNil(failedError)
        XCTAssertEqual(failedError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(failedError?.responseMessage, "40006")
        XCTAssertEqual(failedError?.message, "Status Code: 400 - partial reversal not supported")
    }

    func test_credit_authorization_for_multi_capture() {
        // GIVEN
        let transactionExpectation = expectation(description: "Transaction")
        var transactionResponse: Transaction?
        var transactionError: Error?
        var statusResponse: TransactionStatus?

        // WHEN
        card.authorize(amount: 14)
            .withCurrency("USD")
            .withMultiCapture(true)
            .withAllowDuplicates(true)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionError = error
                if let responseMessage = transactionResponse?.responseMessage {
                    statusResponse = TransactionStatus(rawValue: responseMessage)
                }
                transactionExpectation.fulfill()
            }

        // THEN
        wait(for: [transactionExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(statusResponse, TransactionStatus.preauthorized)

        // GIVEN
        let capture1Expectation = expectation(description: "Capture 1")
        var capture1Response: Transaction?
        var capture1Error: Error?
        var capture1StatusResponse: TransactionStatus?

        // WHEN
        transactionResponse?
            .capture(amount: 3)
            .execute(completion: { capture, error in
                capture1Response = capture
                capture1Error = error
                if let responseMessage = capture?.responseMessage {
                    capture1StatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                capture1Expectation.fulfill()
            }
            )

        // THEN
        wait(for: [capture1Expectation], timeout: 10.0)
        XCTAssertNotNil(capture1Response)
        XCTAssertNil(capture1Error)
        XCTAssertEqual(capture1Response?.responseCode, "SUCCESS")
        XCTAssertEqual(capture1StatusResponse, TransactionStatus.captured)

        // GIVEN
        let capture2Expectation = expectation(description: "Capture 2")
        var capture2Response: Transaction?
        var capture2Error: Error?
        var capture2StatusResponse: TransactionStatus?

        // WHEN
        transactionResponse?
            .capture(amount: 5)
            .execute(completion: { capture, error in
                capture2Response = capture
                capture2Error = error
                if let responseMessage = capture?.responseMessage {
                    capture2StatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                capture2Expectation.fulfill()
            }
            )

        // THEN
        wait(for: [capture2Expectation], timeout: 10.0)
        XCTAssertNotNil(capture2Response)
        XCTAssertNil(capture2Error)
        XCTAssertEqual(capture2Response?.responseCode, "SUCCESS")
        XCTAssertEqual(capture2StatusResponse, TransactionStatus.captured)

        // GIVEN
        let capture3Expectation = expectation(description: "Capture 3")
        var capture3Response: Transaction?
        var capture3Error: Error?
        var capture3StatusResponse: TransactionStatus?

        // WHEN
        transactionResponse?
            .capture(amount: 7)
            .execute(completion: { capture, error in
                capture3Response = capture
                capture3Error = error
                if let responseMessage = capture?.responseMessage {
                    capture3StatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                capture3Expectation.fulfill()
            }
            )

        // THEN
        wait(for: [capture3Expectation], timeout: 10.0)
        XCTAssertNotNil(capture3Response)
        XCTAssertNil(capture3Error)
        XCTAssertEqual(capture3Response?.responseCode, "SUCCESS")
        XCTAssertEqual(capture3StatusResponse, TransactionStatus.captured)
    }
}
