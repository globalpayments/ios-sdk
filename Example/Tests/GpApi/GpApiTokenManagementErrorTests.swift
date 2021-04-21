import XCTest
import GlobalPayments_iOS_SDK

class GpApiTokenManagementErrorTests: XCTestCase {

    override class func setUp() {
        super.setUp()

        let config = GpApiConfig(
            appId: "P3LRVjtGRGxWQQJDE345mSkEh2KfdAyg",
            appKey: "ockJr6pv6KFoGiZA"
        )
        try? ServicesContainer.configureService(config: config)
    }

    func test_verify_tokenized_payment_method_with_malformed_id() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = "THIS_IS_NOT_A_PAYMENT_ID"
        var transactionResult: Transaction?
        var transactionError: GatewayException?
        let verifyExpectation = expectation(description: "Verify Expectation")

        // WHEN
        tokenizedCard
            .verify()
            .withCurrency("USD")
            .execute {
                transactionResult = $0
                if let error = $1 as? GatewayException {
                    transactionError = error
                }
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
        XCTAssertEqual(transactionError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(transactionError?.responseMessage, "40213")
        XCTAssertEqual(transactionError?.message, "Status Code: 400 - payment_method.id: THIS_IS_NOT_A_PAYMENT_ID contains unexpected data")
    }

    func test_verify_tokenizedPaymentMethod_WithMissingCardNumber() {
        // GIVEN
        let card = CreditCardData()
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 5
        card.cvn = "123"
        var tokenResult: String?
        var tokenizeError: GatewayException?
        let tokenizeExpectation = expectation(description: "Tokenize Expectation")

        // WHEN
        card.tokenize {
            tokenResult = $0
            if let error = $1 as? GatewayException {
                tokenizeError = error
            }
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNil(tokenResult)
        XCTAssertNotNil(tokenizeError)
        XCTAssertEqual(tokenizeError?.responseCode, "MANDATORY_DATA_MISSING")
        XCTAssertEqual(tokenizeError?.responseMessage, "40005")
        XCTAssertEqual(tokenizeError?.message, "Status Code: 400 - Request expects the following fields : number")
    }

    func test_verify_tokenized_payment_method_with_random_id() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = "PMT_" + UUID().uuidString
        var transactionResult: Transaction?
        var transactionError: GatewayException?
        let verifyExpectation = expectation(description: "Verify Expectation")

        // WHEN
        tokenizedCard
            .verify()
            .withCurrency("USD")
            .execute {
                transactionResult = $0
                if let error = $1 as? GatewayException {
                    transactionError = error
                }
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
        XCTAssertEqual(transactionError?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(transactionError?.responseMessage, "40116")
        if let message = transactionError?.message {
            XCTAssertTrue(message.contains("Status Code: 404 - payment_method"))
        } else {
            XCTFail("message cannot be nil!")
        }
    }

    func test_update_tokenized_payment_method_with_malformed_id() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = "THIS_IS_NOT_A_PAYMENT_ID"
        tokenizedCard.expMonth = Date().currentMonth
        tokenizedCard.expYear = Date().currentYear + 5

        var updateTokenExpiryResult: Bool?
        var updateTokenExpiryError: GatewayException?
        let updateTokenExpiryExpectation = expectation(description: "Update Token Expiry Expectation")

        // WHEN
        tokenizedCard.updateTokenExpiry {
            updateTokenExpiryResult = $0
            if let error = $1 as? GatewayException {
                updateTokenExpiryError = error
            }
            updateTokenExpiryExpectation.fulfill()
        }

        // THEN
        wait(for: [updateTokenExpiryExpectation], timeout: 10.0)
        if let updateTokenExpiryResult = updateTokenExpiryResult {
            XCTAssertFalse(updateTokenExpiryResult)
        } else {
            XCTFail("updateTokenExpiryResult cannot be nil")
        }
        XCTAssertNotNil(updateTokenExpiryError)
        XCTAssertEqual(updateTokenExpiryError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(updateTokenExpiryError?.responseMessage, "40213")
        XCTAssertEqual(updateTokenExpiryError?.message, "Status Code: 400 - payment_method.id: THIS_IS_NOT_A_PAYMENT_ID contains unexpected data")
    }

    func test_update_tokenized_payment_method_with_random_id() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = "PMT_" + UUID().uuidString
        tokenizedCard.expMonth = Date().currentMonth
        tokenizedCard.expYear = Date().currentYear + 5

        var updateTokenExpiryResult: Bool?
        var updateTokenExpiryError: GatewayException?
        let updateTokenExpiryExpectation = expectation(description: "Update Token Expiry Expectation")

        // WHEN
        tokenizedCard.updateTokenExpiry {
            updateTokenExpiryResult = $0
            if let error = $1 as? GatewayException {
                updateTokenExpiryError = error
            }
            updateTokenExpiryExpectation.fulfill()
        }

        // THEN
        wait(for: [updateTokenExpiryExpectation], timeout: 10.0)
        if let updateTokenExpiryResult = updateTokenExpiryResult {
            XCTAssertFalse(updateTokenExpiryResult)
        } else {
            XCTFail("updateTokenExpiryResult cannot be nil")
        }
        XCTAssertNotNil(updateTokenExpiryError)
        XCTAssertEqual(updateTokenExpiryError?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(updateTokenExpiryError?.responseMessage, "40116")
        if let message = updateTokenExpiryError?.message {
            XCTAssertTrue(message.contains("Status Code: 404 - payment_method"))
        } else {
            XCTFail("message cannot be nil!")
        }
    }

    func test_delete_tokenized_payment_method_with_non_existing_id() {
        // Tokenize

        // GIVEN
        let card = CreditCardData()
        card.number = "4111111111111111"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 5
        card.cvn = "123"
        let tokenizeExpectation = expectation(description: "Tokenize Expectation")
        var token: String?
        var tokenizeError: Error?

        // WHEN
        card.tokenize {
            token = $0
            tokenizeError = $1
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNil(tokenizeError)
        XCTAssertNotNil(token)

        // Delete Token

        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        let deleteTokenExpectation = expectation(description: "Delete Token Expectation")
        var deleteTokenResult: Bool?
        var deleteTokenError: Error?

        // WHEN
        tokenizedCard.deleteToken {
            deleteTokenResult = $0
            deleteTokenError = $1
            deleteTokenExpectation.fulfill()
        }

        // THEN
        wait(for: [deleteTokenExpectation], timeout: 10.0)
        XCTAssertNil(deleteTokenError)
        XCTAssertNotNil(deleteTokenResult)
        XCTAssertEqual(deleteTokenResult, true)

        // Second Token Delete

        // GIVEN
        let secondDeleteTokenExpectation = expectation(description: "Second Delete Token Expectation")
        var secondDeleteTokenResult: Bool?
        var secondDeleteTokenError: Error?

        // WHEN
        tokenizedCard.deleteToken {
            secondDeleteTokenResult = $0
            secondDeleteTokenError = $1
            secondDeleteTokenExpectation.fulfill()
        }

        // THEN
        wait(for: [secondDeleteTokenExpectation], timeout: 10.0)
        XCTAssertNotNil(secondDeleteTokenError)
        XCTAssertNotNil(secondDeleteTokenResult)
        XCTAssertEqual(secondDeleteTokenResult, false)

        // Verify

        // GIVEN
        var verifyTransactionResult: Transaction?
        var verifyTransactionError: GatewayException?
        let verifyExpectation = expectation(description: "Verify Expectation")

        // WHEN
        tokenizedCard
            .verify()
            .withCurrency("USD")
            .execute {
                verifyTransactionResult = $0
                if let error = $1 as? GatewayException {
                    verifyTransactionError = error
                }
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(verifyTransactionResult)
        XCTAssertNotNil(verifyTransactionError)
        XCTAssertEqual(verifyTransactionError?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(verifyTransactionError?.responseMessage, "40116")
        if let message = verifyTransactionError?.message {
            XCTAssertTrue(message.contains("Status Code: 404 - payment_method"))
        } else {
            XCTFail("message cannot be nil!")
        }
    }

    func test_delete_tokenized_payment_method_with_random_id() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = "PMT_" + UUID().uuidString
        let verifyExpectation = expectation(description: "Verify Expectation")
        var transactionResult: Transaction?
        var transactionError: GatewayException?

        // WHEN
        tokenizedCard
            .verify()
            .withCurrency("USD")
            .execute {
                transactionResult = $0
                if let error = $1 as? GatewayException {
                    transactionError = error
                }
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
        XCTAssertEqual(transactionError?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(transactionError?.responseMessage, "40116")
        if let message = transactionError?.message {
            XCTAssertTrue(message.contains("Status Code: 404 - payment_method"))
        } else {
            XCTFail("message cannot be nil!")
        }
    }

    func test_delete_tokenized_payment_method_with_malformed_id() {

        // Delete Token

        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = "THIS_IS_NOT_A_PAYMENT_ID"

        var deleteTokenResult: Bool?
        var deleteTokenError: GatewayException?
        let deleteTokenExpectation = expectation(description: "Delete Token Expectation")

        // WHEN
        tokenizedCard.deleteToken {
            deleteTokenResult = $0
            if let error = $1 as? GatewayException {
                deleteTokenError = error
            }
            deleteTokenExpectation.fulfill()
        }

        // THEN
        wait(for: [deleteTokenExpectation], timeout: 10.0)
        if let deleteTokenResult = deleteTokenResult {
            XCTAssertFalse(deleteTokenResult)
        } else {
            XCTFail("updateTokenExpiryResult cannot be nil")
        }
        XCTAssertNotNil(deleteTokenError)
        XCTAssertEqual(deleteTokenError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(deleteTokenError?.responseMessage, "40213")
        XCTAssertEqual(deleteTokenError?.message, "Status Code: 400 - payment_method.id: THIS_IS_NOT_A_PAYMENT_ID contains unexpected data")

        // Verify Token

        // GIVEN
        let verifyExpectation = expectation(description: "Verify Expectation")
        var transactionResult: Transaction?
        var transactionError: GatewayException?

        // WHEN
        tokenizedCard
            .verify()
            .withCurrency("USD")
            .execute {
                transactionResult = $0
                if let error = $1 as? GatewayException {
                    transactionError = error
                }
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
        XCTAssertEqual(transactionError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(transactionError?.responseMessage, "40213")
        XCTAssertEqual(transactionError?.message, "Status Code: 400 - payment_method.id: THIS_IS_NOT_A_PAYMENT_ID contains unexpected data")
    }
}
