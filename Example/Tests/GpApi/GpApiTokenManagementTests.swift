import XCTest
import GlobalPayments_iOS_SDK

class GpApiTokenManagementTests: XCTestCase {

    private var card: CreditCardData?
    private var token: String?

    override func setUpWithError() throws {
        try super.setUpWithError()

        try ServicesContainer.configureService(config:
            GpApiConfig(
                appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
                appKey: "QDsW1ETQKHX6Y4TA"
            )
        )

        card = CreditCardData()
        card?.number = "4111111111111111"
        card?.expMonth = 12
        card?.expYear = 2025
        card?.cvn = "123"

        let tokenizeExpectation = expectation(description: "Tokenize exception")

        card?.tokenize(completion: { [weak self] token, error in
            self?.token = token
            tokenizeExpectation.fulfill()
        })

        wait(for: [tokenizeExpectation], timeout: 10.0)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token

        let tokenizeExpectation = expectation(description: "Tokenize exception")
        let verifyExpectation = expectation(description: "Verify exception")

        tokenizedCard.deleteToken { completed, error in
            tokenizeExpectation.fulfill()
        }

        wait(for: [tokenizeExpectation], timeout: 10.0)

        tokenizedCard.verify()
            .execute { transaction, error in
                verifyExpectation.fulfill()
        }

        wait(for: [verifyExpectation], timeout: 10.0)
    }

    func test_verify_tokenized_payment_method() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        let verifyExpectation = expectation(description: "Verify Expectation")
        var transactionResult: Transaction?
        var errorResult: Error?

        // WHEN
        tokenizedCard.verify().execute { transaction, error in
            transactionResult = transaction
            errorResult = error
            verifyExpectation.fulfill()
        }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(errorResult)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "00")
        XCTAssertEqual(transactionResult?.responseMessage, "ACTIVE")
    }

    func test_detokenize_payment_method() {
        // GIVEN
        let detokenizeExpectation = expectation(description: "Detokenize Expectation")
        var responseResult: String?
        var responseError: Error?
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token

        // WHEN
        tokenizedCard.detokenize { response, error in
            responseResult = response
            responseError = error
            detokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [detokenizeExpectation], timeout: 10.0)
        XCTAssertNotNil(responseResult)
        XCTAssertNil(responseError)
        XCTAssertEqual(card?.number, responseResult)
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
        tokenizedCard.updateTokenExpiry { updated, error in
            updatedResult = updated
            errorResult = error
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
        tokenizedCard.verify().execute { transaction, error in
            transactionResult = transaction
            transactionErrorResult = error
            executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResult)
        XCTAssertNil(transactionErrorResult)
        XCTAssertEqual(transactionResult?.responseCode, "00")
        XCTAssertEqual(transactionResult?.responseMessage, "ACTIVE")
    }

    func test_credit_sale_with_tokenized_payment_method() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        var transactionResult: Transaction?
        var errorResult: Error?
        var statusResult: TransactionStatus?
        let executeExpectation = expectation(description: "Execute Expectation")

        // WHEN
        tokenizedCard.charge(amount: 19.99)
            .withCurrency("USD")
            .execute { transaction, error in
                transactionResult = transaction
                errorResult = error
                if let responseMessage = transaction?.responseMessage,
                    let status = TransactionStatus(rawValue: responseMessage) {
                    statusResult = status
                }
                executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResult)
        XCTAssertNil(errorResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(statusResult, TransactionStatus.captured)
    }
}
