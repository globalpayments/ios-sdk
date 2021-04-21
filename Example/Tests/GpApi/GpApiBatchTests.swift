import XCTest
import GlobalPayments_iOS_SDK

class GpApiBatchTests: XCTestCase {

    private var card: CreditCardData!

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "P3LRVjtGRGxWQQJDE345mSkEh2KfdAyg",
            appKey: "ockJr6pv6KFoGiZA",
            channel: .cardPresent
        ))
    }

    override func setUp() {
        super.setUp()

        card = CreditCardData()
        card.number = "5425230000004415"
        card.expMonth = 5
        card.expYear = 2025
        card.cvn = "852"
    }

    override func tearDown() {
        super.tearDown()

        card = nil
    }

    func test_close_batch() {

        // Charge

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        let expectedAmount: NSDecimalNumber = 1.99
        let currency: String = "USD"
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        card.charge(amount: expectedAmount)
            .withCurrency(currency)
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

        // Close Batch

        // GIVEN
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        let expectedBatchReference = chargeTransactionResult?.batchSummary?.batchReference
        let expectedTransactionCount = 1
        var closeBatchBatchSummaryResult: BatchSummary?
        var closeBatchBatchSummaryError: Error?

        // WHEN
        sleep(1)
        BatchService.closeBatch(batchReference: expectedBatchReference) {
            closeBatchBatchSummaryResult = $0
            closeBatchBatchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(closeBatchBatchSummaryError)
        XCTAssertNotNil(closeBatchBatchSummaryResult)
        XCTAssertEqual(closeBatchBatchSummaryResult?.status, "CLOSED")
        XCTAssertEqual(closeBatchBatchSummaryResult?.batchReference, expectedBatchReference)
    }

    func test_close_batch_with_closed_batch_reference() {

        // Charge

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        card.charge(amount: 1.99)
            .withCurrency("USD")
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

        // Close Batch

        // GIVEN
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        let batchReference = chargeTransactionResult?.batchSummary?.batchReference
        var closeBatchBatchSummaryResult: BatchSummary?
        var closeBatchBatchSummaryError: Error?

        // WHEN
        sleep(2)
        BatchService.closeBatch(batchReference: batchReference) {
            closeBatchBatchSummaryResult = $0
            closeBatchBatchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(closeBatchBatchSummaryError)
        XCTAssertNotNil(closeBatchBatchSummaryResult)
        XCTAssertEqual(closeBatchBatchSummaryResult?.status, "CLOSED")

        // Close Batch - repeated

        // GIVEN
        let closeBatchRepeatExpectation = expectation(description: "Close Batch Repeat Expectation")
        var closeBatchRepeatBatchSummaryResult: BatchSummary?
        var closeBatchRepeatBatchSummaryError: GatewayException?

        // WHEN
        sleep(2)
        BatchService.closeBatch(batchReference: batchReference) {
            closeBatchRepeatBatchSummaryResult = $0
            if let error = $1 as? GatewayException {
                closeBatchRepeatBatchSummaryError = error
            }
            closeBatchRepeatExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchRepeatExpectation], timeout: 10.0)
        XCTAssertNil(closeBatchRepeatBatchSummaryResult)
        XCTAssertNotNil(closeBatchRepeatBatchSummaryError)
        XCTAssertEqual(closeBatchRepeatBatchSummaryError?.responseCode, "INVALID_BATCH_ACTION")
        XCTAssertEqual(closeBatchRepeatBatchSummaryError?.responseMessage, "40014")
        if let message = closeBatchRepeatBatchSummaryError?.message {
            XCTAssertEqual(message, "Status Code: 400 - 5,No current batch")
        } else {
            XCTFail("closeBatchRepeatBatchSummaryError?.message cannot be nil")
        }
    }

    func test_close_batch_with_invalid_batch_reference() {
        // GIVEN
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        let batchReference = "UNKNOWN"
        var closeBatchBatchSummaryResult: BatchSummary?
        var closeBatchBatchSummaryError: GatewayException?

        // WHEN
        BatchService.closeBatch(batchReference: batchReference) {
            closeBatchBatchSummaryResult = $0
            if let error = $1 as? GatewayException {
                closeBatchBatchSummaryError = error
            }
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(closeBatchBatchSummaryResult)
        XCTAssertNotNil(closeBatchBatchSummaryError)
        XCTAssertEqual(closeBatchBatchSummaryError?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(closeBatchBatchSummaryError?.responseMessage, "40118")
        if let message = closeBatchBatchSummaryError?.message {
            XCTAssertEqual(message, "Status Code: 404 - Batch \(batchReference) not found at this location.")
        } else {
            XCTFail("closeBatchRepeatBatchSummaryError?.message cannot be nil")
        }
    }
}
