import XCTest
import GlobalPayments_iOS_SDK

class GpApiTokenManagementTests: XCTestCase {

    private var card: CreditCardData?
    private var token: String?

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(
            config: GpApiConfig(
                appId: "i872l4VgZRtSrykvSn8Lkah8RE1jihvT",
                appKey: "9pArW2uWoA8enxKc"
            )
        )
    }

    override func setUp() {
        super.setUp()

        // GIVEN
        card = CreditCardData()
        card?.number = "4111111111111111"
        card?.expMonth = 12
        card?.expYear = 2025
        card?.cvn = "123"

        let tokenizeExpectation = expectation(description: "Tokenize exception")
        var expectedToken: String?
        var expectedError: ApiException?

        // WHEN
        card?.tokenize(completion: { [weak self] token, error in
            self?.token = token
            expectedToken = token
            if let error = error as? ApiException {
                expectedError = error
            }
            tokenizeExpectation.fulfill()
        })

        // THEN
        wait(for: [tokenizeExpectation], timeout: 20.0)
        XCTAssertNil(expectedError)
        XCTAssertNotNil(expectedToken)
        XCTAssertNotEqual(expectedToken, "Token could not be generated.")
    }

    override func tearDown() {
        super.tearDown()

        // GIVEN
        let tokenizeExpectation = expectation(description: "Tokenize exception")
        var deleted: Bool?
        var expectedError: Error?
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token

        // WHEN
        tokenizedCard.deleteToken { completed, error in
            deleted = completed
            expectedError = error
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 20.0)
        XCTAssertNil(expectedError)
        XCTAssertNotNil(deleted)
        XCTAssertEqual(deleted, true)

        // GIVEN
        let verifyExpectation = expectation(description: "Verify exception")
        var expectedTransaction: Transaction?
        var expectedVerifyError: GatewayException?

        // WHEN
        tokenizedCard
            .verify()
            .withCurrency("USD")
            .execute {
                expectedTransaction = $0
                if let error = $1 as? GatewayException {
                    expectedVerifyError = error
                }
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(expectedTransaction)
        XCTAssertNotNil(expectedVerifyError)
        XCTAssertEqual(expectedVerifyError?.responseCode, "RESOURCE_NOT_FOUND")
    }

    func test_verify_tokenized_payment_method() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        let verifyExpectation = expectation(description: "Verify Expectation")
        var transactionResult: Transaction?
        var errorResult: Error?

        // WHEN
        tokenizedCard
            .verify()
            .withCurrency("USD")
            .execute {
                transactionResult = $0
                errorResult = $1
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(errorResult)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, "VERIFIED")
    }

    func test_verify_tokenized_payment_method_with_idempotency_key() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        let verifyExpectation = expectation(description: "Verify Expectation")
        let idempotencyKey = UUID().uuidString
        var transactionResult: Transaction?
        var errorResult: Error?

        // WHEN
        tokenizedCard
            .verify()
            .withCurrency("USD")
            .withIdempotencyKey(idempotencyKey)
            .execute {
                transactionResult = $0
                errorResult = $1
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(errorResult)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, "VERIFIED")
        XCTAssertEqual(transactionResult?.cardType, "VISA")

        // GIVEN
        let verifyIdempotencyKeyExpectation = expectation(description: "Verify Idempotency Expectation")
        var verifyTransaction: Transaction?
        var verifyError: GatewayException?

        // WHEN
        tokenizedCard
            .verify()
            .withCurrency("USD")
            .withIdempotencyKey(idempotencyKey)
            .execute {
                verifyTransaction = $0
                if let error = $1 as? GatewayException {
                    verifyError = error
                }
                verifyIdempotencyKeyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyIdempotencyKeyExpectation], timeout: 10.0)
        XCTAssertNil(verifyTransaction)
        XCTAssertNotNil(verifyError)
        XCTAssertEqual(verifyError?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(verifyError?.responseMessage, "40039")
    }

    func test_verify_tokenized_payment_wrong_id() {
        // GIVEN
        let verifyExpectation = expectation(description: "Verify Expectation")
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = "PMT_" + UUID().uuidString
        var transactionResult: Transaction?
        var errorResult: GatewayException?

        // WHEN
        tokenizedCard
            .verify()
            .withCurrency("USD")
            .execute {
                transactionResult = $0
                if let error = $1 as? GatewayException {
                    errorResult = error
                }
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(errorResult)
        XCTAssertEqual(errorResult?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(errorResult?.responseMessage, "40116")
    }

    func test_update_tokenized_payment_method() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        tokenizedCard.expMonth = 12
        tokenizedCard.expYear = 30
        let tokenizeExpectation = expectation(description: "Tokenize Expectation")
        var updatedResult: Bool?
        var errorResult: Error?

        // WHEN
        tokenizedCard.updateTokenExpiry {
            updatedResult = $0
            errorResult = $1
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNotNil(updatedResult)
        XCTAssertNil(errorResult)
        XCTAssertTrue(updatedResult!)

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionErrorResult: Error?

        // WHEN
        tokenizedCard
            .verify()
            .withCurrency("USD")
            .execute {
                transactionResult = $0
                transactionErrorResult = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResult)
        XCTAssertNil(transactionErrorResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, "VERIFIED")
    }

    func test_update_tokenized_payment_method_wrong_id() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = "PMT" + UUID().uuidString
        tokenizedCard.expMonth = 12
        tokenizedCard.expYear = 30
        let tokenizeExpectation = expectation(description: "Tokenize Expectation")
        var updatedResult: Bool?
        var errorResult: GatewayException?

        // WHEN
        tokenizedCard.updateTokenExpiry {
            updatedResult = $0
            if let error = $1 as? GatewayException {
                errorResult = error
            }
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNotNil(updatedResult)
        XCTAssertEqual(updatedResult, false)
        XCTAssertNotNil(errorResult)
        XCTAssertEqual(errorResult?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(errorResult?.responseMessage, "40213")
    }

    func test_credit_sale_with_tokenized_payment_method() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        var transactionResult: Transaction?
        var errorResult: Error?
        let executeExpectation = expectation(description: "Execute Expectation")

        // WHEN
        tokenizedCard
            .charge(amount: 19.99)
            .withCurrency("USD")
            .execute {
                transactionResult = $0
                errorResult = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResult)
        XCTAssertNil(errorResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_credit_sale_with_tokenized_payment_method_with_stored_credentials() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        var transactionResult: Transaction?
        var errorResult: Error?
        let executeExpectation = expectation(description: "Execute Expectation")

        // WHEN
        tokenizedCard
            .charge(amount: 15.25)
            .withCurrency("USD")
            .withStoredCredential(
                StoredCredential(
                    type: .subscription,
                    initiator: .merchant,
                    sequence: .subsequent,
                    reason: .incremental
                )
            ).execute {
                transactionResult = $0
                errorResult = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResult)
        XCTAssertNil(errorResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_credit_tokenization_then_update() {
        // GIVEN
        let tokenizeExpectation = expectation(description: "Tokenize Expectation")
        var token: String?
        var tokenizeError: Error?

        // WHEN
        card?.tokenize {
            token = $0
            tokenizeError = $1
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNil(tokenizeError)
        XCTAssertNotNil(token)

        // GIVEN
        let updateTokenExpiryExpectation = expectation(description: "Update Token Expiry Expectation")
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        tokenizedCard.expYear = Date().currentYear + 1
        tokenizedCard.expMonth = Date().currentMonth
        var updateTokenExpiryResult: Bool?
        var updateTokenExpiryError: Error?

        // WHEN
        tokenizedCard.updateTokenExpiry {
            updateTokenExpiryResult = $0
            updateTokenExpiryError = $1
            updateTokenExpiryExpectation.fulfill()
        }

        // THEN
        wait(for: [updateTokenExpiryExpectation], timeout: 10.0)
        XCTAssertNil(updateTokenExpiryError)
        XCTAssertNotNil(updateTokenExpiryResult)
        XCTAssertEqual(updateTokenExpiryResult, true)
    }

    func test_tokenize_payment_method() {
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

    func test_tokenize_payment_method_missing_card_number() {
        // GIVEN
        let tokenizeExpectation = expectation(description: "Tokenize Expectation")
        let cardData = CreditCardData()
        var tokenizeResult: String?
        var tokenizeError: GatewayException?

        // WHEN
        cardData.tokenize {
            tokenizeResult = $0
            if let error = $1 as? GatewayException {
                tokenizeError = error
            }
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNil(tokenizeResult)
        XCTAssertNotNil(tokenizeError)
        XCTAssertEqual(tokenizeError?.responseCode, "MANDATORY_DATA_MISSING")
        XCTAssertEqual(tokenizeError?.responseMessage, "40005")
    }
}
