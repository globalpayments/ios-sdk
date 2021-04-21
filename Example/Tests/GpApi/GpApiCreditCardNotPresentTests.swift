import XCTest
import GlobalPayments_iOS_SDK

class GpApiCreditCardNotPresentTests: XCTestCase {
    var card: CreditCardData!

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
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

    // MARK: - Authorization

    func test_credit_authorization() {
        // GIVEN
        let cardExecuteExpectation = expectation(description: "Card")
        var transactionResponse: Transaction?
        var transactionErrorResponse: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        card.authorize(amount: 14)
            .withCurrency("GBP")
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
    }

    func test_credit_authorization_then_capture() {
        // GIVEN
        let cardExecuteExpectation = expectation(description: "Card")
        var transactionResponse: Transaction?
        var transactionErrorResponse: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        card.authorize(amount: 14)
            .withCurrency("GBP")
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

        // THEN
        wait(for: [transactionExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(captureResponse)
        XCTAssertNil(captureErrorResponse)
        XCTAssertEqual(captureStatusResponse, TransactionStatus.captured)
    }

    func test_credit_authorization_then_capture_with_idempotency_key() {
        // GIVEN
        let cardExecuteExpectation = expectation(description: "Card")
        let idempotencyKey = UUID().uuidString
        var transactionResponse: Transaction?
        var transactionErrorResponse: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        card.authorize(amount: 14)
            .withCurrency("GBP")
            .withIdempotencyKey(idempotencyKey)
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
        var captureErrorResponse: GatewayException?

        // WHEN
        transactionResponse?
            .capture(amount: 16)
            .withIdempotencyKey(idempotencyKey)
            .withGratuity(2)
            .execute(completion: { capture, error in
                captureResponse = capture
                if let error = error as? GatewayException {
                    captureErrorResponse = error
                }
                transactionExecuteExpectation.fulfill()
            })

        // THEN
        wait(for: [transactionExecuteExpectation], timeout: 10.0)
        XCTAssertNil(captureResponse)
        XCTAssertNotNil(captureErrorResponse)
        XCTAssertEqual(captureErrorResponse?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(captureErrorResponse?.responseMessage, "40039")
    }

    func test_credit_authorization_for_multi_capture() {
        // GIVEN
        let transactionExpectation = expectation(description: "Transaction")
        var transactionResponse: Transaction?
        var transactionError: Error?
        var statusResponse: TransactionStatus?

        // WHEN
        card.authorize(amount: 14)
            .withCurrency("GBP")
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

    func test_credit_authorization_capture_lower_amount() {

        // Authorize

        // GIVEN
        let authorizeExpectation = expectation(description: "Authorize Expectation")
        var authorizeTransactionResult: Transaction?
        var authorizeTransactionError: Error?

        // WHEN
        card.authorize(amount: 6)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute {
                authorizeTransactionResult = $0
                authorizeTransactionError = $1
                authorizeExpectation.fulfill()
            }

        // THEN
        wait(for: [authorizeExpectation], timeout: 10.0)
        XCTAssertNil(authorizeTransactionError)
        XCTAssertNotNil(authorizeTransactionResult)
        XCTAssertEqual(authorizeTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(authorizeTransactionResult?.responseMessage, TransactionStatus.preauthorized.mapped(for: .gpApi))

        // Capture

        // GIVEN
        let captureExpectation = expectation(description: "Capture Expectation")
        var captureTransactionResult: Transaction?
        var captureTransactionError: Error?

        // WHEN
        authorizeTransactionResult?
            .capture(amount: 2.99)
            .withGratuity(2)
            .execute {
                captureTransactionResult = $0
                captureTransactionError = $1
                captureExpectation.fulfill()
            }

        // THEN
        wait(for: [captureExpectation], timeout: 10.0)
        XCTAssertNil(captureTransactionError)
        XCTAssertNotNil(captureTransactionResult)
        XCTAssertEqual(captureTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(captureTransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_credit_authorization_capture_higher_amount() {

        // Authorize

        // GIVEN
        let amount: NSDecimalNumber = 10
        let maximumAmount: NSDecimalNumber = amount.multiplying(by: 1.15)
        let authorizeExpectation = expectation(description: "Authorize Expectation")
        var authorizeTransactionResult: Transaction?
        var authorizeTransactionError: Error?

        // WHEN
        card.authorize(amount: amount)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute {
                authorizeTransactionResult = $0
                authorizeTransactionError = $1
                authorizeExpectation.fulfill()
            }

        // THEN
        wait(for: [authorizeExpectation], timeout: 10.0)
        XCTAssertNil(authorizeTransactionError)
        XCTAssertNotNil(authorizeTransactionResult)
        XCTAssertEqual(authorizeTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(authorizeTransactionResult?.responseMessage, TransactionStatus.preauthorized.mapped(for: .gpApi))

        // Capture

        // GIVEN
        let captureExpectation = expectation(description: "Capture Expectation")
        var captureTransactionResult: Transaction?
        var captureTransactionError: Error?

        // WHEN
        authorizeTransactionResult?
            .capture(amount: maximumAmount)
            .execute {
                captureTransactionResult = $0
                captureTransactionError = $1
                captureExpectation.fulfill()
            }

        // THEN
        wait(for: [captureExpectation], timeout: 10.0)
        XCTAssertNil(captureTransactionError)
        XCTAssertNotNil(captureTransactionResult)
        XCTAssertEqual(captureTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(captureTransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_credit_authorization_capture_higher_amount_fails() {

        // Authorize

        // GIVEN
        let amount: NSDecimalNumber = 10
        let maximumAmount: NSDecimalNumber = amount.multiplying(by: 1.16)
        let authorizeExpectation = expectation(description: "Authorize Expectation")
        var authorizeTransactionResult: Transaction?
        var authorizeTransactionError: Error?

        // WHEN
        card.authorize(amount: amount)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute {
                authorizeTransactionResult = $0
                authorizeTransactionError = $1
                authorizeExpectation.fulfill()
            }

        // THEN
        wait(for: [authorizeExpectation], timeout: 10.0)
        XCTAssertNil(authorizeTransactionError)
        XCTAssertNotNil(authorizeTransactionResult)
        XCTAssertEqual(authorizeTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(authorizeTransactionResult?.responseMessage, TransactionStatus.preauthorized.mapped(for: .gpApi))

        // Capture

        // GIVEN
        let captureExpectation = expectation(description: "Capture Expectation")
        var captureTransactionResult: Transaction?
        var captureTransactionError: GatewayException?

        // WHEN
        authorizeTransactionResult?
            .capture(amount: maximumAmount)
            .execute {
                captureTransactionResult = $0
                if let error = $1 as? GatewayException {
                    captureTransactionError = error
                }
                captureExpectation.fulfill()
            }

        // THEN
        wait(for: [captureExpectation], timeout: 10.0)
        XCTAssertNil(captureTransactionResult)
        XCTAssertNotNil(captureTransactionError)
        XCTAssertEqual(captureTransactionError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(captureTransactionError?.responseMessage, "50020")
        if let message = captureTransactionError?.message {
            XCTAssertTrue(message.contains("Status Code: 400 - Can\'t settle for more than 115% of that which you authorised."))
        } else {
            XCTFail("captureTransactionError message cannot be nil")
        }
    }

    // MARK: - Capture

    func test_credit_capture() {
        // GIVEN
        let authorizeExpectation = expectation(description: "Authorize Expectation")
        var authorizeTransaction: Transaction?
        var authorizeError: Error?

        // WHEN
        card.authorize(amount: 14)
            .withCurrency("GBP")
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

    func test_credit_capture_wrong_id() {
        // GIVEN
        let creditCaptureExpectation = expectation(description: "Credit Capture Expectation")
        let authorization = Transaction()
        authorization.transactionId = "UNKNOWN"
        var transactionResult: Transaction?
        var gatewayException: GatewayException?

        // WHEN
        authorization
            .capture(amount: 16)
            .withGratuity(2)
            .execute {
                transactionResult = $0
                if let exception = $1 as? GatewayException? {
                    gatewayException = exception
                }
                creditCaptureExpectation.fulfill()
            }

        // THEN
        wait(for: [creditCaptureExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(gatewayException)
        XCTAssertEqual(gatewayException?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(gatewayException?.responseMessage, "40118")
    }

    func test_credit_capture_then_refund_higher_amount() {

        // Authorize

        // GIVEN
        let authorizeExpectation = expectation(description: "Authorize Expectation")
        var authorizeTransactionResult: Transaction?
        var authorizeTransactionError: Error?

        // WHEN
        card.authorize(amount: 55)
            .withCurrency("GBP")
            .execute {
                authorizeTransactionResult = $0
                authorizeTransactionError = $1
                authorizeExpectation.fulfill()
            }

        // THEN
        wait(for: [authorizeExpectation], timeout: 10.0)
        XCTAssertNil(authorizeTransactionError)
        XCTAssertNotNil(authorizeTransactionResult)
        XCTAssertEqual(authorizeTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(authorizeTransactionResult?.responseMessage, TransactionStatus.preauthorized.mapped(for: .gpApi))

        // Capture

        // GIVEN
        let captureExpectation = expectation(description: "Capture Expectation")
        var captureTransactionResult: Transaction?
        var captureTransactionError: Error?

        // WHEN
        authorizeTransactionResult?
            .capture(amount: 55)
            .execute {
                captureTransactionResult = $0
                captureTransactionError = $1
                captureExpectation.fulfill()
            }

        // THEN
        wait(for: [captureExpectation], timeout: 10.0)
        XCTAssertNil(captureTransactionError)
        XCTAssertNotNil(captureTransactionResult)
        XCTAssertEqual(captureTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(captureTransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))

        // Refund

        // GIVEN
        let refundExpectation = expectation(description: "Refund Expectation")
        var refundTransactionResult: Transaction?
        var refundTransactionError: GatewayException?

        // WHEN
        authorizeTransactionResult?
            .refund(amount: 65)
            .withCurrency("GBP")
            .execute {
                refundTransactionResult = $0
                if let error = $1 as? GatewayException {
                    refundTransactionError = error
                }
                refundExpectation.fulfill()
            }

        // THEN
        wait(for: [refundExpectation], timeout: 10.0)
        XCTAssertNil(refundTransactionResult)
        XCTAssertNotNil(refundTransactionError)
        XCTAssertEqual(refundTransactionError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(refundTransactionError?.responseMessage, "40087")
        if let message = refundTransactionError?.message {
            XCTAssertEqual(message, "Status Code: 400 - You may only refund up to 100% of the original amount.")
        } else {
            XCTFail("refundTransactionError message cannot be nil")
        }
    }

    // MARK: - Sale

    func test_credit_sale() {
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
            .withCurrency("GBP")
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

    func test_credit_sale_with_stored_credentials() {
        // GIVEN
        let tokenizeException = expectation(description: "Tokenize Exception")
        var token: String?
        var tokenError: Error?

        // WHEN
        card.tokenize {
            token = $0
            tokenError = $1
            tokenizeException.fulfill()
        }

        // THEN
        wait(for: [tokenizeException], timeout: 10.0)
        XCTAssertNil(tokenError)
        XCTAssertNotNil(token)

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        let storedCredentials = StoredCredential(type: .installment,
                                                 initiator: .merchant,
                                                 sequence: .subsequent,
                                                 reason: .incremental)
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        tokenizedCard.cardHolderName = "James Mason"
        var chargeResult: Transaction?
        var chargeResultError: Error?

        // WHEN
        tokenizedCard
            .charge(amount: 50.0)
            .withCurrency("GBP")
            .withStoredCredential(storedCredentials)
            .execute {
                chargeResult = $0
                chargeResultError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeResultError)
        XCTAssertNotNil(chargeResult)
        XCTAssertEqual(chargeResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeResult?.responseMessage, TransactionStatus.captured.rawValue)
    }

    func test_credit_sale_with_request_multi_use_token() {
        // GIVEN
        let chargeExpectation = expectation(description: "Charge Exception")
        var chargeResult: Transaction?
        var chargeResultError: Error?

        // WHEN
        card.charge(amount: 19.99)
            .withCurrency("GBP")
            .withRequestMultiUseToken(true)
            .execute {
                chargeResult = $0
                chargeResultError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeResultError)
        XCTAssertNotNil(chargeResult)
        XCTAssertEqual(chargeResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeResult?.responseMessage, TransactionStatus.captured.rawValue)
        if let result = chargeResult?.token {
            XCTAssertTrue(result.contains("PMT_"))
        } else {
            XCTFail("chargeResult token cannot be nil")
        }
    }

    // MARK: - Refund

    func test_credit_refund() {

        // Charge

        // GIVEN
        let amount: NSDecimalNumber = 10.95
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        card.charge(amount: amount)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeTransactionError)
        XCTAssertNotNil(chargeTransactionResult)
        XCTAssertEqual(chargeTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeTransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))

        // Refund

        // GIVEN
        let refundExpectation = expectation(description: "Refund Expectation")
        var refundTransactionResult: Transaction?
        var refundTransactionError: Error?

        // WHEN
        chargeTransactionResult?
            .refund(amount: amount)
            .withCurrency("USD")
            .execute {
                refundTransactionResult = $0
                refundTransactionError = $1
                refundExpectation.fulfill()
            }

        // THEN
        wait(for: [refundExpectation], timeout: 10.0)
        XCTAssertNil(refundTransactionError)
        XCTAssertNotNil(refundTransactionResult)
        XCTAssertEqual(refundTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(refundTransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_credit_multi_refund() {

        // Charge

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        card.charge(amount: 30)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeTransactionError)
        XCTAssertNotNil(chargeTransactionResult)
        XCTAssertEqual(chargeTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeTransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))

        // Refund - 1

        // GIVEN
        let refund1Expectation = expectation(description: "Refund Expectation")
        var refund1TransactionResult: Transaction?
        var refund1TransactionError: Error?

        // WHEN
        chargeTransactionResult?
            .refund(amount: 10)
            .withCurrency("USD")
            .execute {
                refund1TransactionResult = $0
                refund1TransactionError = $1
                refund1Expectation.fulfill()
            }

        // THEN
        wait(for: [refund1Expectation], timeout: 10.0)
        XCTAssertNil(refund1TransactionError)
        XCTAssertNotNil(refund1TransactionResult)
        XCTAssertEqual(refund1TransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(refund1TransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))

        // Refund - 2

        // GIVEN
        let refund2Expectation = expectation(description: "Refund Expectation")
        var refund2TransactionResult: Transaction?
        var refund2TransactionError: Error?

        // WHEN
        chargeTransactionResult?
            .refund(amount: 10)
            .withCurrency("USD")
            .execute {
                refund2TransactionResult = $0
                refund2TransactionError = $1
                refund2Expectation.fulfill()
            }

        // THEN
        wait(for: [refund2Expectation], timeout: 10.0)
        XCTAssertNil(refund2TransactionError)
        XCTAssertNotNil(refund2TransactionResult)
        XCTAssertEqual(refund2TransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(refund2TransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))

        // Refund - 3

        // GIVEN
        let refund3Expectation = expectation(description: "Refund Expectation")
        var refund3TransactionResult: Transaction?
        var refund3TransactionError: Error?

        // WHEN
        chargeTransactionResult?
            .refund(amount: 10)
            .withCurrency("USD")
            .execute {
                refund3TransactionResult = $0
                refund3TransactionError = $1
                refund3Expectation.fulfill()
            }

        // THEN
        wait(for: [refund3Expectation], timeout: 10.0)
        XCTAssertNil(refund3TransactionError)
        XCTAssertNotNil(refund3TransactionResult)
        XCTAssertEqual(refund3TransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(refund3TransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))

        // Refund - 4 (over original amount)

        // GIVEN
        let refund4Expectation = expectation(description: "Refund Expectation")
        var refund4TransactionResult: Transaction?
        var refund4TransactionError: GatewayException?

        // WHEN
        chargeTransactionResult?
            .refund(amount: 10)
            .withCurrency("USD")
            .execute {
                refund4TransactionResult = $0
                if let error = $1 as? GatewayException {
                    refund4TransactionError = error
                }
                refund4Expectation.fulfill()
            }

        // THEN
        wait(for: [refund4Expectation], timeout: 10.0)
        XCTAssertNil(refund4TransactionResult)
        XCTAssertNotNil(refund4TransactionError)
        XCTAssertEqual(refund4TransactionError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(refund4TransactionError?.responseMessage, "40087")
        if let message = refund4TransactionError?.message {
            XCTAssertTrue(message.contains("Status Code: 400 - You may only refund up to 100% of the original amount."))
        } else {
            XCTFail("refund4TransactionError message cannot be nil")
        }
    }

    func test_credit_multi_refund_without_specifiying_remaining_amount() {

        // Charge

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        card.charge(amount: 50)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeTransactionError)
        XCTAssertNotNil(chargeTransactionResult)
        XCTAssertEqual(chargeTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeTransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))

        // Refund - 1

        // GIVEN
        let refund1Expectation = expectation(description: "Refund Expectation")
        var refund1TransactionResult: Transaction?
        var refund1TransactionError: Error?

        // WHEN
        chargeTransactionResult?
            .refund(amount: 22)
            .withCurrency("USD")
            .execute {
                refund1TransactionResult = $0
                refund1TransactionError = $1
                refund1Expectation.fulfill()
            }

        // THEN
        wait(for: [refund1Expectation], timeout: 10.0)
        XCTAssertNil(refund1TransactionError)
        XCTAssertNotNil(refund1TransactionResult)
        XCTAssertEqual(refund1TransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(refund1TransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))

        // Refund - 2

        // GIVEN
        let refund2Expectation = expectation(description: "Refund Expectation")
        var refund2TransactionResult: Transaction?
        var refund2TransactionError: Error?

        // WHEN
        chargeTransactionResult?
            .refund()
            .withCurrency("USD")
            .execute {
                refund2TransactionResult = $0
                refund2TransactionError = $1
                refund2Expectation.fulfill()
            }

        // THEN
        wait(for: [refund2Expectation], timeout: 10.0)
        XCTAssertNil(refund2TransactionError)
        XCTAssertNotNil(refund2TransactionResult)
        XCTAssertEqual(refund2TransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(refund2TransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_credit_refund_transaction_lower_amount() {

        // Charge

        // GIVEN
        let amount: NSDecimalNumber = 5.95
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        card.charge(amount: amount)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeTransactionError)
        XCTAssertNotNil(chargeTransactionResult)
        XCTAssertEqual(chargeTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeTransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))

        // Refund

        // GIVEN
        let refundExpectation = expectation(description: "Refund Expectation")
        var refundTransactionResult: Transaction?
        var refundTransactionError: Error?

        // WHEN
        chargeTransactionResult?
            .refund(amount: 2.25)
            .withCurrency("USD")
            .execute {
                refundTransactionResult = $0
                refundTransactionError = $1
                refundExpectation.fulfill()
            }

        // THEN
        wait(for: [refundExpectation], timeout: 10.0)
        XCTAssertNil(refundTransactionError)
        XCTAssertNotNil(refundTransactionResult)
        XCTAssertEqual(refundTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(refundTransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_credit_refund_transaction_higher_amount_fails() {

        // Charge

        // GIVEN
        let amount: NSDecimalNumber = 5.95
        let expectedAmount: NSDecimalNumber = amount.multiplying(by: 1.1)
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        card.charge(amount: amount)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeTransactionError)
        XCTAssertNotNil(chargeTransactionResult)
        XCTAssertEqual(chargeTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeTransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))

        // Refund

        // GIVEN
        let refundExpectation = expectation(description: "Refund Expectation")
        var refundTransactionResult: Transaction?
        var refundTransactionError: GatewayException?

        // WHEN
        chargeTransactionResult?
            .refund(amount: expectedAmount)
            .withCurrency("USD")
            .execute {
                refundTransactionResult = $0
                if let error = $1 as? GatewayException {
                    refundTransactionError = error
                }
                refundExpectation.fulfill()
            }

        // THEN
        wait(for: [refundExpectation], timeout: 10.0)
        XCTAssertNil(refundTransactionResult)
        XCTAssertNotNil(refundTransactionError)
        XCTAssertEqual(refundTransactionError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(refundTransactionError?.responseMessage, "40087")
        if let message = refundTransactionError?.message {
            XCTAssertTrue(message.contains("Status Code: 400 - You may only refund up to 100% of the original amount."))
        } else {
            XCTFail("refundTransactionError message cannot be nil")
        }
    }

    func test_credit_refund_transaction() {
        // GIVEN
        let transactionExecuteExpectation = expectation(description: "Credit Refund")
        var transactionResponse: Transaction?
        var transactionErrorResponse: Error?
        var transactionStatus: TransactionStatus?

        // WHEN
        card.charge(amount: 10.95)
            .withCurrency("GBP")
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
        transactionResponse?
            .refund(amount: 10.95)
            .withCurrency("GBP")
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

    func test_credit_partial_refund_transaction() {
        // GIVEN
        let transactionChargeExpectation = expectation(description: "Transaction Charge Expectation")
        var transactionCharge: Transaction?
        var transactionChargeError: Error?
        var transactionChargeStatus: String?

        // WHEN
        card.charge(amount: 50.0)
            .withCurrency("GBP")
            .withAllowDuplicates(true)
            .execute {
                transactionCharge = $0
                transactionChargeError = $1
                transactionChargeStatus = $0?.responseMessage
                transactionChargeExpectation.fulfill()
            }

        // THEN
        wait(for: [transactionChargeExpectation], timeout: 10.0)
        XCTAssertNil(transactionChargeError)
        XCTAssertNotNil(transactionCharge)
        XCTAssertNotNil(transactionChargeStatus)
        XCTAssertEqual(transactionCharge?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionChargeStatus, TransactionStatus.captured.rawValue)

        // GIVEN
        let partialRefundExpectation = expectation(description: "Partial Refund Expectation")
        let defaultRefundExpectation = expectation(description: "Default Refund Expectation")
        var partialRefund: Transaction?
        var defaultRefund: Transaction?
        var partialRefundError: Error?
        var defaultRefundError: Error?

        // WHEN
        transactionCharge?
            .refund(amount: 10)
            .withCurrency("GBP")
            .execute(completion: {
                partialRefund = $0
                partialRefundError = $1
                partialRefundExpectation.fulfill()
            })

        transactionCharge?
            .refund()
            .withCurrency("GBP")
            .execute(completion: {
                defaultRefund = $0
                defaultRefundError = $1
                defaultRefundExpectation.fulfill()
            })

        // THEN
        wait(for: [partialRefundExpectation, defaultRefundExpectation], timeout: 20.0)
        XCTAssertNil(partialRefundError)
        XCTAssertNil(defaultRefundError)
        XCTAssertNotNil(partialRefund)
        XCTAssertNotNil(defaultRefund)
        XCTAssertEqual(partialRefund?.responseCode, "SUCCESS")
        XCTAssertEqual(defaultRefund?.responseCode, "SUCCESS")
        XCTAssertEqual(partialRefund?.responseMessage, TransactionStatus.captured.rawValue)
        XCTAssertEqual(defaultRefund?.responseMessage, TransactionStatus.captured.rawValue)
    }

    func test_credit_refund_transaction_with_idempotency_key() {
        // GIVEN
        let transactionExecuteExpectation = expectation(description: "transaction execute expectation")
        var transactionChargeResponse: Transaction?
        var transactionChargeErrorResponse: Error?
        var transactionStatus: TransactionStatus?
        let idempotencyKey = UUID().uuidString

        // WHEN
        card.charge(amount: 10.95)
            .withCurrency("GBP")
            .withIdempotencyKey(idempotencyKey)
            .withAllowDuplicates(true)
            .execute { transaction, error in
                transactionChargeResponse = transaction
                transactionChargeErrorResponse = error
                if let responseMessage = transaction?.responseMessage {
                    transactionStatus = TransactionStatus(rawValue: responseMessage)
                }
                transactionExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [transactionExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionChargeResponse)
        XCTAssertNil(transactionChargeErrorResponse)
        XCTAssertEqual(transactionChargeResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatus, TransactionStatus.captured)

        // GIVEN
        let cardExecuteExpectation = expectation(description: "card execute expectation")
        var transactionRefundResponse: Transaction?
        var transactionRefundErrorResponse: GatewayException?

        // WHEN
        transactionChargeResponse?
            .refund(amount: 10.95)
            .withCurrency("GBP")
            .withIdempotencyKey(idempotencyKey)
            .execute(completion: {
                transactionRefundResponse = $0
                if let error = $1 as? GatewayException {
                    transactionRefundErrorResponse = error
                }
                cardExecuteExpectation.fulfill()
            })

        // THEN
        wait(for: [cardExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionRefundErrorResponse)
        XCTAssertNil(transactionRefundResponse)
        XCTAssertEqual(transactionRefundErrorResponse?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(transactionRefundErrorResponse?.responseMessage, "40039")
    }

    func test_credit_refund_transaction_wrong_id() {
        // GIVEN
        let transactionExpectation = expectation(description: "Transaction")
        let charge = Transaction()
        charge.transactionId = "UNKNOWN"
        var transactionResponse: Transaction?
        var transactionError: GatewayException?

        // WHEN
        charge
            .refund(amount: 10.95)
            .withCurrency("GBP")
            .execute {
                transactionResponse = $0
                if let error = $1 as? GatewayException {
                    transactionError = error
                }
                transactionExpectation.fulfill()
            }

        // THEN
        wait(for: [transactionExpectation], timeout: 10.0)
        XCTAssertNil(transactionResponse)
        XCTAssertNotNil(transactionError)
        XCTAssertEqual(transactionError?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(transactionError?.responseMessage, "40118")
    }

    // MARK: - Reverse

    func test_credit_reverse_transaction() {
        // GIVEN
        let transactionExpectation = expectation(description: "Transaction")
        var transactionResponse: Transaction?
        var transactionError: Error?
        var transactionStatus: TransactionStatus?

        // WHEN
        card.charge(amount: 12.99)
            .withCurrency("GBP")
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

    func test_credit_reverse_transaction_with_idempotency_key() {
        // GIVEN
        let transactionExpectation = expectation(description: "Transaction")
        var transactionResponse: Transaction?
        var transactionError: Error?
        var transactionStatus: TransactionStatus?
        let idempotencyKey = UUID().uuidString

        // WHEN
        card.charge(amount: 12.99)
            .withCurrency("GBP")
            .withIdempotencyKey(idempotencyKey)
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
        var reverseError: GatewayException?

        // WHEN
        transactionResponse?
            .reverse(amount: 12.99)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                reverseResponse = $0
                if let error = $1 as? GatewayException {
                    reverseError = error
                }
                reverseExpectation.fulfill()
            }

        // THEN
        wait(for: [reverseExpectation], timeout: 10.0)
        XCTAssertNil(reverseResponse)
        XCTAssertNotNil(reverseError)
        XCTAssertEqual(reverseError?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(reverseError?.responseMessage, "40039")
    }

    func test_credit_reverse_transaction_wrong_id() {
        // GIVEN
        let transactionExpectation = expectation(description: "Transaction")
        let charge = Transaction()
        charge.transactionId = "UNKNOWN"
        var transactionResponse: Transaction?
        var transactionError: GatewayException?

        // WHEN
        charge.reverse(amount: 12.99)
            .execute {
                transactionResponse = $0
                if let error = $1 as? GatewayException {
                    transactionError = error
                }
                transactionExpectation.fulfill()
            }

        // THEN
        wait(for: [transactionExpectation], timeout: 10.0)
        XCTAssertNil(transactionResponse)
        XCTAssertNotNil(transactionError)
        XCTAssertEqual(transactionError?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(transactionError?.responseMessage, "40118")
    }

    func test_credit_partial_reverse_transaction() {
        // GIVEN
        let transactionExpectation = expectation(description: "Transaction")
        var transactionResponse: Transaction?
        var transactionError: Error?
        var transactionStatus: TransactionStatus?

        // WHEN
        card.charge(amount: 3.99)
            .withCurrency("GBP")
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
        XCTAssertEqual(failedError?.responseMessage, "40214")
        XCTAssertEqual(failedError?.message, "Status Code: 400 - partial reversal not supported")
    }

    // MARK: - Verify

    func test_credit_verify() {
        // GIVEN
        let verifyExpectation = expectation(description: "Verify Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card?.verify()
            .withCurrency("GBP")
            .execute(completion: { transaction, error in
                transactionResult = transaction
                transactionError = error
                verifyExpectation.fulfill()
            })

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, "VERIFIED")
    }

    func test_credit_verify_with_address() {
        // GIVEN
        let verifyExpectation = expectation(description: "Verify Expectation")
        let address = Address()
        address.postalCode = "WB3 A21"
        address.streetAddress1 = "Flat 456"
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card?.verify()
            .withCurrency("GBP")
            .withAddress(address)
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

    func test_credit_verify_with_idempotency_key() {
        // GIVEN
        let verifyExpectation = expectation(description: "Verify Expectation")
        let idempotencyKey = UUID().uuidString
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card.verify()
            .withCurrency("GBP")
            .withIdempotencyKey(idempotencyKey)
            .execute(completion: { transaction, error in
                transactionResult = transaction
                transactionError = error
                verifyExpectation.fulfill()
            })

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, "VERIFIED")

        // GIVEN
        let verifyIdempotencyExpectation = expectation(description: "Verify Expectation")
        var verifyTransactionResult: Transaction?
        var verifyTransactionError: GatewayException?

        // WHEN
        card.verify()
            .withCurrency("GBP")
            .withIdempotencyKey(idempotencyKey)
            .execute {
                verifyTransactionResult = $0
                if let error = $1 as? GatewayException {
                    verifyTransactionError = error
                }
                verifyIdempotencyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyIdempotencyExpectation], timeout: 10.0)
        XCTAssertNil(verifyTransactionResult)
        XCTAssertNotNil(verifyTransactionError)
        XCTAssertEqual(verifyTransactionError?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(verifyTransactionError?.responseMessage, "40039")
    }

    func test_credit_verify_without_currency() {
        // GIVEN
        let verifyExpectation = expectation(description: "Verify Expectation")
        var transactionResult: Transaction?
        var transactionError: GatewayException?

        // WHEN
        card.verify()
            .execute(completion: {
                transactionResult = $0
                if let error = $1 as? GatewayException {
                    transactionError = error
                }
                verifyExpectation.fulfill()
            })

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
        XCTAssertEqual(transactionError?.responseCode, "MANDATORY_DATA_MISSING")
        XCTAssertEqual(transactionError?.responseMessage, "40005")
    }

    func test_credit_verify_invalid_cvv() {
        // GIVEN
        let verifyExpectation = expectation(description: "Verify Expectation")
        var transactionResult: Transaction?
        var transactionError: GatewayException?

        // WHEN
        card.cvn = "1234"
        card.verify()
            .withCurrency("EUR")
            .execute(completion: {
                transactionResult = $0
                if let error = $1 as? GatewayException {
                    transactionError = error
                }
                verifyExpectation.fulfill()
            })

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
        XCTAssertEqual(transactionError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(transactionError?.responseMessage, "40085")
    }

    // MARK: - Charge

    func test_credit_charge_transactions_with_same_idempotency_key() {
        // GIVEN
        let idempotencyExpectation = expectation(description: "Idempotency Expectation")
        let idempotencyKey = UUID().uuidString
        var transactionResult: Transaction?
        var transactionError: Error?
        var transactionStatus: TransactionStatus?

        // WHEN
        card.charge(amount: 4.95)
            .withIdempotencyKey(idempotencyKey)
            .withCurrency("GBP")
            .execute(completion: {
                transactionResult = $0
                transactionError = $1
                if let responseMessage = $0?.responseMessage {
                    transactionStatus = TransactionStatus(rawValue: responseMessage)
                }
                idempotencyExpectation.fulfill()
            })

        // THEN
        wait(for: [idempotencyExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatus, TransactionStatus.captured)

        // GIVEN
        let dublicateExpectation = expectation(description: "Dublicate Idempotency Expectation")
        var dublicateTransaction: Transaction?
        var gatewayException: GatewayException?

        // WHEN
        card.charge(amount: 4.95)
            .withCurrency("GBP")
            .withIdempotencyKey(idempotencyKey)
            .execute {
                dublicateTransaction = $0
                if let error = $1 as? GatewayException {
                    gatewayException = error
                }
                dublicateExpectation.fulfill()
            }

        // THEN
        wait(for: [dublicateExpectation], timeout: 10.0)
        XCTAssertNil(dublicateTransaction)
        XCTAssertNotNil(gatewayException)
        XCTAssertEqual(gatewayException?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(gatewayException?.responseMessage, "40039")
    }

    // MARK: - Usage mode

    func test_tokenization_then_paying_with_token_single_to_multiple_use() {

        // Tokenization

        // GIVEN
        let tokenizeExpectation = expectation(description: "Tokenize Expectation")
        var tokenizeToken: String?
        var tokenizeError: Error?

        // WHEN
        AuthorizationBuilder(transactionType: .verify, paymentMethod: card)
            .withRequestMultiUseToken(true)
            .withTokenUsageMode(.single)
            .execute {
                tokenizeToken = $0?.token
                tokenizeError = $1
                tokenizeExpectation.fulfill()
            }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNil(tokenizeError)
        XCTAssertNotNil(tokenizeToken)

        // Charge with request multi use token

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = tokenizeToken
        tokenizedCard.cardHolderName = "James Mason"
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        tokenizedCard
            .charge(amount: 10.0)
            .withCurrency("USD")
            .withRequestMultiUseToken(true)
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeTransactionError)
        XCTAssertNotNil(chargeTransactionResult)
        XCTAssertEqual(chargeTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeTransactionResult?.responseMessage, TransactionStatus.captured.rawValue)
        if let result = chargeTransactionResult?.token {
            XCTAssertTrue(result.contains("PMT_"))
        } else {
            XCTFail("tokenizeResult cannot be nil")
        }

        // Charge with updated multi use token

        // GIVEN
        tokenizedCard.token = chargeTransactionResult?.token
        let multiChargeExpectaion = expectation(description: "Multi Charge Expectaion")
        var multiChargeTransactionResult: Transaction?
        var multiChargeTransactionError: Error?

        // WHEN
        tokenizedCard
            .charge(amount: 10.0)
            .withCurrency("USD")
            .execute {
                multiChargeTransactionResult = $0
                multiChargeTransactionError = $1
                multiChargeExpectaion.fulfill()
            }

        // THEN
        wait(for: [multiChargeExpectaion], timeout: 10.0)
        XCTAssertNil(multiChargeTransactionError)
        XCTAssertNotNil(multiChargeTransactionResult)
        XCTAssertEqual(multiChargeTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(multiChargeTransactionResult?.responseMessage, TransactionStatus.captured.rawValue)
    }

    func test_tokenize_payment_method_multiple_usage_mode() {
        // GIVEN
        let tokenizeExpectation = expectation(description: "Tokenize Expectation")
        let cardData = CreditCardData()
        cardData.number = "4111111111111111"
        cardData.expMonth = 12
        cardData.expYear = 2030
        var tokenizeResult: String?
        var tokenizeError: Error?

        // WHEN
        cardData.tokenize {
            tokenizeResult = $0
            tokenizeError = $1
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNil(tokenizeError)
        XCTAssertNotNil(tokenizeResult)
        if let result = tokenizeResult {
            XCTAssertTrue(result.contains("PMT_"))
        } else {
            XCTFail("tokenizeResult cannot be nil")
        }
    }

    func test_tokenize_single_use_then_verify_with_request_multi_use_token() {

        // Tokenize

        // GIVEN
        let card = CreditCardData()
        card.number = "4111111111111111"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 5
        card.cvn = "123"

        let tokenizeExpectation = expectation(description: "Tokenize exception")
        var expectedToken: String?

        // WHEN
        AuthorizationBuilder(transactionType: .verify, paymentMethod: card)
            .withRequestMultiUseToken(true)
            .withTokenUsageMode(.single)
            .withCurrency("USD")
            .execute(completion: { transaction, _ in
                expectedToken = transaction?.token
                tokenizeExpectation.fulfill()
            })

        // THEN
        wait(for: [tokenizeExpectation], timeout: 20.0)
        XCTAssertNotNil(expectedToken)
        XCTAssertNotEqual(expectedToken, "Token could not be generated.")

        // Verify

        // GIVEN
        var transaction: Transaction?
        var error: Error?
        let verifyExpectation = expectation(description: "Verify Expectation")
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = expectedToken

        // WHEN
        tokenizedCard
            .verify()
            .withCurrency("USD")
            .withRequestMultiUseToken(true)
            .execute {
                transaction = $0
                error = $1
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 20.0)
        XCTAssertNil(error)
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction?.responseMessage, "VERIFIED")
        XCTAssertEqual(transaction?.responseCode, "SUCCESS")
    }
}
