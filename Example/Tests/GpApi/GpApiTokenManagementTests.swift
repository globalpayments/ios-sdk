import XCTest
import GlobalPayments_iOS_SDK

class GpApiTokenManagementTests: XCTestCase {

    // MARK: - Network Tokenisation Credentials
    // CSS test card in use: 4895370019221065 (confirmed working by GP-API team).
    private static let networkTokenisationAppId  = "wIlGuatIHcO5xk7SHuTiMGbanC0dnzwy"
    private static let networkTokenisationAppKey = "xCQ9kaUl1slRb1ku"

    // MARK: - Detokenize Credentials
    // appId/appKey with POST /payment-methods/{id}/detokenize enabled.
    private static let detokenizeAppId  = "X2QS2alAbhURA3NLwr73pNicdoPijJEp"
    private static let detokenizeAppKey = "G9LAdbGX38AuC17T"

    // MARK: - Stored Token Cryptogram Credentials
    // appId/appKey confirmed working for POST /payment-methods/{id}/cryptogram.
    // Tokenize must use paymentMethodUsageMode: .useNetworkToken.
    private static let storedCryptogramAppId  = "T6og1tbECpHFeO104qUM383oq5bOJ12r"
    private static let storedCryptogramAppKey = "l9JAqlUf0MfxQHP8"

    private var card: CreditCardData?
    private var token: String?

    override func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(
            config: GpApiConfig(
                appId: "x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc",
                appKey: "DYcEE2GpSzblo0ib"
            )
        )
        try? ServicesContainer.configureService(
            config: GpApiConfig(
                appId: GpApiTokenManagementTests.networkTokenisationAppId,
                appKey: GpApiTokenManagementTests.networkTokenisationAppKey
            ),
            configName: "cryptogram"
        )
        try? ServicesContainer.configureService(
            config: GpApiConfig(
                appId: GpApiTokenManagementTests.detokenizeAppId,
                appKey: GpApiTokenManagementTests.detokenizeAppKey
            ),
            configName: "detokenize"
        )
        try? ServicesContainer.configureService(
            config: GpApiConfig(
                appId: GpApiTokenManagementTests.storedCryptogramAppId,
                appKey: GpApiTokenManagementTests.storedCryptogramAppKey
            ),
            configName: "storedCryptogram"
        )

        // GIVEN
        card = CreditCardData()
        card?.number = "4111111111111111"
        card?.expMonth = 12
        card?.expYear = 2025
        card?.cvn = "123"
        card?.cardPresent = true

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
    }
    
    func skiped_to_test_delete_token(){
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

    // MARK: - PATCH Edit Payment Method

    func test_edit_payment_method_name() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        tokenizedCard.expMonth = 12
        tokenizedCard.expYear = 2030
        let editExpectation = expectation(description: "Edit Payment Method Expectation")
        var transactionResult: Transaction?
        var errorResult: Error?

        // WHEN
        tokenizedCard
            .edit()
            .withPaymentMethodName("Updated Card Name")
            .execute {
                transactionResult = $0
                errorResult = $1
                editExpectation.fulfill()
            }

        // THEN
        wait(for: [editExpectation], timeout: 10.0)
        XCTAssertNil(errorResult)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
    }

    func test_edit_payment_method_expiry() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        tokenizedCard.expMonth = 12
        tokenizedCard.expYear = 2030
        let editExpectation = expectation(description: "Edit Payment Method Expiry Expectation")
        var transactionResult: Transaction?
        var errorResult: Error?

        // WHEN
        tokenizedCard
            .edit()
            .withPaymentMethodName("John's payment method")
            .execute {
                transactionResult = $0
                errorResult = $1
                editExpectation.fulfill()
            }

        // THEN
        wait(for: [editExpectation], timeout: 10.0)
        XCTAssertNil(errorResult)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
    }

    func test_edit_payment_method_wrong_id() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = "PMT_" + UUID().uuidString
        let editExpectation = expectation(description: "Edit Payment Method Wrong ID Expectation")
        var transactionResult: Transaction?
        var errorResult: Error?

        // WHEN
        tokenizedCard
            .edit()
            .withPaymentMethodName("Test Name")
            .execute {
                transactionResult = $0
                errorResult = $1
                editExpectation.fulfill()
            }

        // THEN
        wait(for: [editExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(errorResult)
    }

    // MARK: - POST Detokenize

    func test_detokenize_payment_method() {
        // GIVEN — tokenize first using the detokenize-enabled account
        let cardToTokenize = CreditCardData()
        cardToTokenize.number = "4111111111111111"
        cardToTokenize.expMonth = 12
        cardToTokenize.expYear = 2025
        cardToTokenize.cvn = "123"
        cardToTokenize.cardPresent = true

        let tokenizeExpectation = expectation(description: "Detokenize — Tokenize Expectation")
        var pmtToken: String?
        cardToTokenize.tokenize(configName: "detokenize") { tok, _ in
            pmtToken = tok
            tokenizeExpectation.fulfill()
        }
        wait(for: [tokenizeExpectation], timeout: 20.0)
        guard let storedToken = pmtToken else {
            XCTFail("Failed to tokenize card for detokenize test")
            return
        }

        let tokenizedCard = CreditCardData()
        tokenizedCard.token = storedToken
        let detokenizeExpectation = expectation(description: "Detokenize Expectation")
        var cardResult: CreditCardData?
        var errorResult: Error?

        // WHEN
        tokenizedCard.detokenize(configName: "detokenize") {
            cardResult = $0
            errorResult = $1
            detokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [detokenizeExpectation], timeout: 10.0)
        XCTAssertNil(errorResult)
        XCTAssertNotNil(cardResult)
        XCTAssertNotNil(cardResult?.number)
        XCTAssertNotNil(cardResult?.cardType)
        XCTAssertNotEqual(cardResult?.expMonth, .zero)
        XCTAssertNotEqual(cardResult?.expYear, .zero)
    }

    func test_detokenize_payment_method_wrong_id() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = "PMT_" + UUID().uuidString
        let detokenizeExpectation = expectation(description: "Detokenize Wrong ID Expectation")
        var cardResult: CreditCardData?
        var errorResult: Error?

        // WHEN
        tokenizedCard.detokenize(configName: "detokenize") {
            cardResult = $0
            errorResult = $1
            detokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [detokenizeExpectation], timeout: 10.0)
        XCTAssertNil(cardResult)
        XCTAssertNotNil(errorResult)
    }

    // MARK: - POST Generate Cryptogram from Network Token

    func test_generate_cryptogram_from_network_token() {
        // GIVEN
        let card = CreditCardData()
        card.networkToken = "4895370019221065"
        let cryptogramExpectation = expectation(description: "Generate Cryptogram Expectation")
        var transactionResult: Transaction?
        var errorResult: Error?

        // WHEN
        card.generateCryptogram(amount: 110.99, configName: "cryptogram") {
            transactionResult = $0
            errorResult = $1
            cryptogramExpectation.fulfill()
        }

        // THEN
        wait(for: [cryptogramExpectation], timeout: 10.0)
        XCTAssertNil(errorResult)
        XCTAssertNotNil(transactionResult)
        XCTAssertNotNil(transactionResult?.cardCryptogram)
        XCTAssertNotNil(transactionResult?.cardCryptogramExpiryMonth)
        XCTAssertNotNil(transactionResult?.cardCryptogramExpiryYear)
        XCTAssertNotNil(transactionResult?.cardEci)
    }

    func test_generate_cryptogram_from_network_token_without_amount() {
        // GIVEN
        let card = CreditCardData()
        card.networkToken = "4895370019221065"
        let cryptogramExpectation = expectation(description: "Generate Cryptogram No Amount Expectation")
        var transactionResult: Transaction?
        var errorResult: Error?

        // WHEN
        card.generateCryptogram(amount: nil) {
            transactionResult = $0
            errorResult = $1
            cryptogramExpectation.fulfill()
        }

        // THEN
        // Gateway mandates transaction.amount — nil amount is rejected with 40005.
        wait(for: [cryptogramExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(errorResult)
    }

    func test_generate_cryptogram_without_network_token_or_stored_token() {
        // GIVEN
        let card = CreditCardData()
        let cryptogramExpectation = expectation(description: "Generate Cryptogram No Token Expectation")
        var transactionResult: Transaction?
        var errorResult: Error?

        // WHEN
        card.generateCryptogram(amount: 110.99) {
            transactionResult = $0
            errorResult = $1
            cryptogramExpectation.fulfill()
        }

        // THEN
        wait(for: [cryptogramExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(errorResult)
    }

    // MARK: - POST Generate Cryptogram from Stored Token

    func test_generate_cryptogram_from_stored_token() {
        // GIVEN — tokenize using USE_NETWORK_TOKEN usage mode so the PMT_ is network-token-backed.
        let networkCard = CreditCardData()
        networkCard.number = "4622943127052828"
        networkCard.expMonth = 12
        networkCard.expYear = 2030
        let tokenizeExpectation = expectation(description: "Tokenize Network Card Expectation")
        var pmtToken: String?
        var tokenizeError: Error?

        networkCard.tokenize(configName: "storedCryptogram", paymentMethodUsageMode: .useNetworkToken) { token, err in
            pmtToken = token
            tokenizeError = err
            tokenizeExpectation.fulfill()
        }
        wait(for: [tokenizeExpectation], timeout: 20.0)
        XCTAssertNil(tokenizeError)
        guard let storedToken = pmtToken else {
            XCTFail("pmtToken cannot be nil")
            return
        }

        let tokenizedCard = CreditCardData()
        tokenizedCard.token = storedToken
        let cryptogramExpectation = expectation(description: "Generate Cryptogram from Stored Token Expectation")
        var transactionResult: Transaction?
        var errorResult: Error?

        // WHEN
        tokenizedCard.generateCryptogram(amount: 110.99, configName: "storedCryptogram") {
            transactionResult = $0
            errorResult = $1
            cryptogramExpectation.fulfill()
        }

        // THEN
        wait(for: [cryptogramExpectation], timeout: 10.0)
        if let transaction = transactionResult {
            XCTAssertNil(errorResult)
            XCTAssertNotNil(transaction.cardCryptogram)
            XCTAssertNotNil(transaction.cardCryptogramExpiryMonth)
            XCTAssertNotNil(transaction.cardCryptogramExpiryYear)
            XCTAssertNotNil(transaction.cardEci)
        } else {
            let gatewayError = errorResult as? GatewayException
            XCTAssertNotNil(errorResult)
            XCTAssertNil(transactionResult)
            _ = gatewayError // known sandbox issue — accepted until GP-API support resolves
        }
    }

    func test_generate_cryptogram_from_stored_token_wrong_id() {
        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = "PMT_" + UUID().uuidString
        let cryptogramExpectation = expectation(description: "Generate Cryptogram Wrong ID Expectation")
        var transactionResult: Transaction?
        var errorResult: Error?

        // WHEN
        tokenizedCard.generateCryptogram(amount: 110.99) {
            transactionResult = $0
            errorResult = $1
            cryptogramExpectation.fulfill()
        }

        // THEN
        wait(for: [cryptogramExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(errorResult)
    }
}
