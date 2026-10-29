import XCTest
import GlobalPayments_iOS_SDK

// AH-3065: Partner account with multiple MMAs - verifies `GpApiConfig.mmaId` routes
// requests to POST /accounts/{MMA_ID}/merchants/{MER_ID}/transactions.
class GpApiCreditWithMMATests: XCTestCase {

    private var card: CreditCardData!
    private let AMOUNT: NSDecimalNumber = 7.8
    private let CURRENCY: String = "USD"
    private let EXPECTED_CODE: String = "SUCCESS"

    private let APP_ID: String = "ju9LDqNIxUgY2NeQPgwqc0fLbq3AcJCL"
    private let APP_KEY: String = ""
    private let MMA_1: String = "MMA_003720f36d9d4f7f9348b5a4981071ce"
    private let MMA_2: String = "MMA_344aebc638864d7381909dcf78d4c760"

    // TODO: MMA_1 has no merchant onboarded yet in sandbox (GP-API returned
    // "Merchant Configuration does not exist" on creation attempt) - replace once available.
    private let PLACEHOLDER_MER_ID: String = "MER_REPLACE_ME_MMA_1"
    private let MER_ID_UNDER_MMA_1: String = "MER_REPLACE_ME_MMA_1"
    // Confirmed via GET /accounts/{MMA_2}/merchants on 2026-10-13 ("SDKTest", ACTIVE).
    private let MER_ID_UNDER_MMA_2: String = "MER_6517954c0c8544feb3f74c825e2b032c"

    override func setUp() {
        super.setUp()

        card = CreditCardData()
        card.number = "4263970000005262"
        card.expMonth = 12
        card.expYear = 2025
        card.cvn = "852"
    }

    override func tearDown() {
        super.tearDown()
        card = nil
    }

    private func configureService(mmaId: String?, merchantId: String?) {
        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "transaction_processing"

        let config = GpApiConfig(
            appId: APP_ID,
            appKey: APP_KEY,
            accessTokenInfo: accessTokenInfo,
            merchantId: merchantId,
            mmaId: mmaId
        )

        try? ServicesContainer.configureService(config: config)
    }

    func test_sale_with_mma1() throws {
        try XCTSkipIf(MER_ID_UNDER_MMA_1 == PLACEHOLDER_MER_ID, "No merchant onboarded under MMA_1 yet - see AH-3065; replace MER_ID_UNDER_MMA_1 once available.")

        configureService(mmaId: MMA_1, merchantId: MER_ID_UNDER_MMA_1)

        let saleExpectation = expectation(description: "Sale under MMA 1 Expectation")
        var saleResult: Transaction?
        var saleError: Error?

        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                saleResult = $0
                saleError = $1
                saleExpectation.fulfill()
            }

        wait(for: [saleExpectation], timeout: 10.0)
        XCTAssertNil(saleError)
        XCTAssertNotNil(saleResult)
        XCTAssertEqual(EXPECTED_CODE, saleResult?.responseCode)
    }

    func test_sale_with_mma2() {
        configureService(mmaId: MMA_2, merchantId: MER_ID_UNDER_MMA_2)

        let saleExpectation = expectation(description: "Sale under MMA 2 Expectation")
        var saleResult: Transaction?
        var saleError: Error?

        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                saleResult = $0
                saleError = $1
                saleExpectation.fulfill()
            }

        wait(for: [saleExpectation], timeout: 10.0)
        XCTAssertNil(saleError)
        XCTAssertNotNil(saleResult)
        XCTAssertEqual(EXPECTED_CODE, saleResult?.responseCode)
    }

    // Omitting mmaId on a Partner app linked to multiple MMAs is genuinely ambiguous -
    // GP-API rejects it outright (confirmed: 400 MANDATORY_DATA_MISSING "Multiple accounts
    // found") rather than silently defaulting, proving why mmaId is required here.
    // Backward compatibility for single-MMA partners is already covered by the pre-existing
    // GpApiCreditWithMerchantIdTests.swift, which never sets mmaId and still passes.
    func test_sale_without_mma_fails_when_multiple_mmas_exist() {
        configureService(mmaId: nil, merchantId: MER_ID_UNDER_MMA_2)

        let saleExpectation = expectation(description: "Sale without MMA Expectation")
        var saleResult: Transaction?
        var saleError: Error?

        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                saleResult = $0
                saleError = $1
                saleExpectation.fulfill()
            }

        wait(for: [saleExpectation], timeout: 10.0)
        XCTAssertNil(saleResult)
        guard let gatewayError = saleError as? GatewayException else {
            XCTFail("Expected a GatewayException, got \(String(describing: saleError))")
            return
        }
        XCTAssertEqual("MANDATORY_DATA_MISSING", gatewayError.responseCode)
        XCTAssertEqual("40107", gatewayError.responseMessage)
    }

    // Negative: a merchant from MMA_2 must not be reachable through MMA_1's URL scope.
    func test_sale_with_mismatched_mma_fails() {
        configureService(mmaId: MMA_1, merchantId: MER_ID_UNDER_MMA_2)

        let saleExpectation = expectation(description: "Sale with mismatched MMA Expectation")
        var saleResult: Transaction?
        var saleError: Error?

        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                saleResult = $0
                saleError = $1
                saleExpectation.fulfill()
            }

        wait(for: [saleExpectation], timeout: 10.0)
        XCTAssertNil(saleResult)
        XCTAssertNotNil(saleError)
    }

    // The /accesstoken call must stay unaffected by mmaId being set on the config.
    func test_access_token_unaffected_by_mma() {
        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "transaction_processing"

        let config = GpApiConfig(
            appId: APP_ID,
            appKey: APP_KEY,
            accessTokenInfo: accessTokenInfo,
            merchantId: MER_ID_UNDER_MMA_2,
            mmaId: MMA_2
        )

        try? ServicesContainer.configureService(config: config)

        let saleExpectation = expectation(description: "Sign-in via Sale Expectation")
        var saleError: Error?

        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                saleError = $1
                saleExpectation.fulfill()
            }

        wait(for: [saleExpectation], timeout: 10.0)
        XCTAssertNil(saleError)
        XCTAssertNotNil(config.accessTokenInfo?.token)
    }
}
