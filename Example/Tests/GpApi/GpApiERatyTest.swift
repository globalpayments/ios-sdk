import XCTest
import GlobalPayments_iOS_SDK
import Foundation

/// Region:      Europe (Poland)
/// Gateway:     GP-API
/// Environment: Sandbox
/// Payment:     eRaty (provider = ERATY, category = BNPL)
final class GpApiERatyTest: XCTestCase {

    // MARK: - Constants

    private let AMOUNT: NSDecimalNumber = 400.00
    private let CURRENCY = "PLN"
    private let COUNTRY = "PL"

    private let returnUrl       = "https://webhook.site/1a9fd3b4-dc6b-4db6-b2a4-4b230f185cb5"
    private let statusUpdateUrl = "https://webhook.site/1a9fd3b4-dc6b-4db6-b2a4-4b230f185cb5"
    private let cancelUrl       = "https://webhook.site/1a9fd3b4-dc6b-4db6-b2a4-4b230f185cb5"

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        eRatySetup()
    }

    override func tearDown() {
        super.tearDown()
    }

    /// Configures the SDK for eRaty sandbox testing.
    private func eRatySetup() {
        ServicesContainer.shared.removeConfiguration(configName: "default")

        let appId = "hkjrcsGDhWiDt8GEhoDMKy3pzFz5R0Bo"
        let appKey = "cQOKHoAAvNIcEN8s"

        let config = GpApiConfig(
            appId: appId,
            appKey: appKey,
            channel: .cardNotPresent
        )
        config.country = COUNTRY
        config.serviceUrl = "https://apis.sandbox.globalpay.com/ucp"

        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "GPECOM_APM_Transaction_Processing"
        config.accessTokenInfo = accessTokenInfo

        do {
            try ServicesContainer.configureService(config: config)
        } catch {
            XCTFail("Failed to configure ServicesContainer for eRaty tests: \(error)")
        }
    }

    // MARK: - Helpers

    /// Builds a fully configured AlternatePaymentMethod for eRaty.
    private func makeERatyPaymentMethod() -> AlternatePaymentMethod {
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .ERATY
        paymentMethod.accountHolderName = "John Doe"
        paymentMethod.returnUrl = returnUrl
        paymentMethod.statusUpdateUrl = statusUpdateUrl
        paymentMethod.cancelUrl = cancelUrl
        paymentMethod.category = .BNPL

        let terms = Terms.make(timeUnit: "MONTH", count: 6, mode: TermsMode.BANK_INTEREST.rawValue)
        paymentMethod.terms = terms

        return paymentMethod
    }

    /// Builds payer details for eRaty.
    private func makePayerDetails() -> PayerDetails {
        let payer = PayerDetails()
        payer.email   = "abc@ccc.com"
        payer.country = COUNTRY
        return payer
    }

    // MARK: - Tests

    /// Given: A valid eRaty sale request with all required fields
    /// When:  The charge is submitted to GP-API
    /// Then:  The response status is INITIATED and a redirect URL is returned
    func test_eRaty_SaleRequest_WhenFieldsAreCorrect_ShouldReturnInitiatedWithRedirectUrl() {
        // GIVEN
        let paymentMethod = makeERatyPaymentMethod()
        let payerDetails  = makePayerDetails()

        let expectation = self.expectation(description: "eRaty Charge Expectation")
        var response: Transaction?
        var error: Error?

        // WHEN
        paymentMethod.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withPayerDetails(payerDetails: payerDetails)
            .withClientTransactionId("REF-\(UUID().uuidString)")
            .execute {
                response = $0
                error    = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error, "Expected no error, got: \(error?.localizedDescription ?? "")")
        XCTAssertNotNil(response)
        XCTAssertEqual("SUCCESS", response?.responseCode)
        XCTAssertEqual(TransactionStatus.initiated.mapped(for: .gpApi), response?.responseMessage)

        let apmResponse = response?.alternativePaymentResponse
        XCTAssertNotNil(apmResponse, "Expected alternativePaymentResponse to be populated")
        XCTAssertNotNil(
            apmResponse?.redirectUrl ?? apmResponse?.providerRedirectUrl,
            "Expected a redirect URL for the customer"
        )
        XCTAssertEqual("ERATY", apmResponse?.providerName?.uppercased())
        XCTAssertEqual("BNPL", apmResponse?.category?.uppercased())
    }

    /// Verifies that submitting an eRaty request WITHOUT a returnUrl throws a BuilderException.
    func test_eRaty_SaleRequest_WhenReturnUrlIsMissing_ShouldThrowBuilderException() {
        // GIVEN
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .ERATY
        paymentMethod.accountHolderName = "John Doe"
        paymentMethod.statusUpdateUrl = statusUpdateUrl
        paymentMethod.cancelUrl = cancelUrl
        paymentMethod.category = .BNPL

        let expectation = self.expectation(description: "eRaty Missing ReturnUrl Expectation")
        var response: Transaction?
        var builderError: BuilderException?

        // WHEN
        paymentMethod.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                response = $0
                if let err = $1 as? BuilderException {
                    builderError = err
                }
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(builderError)
        XCTAssertEqual(
            "paymentMethod.returnUrl cannot be nil for this rule",
            builderError?.message
        )
    }

    /// Verifies that the eRaty request serializes optional terms correctly when provided.
    func test_eRaty_SaleRequest_WithTerms_ShouldIncludeTermsInResponse() {
        // GIVEN
        let paymentMethod = makeERatyPaymentMethod()
        let payerDetails  = makePayerDetails()

        let expectation = self.expectation(description: "eRaty Terms Expectation")
        var response: Transaction?
        var error: Error?

        // WHEN
        paymentMethod.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withPayerDetails(payerDetails: payerDetails)
            .withClientTransactionId("REF-\(UUID().uuidString)")
            .execute {
                response = $0
                error    = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)

        let terms = response?.alternativePaymentResponse?.responseTerms
        XCTAssertNotNil(terms, "Expected terms to be returned in the APM response")
        XCTAssertEqual("MONTH", terms?.TimeUnit?.uppercased())
        XCTAssertEqual(Int64(6), terms?.count)
        XCTAssertEqual(TermsMode.BANK_INTEREST.rawValue, terms?.mode)
    }
    
    func test_eRatyCapture_WhenTransactionInitiated_ShouldSucceed() {
        let expectationInitiate = expectation(description: "eRaty Initiate for Capture")
        var responseInitiate: Transaction?
        var errorInitiate: Error?

        makeERatyPaymentMethod().charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withPayerDetails(payerDetails: makePayerDetails())
            .withClientTransactionId("REF-\(UUID().uuidString)")
            .execute {
                responseInitiate = $0
                errorInitiate    = $1
                expectationInitiate.fulfill()
            }

        wait(for: [expectationInitiate], timeout: 10.0)
        XCTAssertNil(errorInitiate)
        XCTAssertNotNil(responseInitiate)
        XCTAssertEqual("SUCCESS", responseInitiate?.responseCode)
        XCTAssertEqual(TransactionStatus.initiated.mapped(for: .gpApi), responseInitiate?.responseMessage)

        guard let transactionId = responseInitiate?.transactionId else {
            XCTFail("No transactionId returned from initiate step")
            return
        }

        let redirectUrl = responseInitiate?.alternativePaymentResponse?.redirectUrl
                       ?? responseInitiate?.alternativePaymentResponse?.providerRedirectUrl
        XCTAssertNotNil(redirectUrl)
        print("eRaty redirect URL — open in browser and click Pay: \(redirectUrl ?? "N/A")")

        let targetStatus = TransactionStatus.captured.mapped(for: .gpApi)
        var lastSummary: TransactionSummary?
        var lastError: Error?

        for attempt in 1...18 {
            let pollExpect = expectation(description: "Poll attempt \(attempt)")
            ReportingService
                .transactionDetail(transactionId: transactionId)
                .execute {
                    lastSummary = $0
                    lastError   = $1
                    pollExpect.fulfill()
                }
            wait(for: [pollExpect], timeout: 15.0)
            let currentStatus = lastSummary?.transactionStatus?.mapped(for: .gpApi) ?? "N/A"
            print("eRaty poll [\(attempt)/18] transactionId: \(transactionId) — status: \(currentStatus)")
            if currentStatus == targetStatus { break }
            if attempt < 18 { sleep(5) }
        }

        XCTAssertNil(lastError)
        XCTAssertNotNil(lastSummary)
        XCTAssertEqual(
            targetStatus,
            lastSummary?.transactionStatus?.mapped(for: .gpApi),
            "Expected CAPTURED — did you click Pay in the browser within 90 seconds?"
        )
        XCTAssertEqual(transactionId, lastSummary?.transactionId)
    }

    // MARK: - Additional Negative Tests (Builder Validation)

    /// Verifies that omitting statusUpdateUrl triggers a BuilderException before hitting the gateway.
    func test_eRaty_SaleRequest_WhenStatusUpdateUrlIsMissing_ShouldThrowBuilderException() {
        // GIVEN
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .ERATY
        paymentMethod.accountHolderName = "John Doe"
        paymentMethod.returnUrl = returnUrl
        paymentMethod.cancelUrl = cancelUrl
        paymentMethod.category = .BNPL

        let expectation = self.expectation(description: "eRaty Missing StatusUpdateUrl Expectation")
        var response: Transaction?
        var builderError: BuilderException?

        // WHEN
        paymentMethod.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                response = $0
                builderError = $1 as? BuilderException
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(builderError)
        XCTAssertEqual(
            "paymentMethod.statusUpdateUrl cannot be nil for this rule",
            builderError?.message
        )
    }

    /// Verifies that omitting accountHolderName triggers a BuilderException before hitting the gateway.
    func test_eRaty_SaleRequest_WhenAccountHolderNameIsMissing_ShouldThrowBuilderException() {
        // GIVEN
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .ERATY
        paymentMethod.returnUrl = returnUrl
        paymentMethod.statusUpdateUrl = statusUpdateUrl
        paymentMethod.cancelUrl = cancelUrl
        paymentMethod.category = .BNPL
        // accountHolderName intentionally not set

        let expectation = self.expectation(description: "eRaty Missing AccountHolderName Expectation")
        var response: Transaction?
        var builderError: BuilderException?

        // WHEN
        paymentMethod.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                response = $0
                builderError = $1 as? BuilderException
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(builderError)
        XCTAssertEqual(
            "paymentMethod.accountHolderName cannot be nil for this rule",
            builderError?.message
        )
    }

    // MARK: - Reporting Tests (known transaction IDs)

    /// Queries a known sandbox transaction that has already been CAPTURED and asserts its status.
    func test_eRaty_ReportTransactionDetail_Captured() {
        // GIVEN — a transaction that was previously initiated and paid in the sandbox
        let transactionId = "TRN_CK6ERuoZTHjYck9y2iCdmOfPcF0wSx_ddc4bb254221"

        let expectation = self.expectation(description: "eRaty Report Captured Expectation")
        var summary: TransactionSummary?
        var error: Error?

        // WHEN
        ReportingService
            .transactionDetail(transactionId: transactionId)
            .execute {
                summary = $0
                error   = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(summary)
        XCTAssertEqual(transactionId, summary?.transactionId)
        XCTAssertEqual(
            TransactionStatus.captured.mapped(for: .gpApi),
            summary?.transactionStatus?.mapped(for: .gpApi)
        )
    }

    /// Queries a known sandbox transaction that was DECLINED and asserts its status.
    func test_eRaty_ReportTransactionDetail_Declined() {
        // GIVEN — a transaction that was previously declined in the sandbox
        let transactionId = "TRN_Y74JLuGbMnoZbTRHcDETtbHUi5RdUA_2eefca13b34b"

        let expectation = self.expectation(description: "eRaty Report Declined Expectation")
        var summary: TransactionSummary?
        var error: Error?

        // WHEN
        ReportingService
            .transactionDetail(transactionId: transactionId)
            .execute {
                summary = $0
                error   = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(summary)
        XCTAssertEqual(transactionId, summary?.transactionId)
        XCTAssertEqual(
            TransactionStatus.declined.mapped(for: .gpApi),
            summary?.transactionStatus?.mapped(for: .gpApi)
        )
    }
}
