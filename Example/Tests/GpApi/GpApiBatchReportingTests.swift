import XCTest
import GlobalPayments_iOS_SDK

class GpApiBatchReportingTests: XCTestCase {

    // A pre-existing, already-closed sandbox batch with known field values, used because
    // this merchant account's test card data doesn't produce a chargeable transaction here.
    private static let knownBatchReference = "BAT_b6cac6cc-41ae-4e37-b2d8-eb168fb4907br3jhs"

    override class func setUp() {
        super.setUp()

        let config = GpApiConfig(
            appId: "",
            appKey: "",
            channel: .cardNotPresent
        )
        config.accessTokenInfo = AccessTokenInfo(transactionProcessingAccountName: "Transit_CNP_Transaction_Processing")
        try? ServicesContainer.configureService(config: config)
    }

    func test_get_batch_detail() {

        // GIVEN
        let getBatchDetailExpectation = expectation(description: "Get Batch Detail Expectation")
        var batchDetailResult: BatchSummary?
        var batchDetailError: Error?

        // WHEN
        ReportingService.batchDetail(batchReference: Self.knownBatchReference)
            .execute {
                batchDetailResult = $0
                batchDetailError = $1
                getBatchDetailExpectation.fulfill()
            }

        // THEN
        wait(for: [getBatchDetailExpectation], timeout: 10.0)
        XCTAssertNil(batchDetailError)
        XCTAssertNotNil(batchDetailResult)
        XCTAssertEqual(batchDetailResult?.batchReference, Self.knownBatchReference)
        XCTAssertEqual(batchDetailResult?.status, "CLOSED")
        XCTAssertNotNil(batchDetailResult?.transactionCount)
        XCTAssertNotNil(batchDetailResult?.totalAmount)
        XCTAssertNotNil(batchDetailResult?.timeCreated)
        XCTAssertNotNil(batchDetailResult?.timeClosed)
        XCTAssertNotNil(batchDetailResult?.merchantId)
        XCTAssertNotNil(batchDetailResult?.accountId)
        XCTAssertNotNil(batchDetailResult?.accountName)
        XCTAssertNotNil(batchDetailResult?.sales)
        XCTAssertNotNil(batchDetailResult?.refunds)
        XCTAssertEqual(batchDetailResult?.action?.resultCode, "SUCCESS")

        // host_breakdown/funding breakdown/brand_breakdown are omitted by the gateway on a
        // zero-transaction batch, so only assert their shape when the gateway returns them.
        if let hostBreakdown = batchDetailResult?.hostBreakdown {
            if let fundingDebit = hostBreakdown.fundingDebit {
                XCTAssertTrue(fundingDebit.sales != nil || fundingDebit.refunds != nil)
            }
            if let fundingCredit = hostBreakdown.fundingCredit {
                XCTAssertTrue(fundingCredit.sales != nil || fundingCredit.refunds != nil)
            }
        }
    }

    func test_get_batch_detail_with_invalid_reference() {

        // GIVEN
        let getBatchDetailExpectation = expectation(description: "Get Batch Detail Expectation")
        var batchDetailResult: BatchSummary?
        var batchDetailError: GatewayException?

        // WHEN
        ReportingService.batchDetail(batchReference: "UNKNOWN")
            .execute {
                batchDetailResult = $0
                if let error = $1 as? GatewayException {
                    batchDetailError = error
                }
                getBatchDetailExpectation.fulfill()
            }

        // THEN
        wait(for: [getBatchDetailExpectation], timeout: 10.0)
        XCTAssertNil(batchDetailResult)
        XCTAssertNotNil(batchDetailError)
    }

    // Unlike `knownBatchReference` (zero transactions), this batch has real activity, so
    // host_breakdown/brand_breakdown/funding_debit/funding_credit are guaranteed to be present
    // rather than conditionally asserted.
    func test_get_batch_detail_with_populated_batch() {
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "CJ9IqiLLvbXwT2RiyLzvw3lfAEGGhLMn",
            appKey: "marc1aodIfPORX2B",
            channel: .cardNotPresent
        ), configName: Self.batchTransactionsConfigName)

        // GIVEN
        let getBatchDetailExpectation = expectation(description: "Get Populated Batch Detail Expectation")
        var batchDetailResult: BatchSummary?
        var batchDetailError: Error?

        // WHEN
        ReportingService.batchDetail(batchReference: Self.knownBatchTransactionsReference)
            .execute(configName: Self.batchTransactionsConfigName) {
                batchDetailResult = $0
                batchDetailError = $1
                getBatchDetailExpectation.fulfill()
            }

        // THEN
        wait(for: [getBatchDetailExpectation], timeout: 10.0)
        XCTAssertNil(batchDetailError)
        XCTAssertEqual(batchDetailResult?.status, "CLOSED")
        XCTAssertEqual(batchDetailResult?.transactionCount, 669)
        XCTAssertEqual(batchDetailResult?.sales?.count, 580)
        XCTAssertEqual(batchDetailResult?.refunds?.count, 89)
        XCTAssertEqual(batchDetailResult?.fundingDebit?.count, 55)
        XCTAssertEqual(batchDetailResult?.fundingCredit?.count, 614)
        XCTAssertEqual(batchDetailResult?.action?.resultCode, "SUCCESS")

        let brandBreakdown = batchDetailResult?.brandBreakdown ?? []
        XCTAssertEqual(brandBreakdown.count, 5)
        let mastercardBreakdown = brandBreakdown.first { $0.brand == "MASTERCARD" }
        XCTAssertEqual(mastercardBreakdown?.count, 123)

        let hostBreakdown = batchDetailResult?.hostBreakdown
        XCTAssertEqual(hostBreakdown?.merchantName, "GP API 3CV")
        XCTAssertEqual(hostBreakdown?.reference, "336")
        XCTAssertEqual(hostBreakdown?.count, 659)
        XCTAssertEqual(hostBreakdown?.fundingDebit?.sales?.count, 52)
        XCTAssertEqual(hostBreakdown?.fundingDebit?.refunds?.count, 3)
        XCTAssertEqual(hostBreakdown?.fundingCredit?.sales?.count, 518)
        XCTAssertEqual(hostBreakdown?.fundingCredit?.refunds?.count, 86)
    }

    // MARK: - Batch Transactions

    // GET /batches/{id}/transactions is only enabled for certain settlement-host-backed accounts
    // (confirmed Portico-routed accounts work; the account used elsewhere in this file does not,
    // returning 404 RESOURCE_NOT_FOUND). Also: this endpoint 404s if ANY query params are present
    // (including page/page_size), so no paging params are ever sent for it.
    private static let batchTransactionsConfigName = "batchTransactionsConfig"
    private static let knownBatchTransactionsReference = "BAT_1413764-252"

    override func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "CJ9IqiLLvbXwT2RiyLzvw3lfAEGGhLMn",
            appKey: "marc1aodIfPORX2B",
            channel: .cardNotPresent
        ), configName: Self.batchTransactionsConfigName)
    }

    func test_get_batch_transactions() {

        // GIVEN
        let getBatchTransactionsExpectation = expectation(description: "Get Batch Transactions Expectation")
        var result: BatchTransactionsSummary?
        var resultError: Error?

        // WHEN
        ReportingService.batchTransactions(batchReference: Self.knownBatchTransactionsReference)
            .execute(configName: Self.batchTransactionsConfigName) {
                result = $0
                resultError = $1
                getBatchTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [getBatchTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(resultError)
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.totalRecordCount)
        XCTAssertNotNil(result?.batchTransactionCount)
        XCTAssertNotNil(result?.merchantId)
        XCTAssertNotNil(result?.accountId)
        XCTAssertNotNil(result?.accountName)
        XCTAssertEqual(result?.filterBatchId, Self.knownBatchTransactionsReference)
        XCTAssertEqual(result?.action?.resultCode, "SUCCESS")
        XCTAssertFalse(result?.transactions?.isEmpty ?? true)
        XCTAssertNotNil(result?.transactions?.first?.transactionId)
    }

    // Asserts per-item field mapping against a known transaction (id 200141401461, a REFUND on a
    // MASTERCARD) rather than just checking transactionId is non-nil, including the numeric-id
    // coercion fix (Portico-routed responses return a raw JSON number for "id", not a string).
    func test_get_batch_transactions_maps_all_fields() {

        // GIVEN
        let getBatchTransactionsExpectation = expectation(description: "Get Batch Transactions Expectation")
        var result: BatchTransactionsSummary?
        var resultError: Error?

        // WHEN
        ReportingService.batchTransactions(batchReference: Self.knownBatchTransactionsReference)
            .execute(configName: Self.batchTransactionsConfigName) {
                result = $0
                resultError = $1
                getBatchTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [getBatchTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(resultError)

        let transaction = result?.transactions?.first { $0.transactionId == "200141401461" }
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction?.transactionStatus, .batched)
        XCTAssertEqual(transaction?.transactionType, "REFUND")
        XCTAssertEqual(transaction?.amount, -1)
        XCTAssertEqual(transaction?.currency, "USD")
        XCTAssertEqual(transaction?.referenceNumber, "TRANS-20261022102449302Z5")
        XCTAssertEqual(transaction?.gratuityAmount, 0)
        XCTAssertEqual(transaction?.cashBackAmount, 0)
        XCTAssertEqual(transaction?.taxAmount, 0)
        XCTAssertEqual(transaction?.surchargeAmount, 0)
        XCTAssertEqual(transaction?.gatewayResponseCode, "00")
        XCTAssertEqual(transaction?.gatewayResponseMessage, "APPROVAL")
        XCTAssertEqual(transaction?.cardType, "MASTERCARD")
        XCTAssertEqual(transaction?.authCode, "MC0100")
        XCTAssertEqual(transaction?.maskedCardNumber, "511502******7896")
        XCTAssertEqual(transaction?.cardDetails?.funding, "CREDIT")
        XCTAssertEqual(transaction?.cardDetails?.avsAddressResult, "NOT_CHECKED")
        XCTAssertEqual(transaction?.cardDetails?.avsPostalCodeResult, "NOT_CHECKED")
    }

    func test_get_batch_transactions_with_invalid_reference() {

        // GIVEN
        let getBatchTransactionsExpectation = expectation(description: "Get Batch Transactions Expectation")
        var result: BatchTransactionsSummary?
        var resultError: GatewayException?

        // WHEN
        ReportingService.batchTransactions(batchReference: "UNKNOWN")
            .execute(configName: Self.batchTransactionsConfigName) {
                result = $0
                if let error = $1 as? GatewayException {
                    resultError = error
                }
                getBatchTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [getBatchTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(result)
        XCTAssertNotNil(resultError)
    }
}

