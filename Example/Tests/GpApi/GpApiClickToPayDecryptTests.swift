import XCTest
import GlobalPayments_iOS_SDK

class GpApiClickToPayDecryptTests: XCTestCase {

    var card: CreditCardData!

    override func setUp() {
        super.setUp()

        let config = GpApiConfig(
            appId: "Q3GX8Q0eY70hoRedigufpFadVgC4vZ5irPzxdifAAI26VxT2",
            appKey: "EGTR7u6uqVuiQqHYDBDjqGJRu1TW7ZVMRYczYZhtx5xAzOxkGLODFRzOGBbbjVza",
            channel: .cardNotPresent,
            country: "US",
            accessTokenInfo: AccessTokenInfo(
                tokenizationAccountName: "Ecom_Tokenization_Account",
                transactionProcessingAccountName: "GPECOM_Transaction_Processing_CNP"
            )
        )
        config.dataResidency = .eu
        try? ServicesContainer.configureService(config: config)

        card = CreditCardData()
        card.cardHolderName = "James Mason"
        card.mobileType = EncryptedMobileType.CLICK_PAY.rawValue
        card.cardType = "VISA"
        card.token = GpApiClickToPayTestData.encryptedPayload
        card.dpaReference = GpApiClickToPayTestData.dpaReference
        card.dataTypeIndicator = GpApiClickToPayTestData.dataTypeIndicator
    }

    override func tearDown() {
        super.tearDown()

        card = nil
    }

    // MARK: - Test: Decrypt Click to Pay encrypted token

    func test_decrypt_click_to_pay_token() throws {
        // GIVEN
        try XCTSkipUnless(
            card.token?.isEmpty == false && card.dpaReference?.isEmpty == false,
            "Paste a fresh Visa SRC JWT into GpApiClickToPayTestData.encryptedPayload to run this test. Tokens expire ~60 seconds after generation — run immediately after pasting. Test skipped."
        )
        // GIVEN
        let decryptExpectation = expectation(description: "Decrypt CTP Token Expectation")
        var decryptResult: Transaction?
        var decryptError: Error?

        // WHEN
        card.decrypt()
            .withCurrency("USD")
            .execute {
                decryptResult = $0
                decryptError = $1
                decryptExpectation.fulfill()
            }

        // THEN
        wait(for: [decryptExpectation], timeout: 10)
        XCTAssertNil(decryptError)
        XCTAssertNotNil(decryptResult)
        XCTAssertEqual(decryptResult?.responseCode, "SUCCESS")
        XCTAssertEqual(decryptResult?.responseMessage, "DECRYPTED")
        XCTAssertNotNil(decryptResult?.transactionId)
        XCTAssertNotNil(decryptResult?.decryptId)
        XCTAssertTrue(decryptResult?.decryptId?.starts(with: "DEC_") ?? false)
        XCTAssertNotNil(decryptResult?.token)
        XCTAssertTrue(decryptResult?.token?.starts(with: "PMT_") ?? false)
    }

    // MARK: - Test: Authorize using PMT_ID + DEC_ID (sequential decrypt → charge)

    func test_charge_click_to_pay_with_dec_id() throws {
        // STEP 1: Decrypt the CTP token to get PMT_ID + DEC_ID
        try XCTSkipUnless(
            card.token?.isEmpty == false && card.dpaReference?.isEmpty == false,
            "Paste a fresh Visa SRC JWT into GpApiClickToPayTestData.encryptedPayload to run this test. Tokens expire ~60 seconds after generation — run immediately after pasting. Test skipped."
        )
        let decryptExpectation = expectation(description: "Decrypt Step")
        var decryptResult: Transaction?
        var decryptError: Error?

        card.decrypt()
            .withCurrency("USD")
            .execute {
                decryptResult = $0
                decryptError = $1
                decryptExpectation.fulfill()
            }

        wait(for: [decryptExpectation], timeout: 10)
        XCTAssertNil(decryptError)
        XCTAssertNotNil(decryptResult?.token)
        XCTAssertNotNil(decryptResult?.decryptId)

        guard let pmtId = decryptResult?.token,
              let decId = decryptResult?.decryptId else {
            XCTFail("Decrypt step did not return PMT_ID and DEC_ID")
            return
        }

        // STEP 2: Charge using PMT_ID + DEC_ID
        let chargeExpectation = expectation(description: "CTP Charge With DEC_ID Expectation")
        var chargeResult: Transaction?
        var chargeError: Error?

        let tokenizedCard = CreditCardData()
        tokenizedCard.token = pmtId
        tokenizedCard.mobileType = EncryptedMobileType.CLICK_PAY.rawValue
        tokenizedCard.cardHolderName = "James Mason"
        tokenizedCard.dpaReference = card.dpaReference
        tokenizedCard.dataTypeIndicator = card.dataTypeIndicator

        tokenizedCard.charge(amount: 10)
            .withCurrency("EUR")
            .withModifier(.decryptedMobile)
            .withDecryptionId(decId)
            .execute {
                chargeResult = $0
                chargeError = $1
                chargeExpectation.fulfill()
            }

        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(chargeError)
        XCTAssertNotNil(chargeResult)
        XCTAssertEqual(chargeResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeResult?.responseMessage, TransactionStatus.captured.rawValue)
    }

    // MARK: - Test: Create single-use payment method with CVV

    func test_create_payment_method_with_cvv() throws {
        // GIVEN
        let tokenizeExpectation = expectation(description: "Tokenize With CVV Expectation")
        var tokenizeResult: Transaction?
        var tokenizeError: Error?

        let plainCard = CreditCardData()
        plainCard.number = "4263970000005262"
        plainCard.expMonth = 05
        plainCard.expYear = 2030
        plainCard.cvn = "123"
        plainCard.cardHolderName = "James Mason"

        // WHEN
        plainCard.verify()
            .withRequestMultiUseToken(true)
            .withPaymentMethodUsageMode(.single)
            .execute {
                tokenizeResult = $0
                tokenizeError = $1
                tokenizeExpectation.fulfill()
            }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10)

        if let gatewayError = tokenizeError as? GatewayException,
           gatewayError.responseCode == "ACTION_NOT_AUTHORIZED" || gatewayError.responseMessage == "40022" {
            throw XCTSkip("Missing PMT_POST_Create_Single permission for /payment-methods on current access token/account. Update EU CTP app credentials or account permissions and retry.")
        }

        XCTAssertNil(tokenizeError)
        XCTAssertNotNil(tokenizeResult)
        XCTAssertNotNil(tokenizeResult?.token)
        XCTAssertTrue(tokenizeResult?.token?.starts(with: "PMT_") ?? false)
    }

    // MARK: - Test: Create single-use payment method without CVV

    func test_create_payment_method_without_cvv() {
        // GIVEN
        let tokenizeExpectation = expectation(description: "Tokenize Without CVV Expectation")
        var tokenizeResult: Transaction?
        var tokenizeError: Error?

        let plainCard = CreditCardData()
        plainCard.number = "4263970000005262"
        plainCard.expMonth = 05
        plainCard.expYear = 2030
        // No cvn set — single-use token without CVV

        // WHEN
        plainCard.verify()
            .withRequestMultiUseToken(true)
            .execute {
                tokenizeResult = $0
                tokenizeError = $1
                tokenizeExpectation.fulfill()
            }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10)
        XCTAssertNil(tokenizeError)
        XCTAssertNotNil(tokenizeResult)
        XCTAssertNotNil(tokenizeResult?.token)
        XCTAssertTrue(tokenizeResult?.token?.starts(with: "PMT_") ?? false)
    }

    // MARK: - Helpers

    private func assertClickToPayPayerDetails(_ response: Transaction?) {
        XCTAssertNotNil(response?.payerDetails)
        XCTAssertNotNil(response?.payerDetails?.firstName)
        XCTAssertNotNil(response?.payerDetails?.lastName)
        XCTAssertNotNil(response?.payerDetails?.billingAddress)
    }
}
