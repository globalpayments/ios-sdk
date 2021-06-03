import XCTest
import GlobalPayments_iOS_SDK

class GpApiBatchTests: XCTestCase {

    private var card: CreditTrackData!
    private let currency = "USD"
    private let tagData =
                "82021C008407A0000002771010950580000000009A031709289C01005F280201245F2A0201245F3401019F02060000000010009F03060000000000009F080200019F090200019F100706010A03A420009F1A0201249F26089CC473F4A4CE18D39F2701809F3303E0F8C89F34030100029F3501229F360200639F370435EFED379F410400000019"

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

        card = CreditTrackData()
        card.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        card.entryMethod = .swipe
    }

    override func tearDown() {
        super.tearDown()

        card = nil
    }

    func test_close_batch() {

        // Charge

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card.charge(amount: 1.99)
            .withCurrency(currency)
            .execute {
                transactionResult = $0
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        assertTransactionResponse(transaciton: transactionResult, status: .captured)

        // Close Batch

        // GIVEN
        sleep(1)
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: Error?

        // WHEN
        BatchService.closeBatch(batchReference: transactionResult?.batchSummary?.batchReference) {
            batchSummaryResult = $0
            batchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(batchSummaryError)
        assertBatchCloseResponse(batchSummary: batchSummaryResult, amount: 1.99)
    }

    func test_close_batch_chip_transaction() {

        // Charge

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card.charge(amount: 1.99)
            .withCurrency(currency)
            .withTagData(tagData)
            .execute {
                transactionResult = $0
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        assertTransactionResponse(transaciton: transactionResult, status: .captured)

        // Close batch

        // GIVEN
        sleep(1)
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: Error?

        // WHEN
        BatchService.closeBatch(batchReference: transactionResult?.batchSummary?.batchReference) {
            batchSummaryResult = $0
            batchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(batchSummaryError)
        assertBatchCloseResponse(batchSummary: batchSummaryResult, amount: 1.99)
    }

    func test_close_batch_auth_and_capture() {

        // Authorize

        // GIVEN
        let authorizeExecuteExpectation = expectation(description: "Authorize Execute Expectation")
        var authorizeTransactionResult: Transaction?
        var authorizeTransactionError: Error?

        // WHEN
        card.authorize(amount: 1.99)
            .withCurrency(currency)
            .execute {
                authorizeTransactionResult = $0
                authorizeTransactionError = $1
                authorizeExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [authorizeExecuteExpectation], timeout: 10.0)
        XCTAssertNil(authorizeTransactionError)
        assertTransactionResponse(transaciton: authorizeTransactionResult, status: .preauthorized)

        // Capture

        // GIVEN
        let captureExecuteExpectation = expectation(description: "Authorize Execute Expectation")
        var captureTransactionResult: Transaction?
        var captureTransactionError: Error?

        // WHEN
        authorizeTransactionResult?
            .capture(amount: 1.99)
            .withCurrency(currency)
            .execute {
                captureTransactionResult = $0
                captureTransactionError = $1
                captureExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [captureExecuteExpectation], timeout: 10.0)
        XCTAssertNil(captureTransactionError)
        assertTransactionResponse(transaciton: captureTransactionResult, status: .captured)

        // Close Batch

        // GIVEN
        sleep(1)
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: Error?

        // WHEN
        BatchService.closeBatch(batchReference: captureTransactionResult?.batchSummary?.batchReference) {
            batchSummaryResult = $0
            batchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(batchSummaryError)
        assertBatchCloseResponse(batchSummary: batchSummaryResult, amount: 1.99)
    }

    func test_close_batch_contactless_transaction() {

        // Charge

        // GIVEN
        let debitCard = DebitTrackData()
        debitCard.value = ";4024720012345671=18125025432198712345?"
        debitCard.entryMethod = .proximity
        debitCard.pinBlock = "AFEC374574FC90623D010000116001EE"
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        debitCard
            .charge(amount: 1.99)
            .withCurrency(currency)
            .withTagData(tagData)
            .execute {
                transactionResult = $0
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        assertTransactionResponse(transaciton: transactionResult, status: .captured)

        // Close batch

        // GIVEN
        sleep(1)
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: Error?

        // WHEN
        BatchService.closeBatch(batchReference: transactionResult?.batchSummary?.batchReference) {
            batchSummaryResult = $0
            batchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(batchSummaryError)
        assertBatchCloseResponse(batchSummary: batchSummaryResult, amount: 1.99)
    }

    func test_close_batch_multiple_charge_credit_track_data() {

        // Charge 1

        // GIVEN
        let charge1Expectation = expectation(description: "Charge 1 Expectation")
        var charge1TransactionResult: Transaction?
        var charge1TransactionError: Error?

        // WHEN
        card.charge(amount: 1.99)
            .withCurrency(currency)
            .execute {
                charge1TransactionResult = $0
                charge1TransactionError = $1
                charge1Expectation.fulfill()
            }

        // THEN
        wait(for: [charge1Expectation], timeout: 10)
        XCTAssertNil(charge1TransactionError)
        assertTransactionResponse(transaciton: charge1TransactionResult, status: .captured)

        // Charge 2

        // GIVEN
        let charge2Expectation = expectation(description: "Charge 1 Expectation")
        var charge2TransactionResult: Transaction?
        var charge2TransactionError: Error?

        // WHEN
        card.charge(amount: 1.99)
            .withCurrency(currency)
            .execute {
                charge2TransactionResult = $0
                charge2TransactionError = $1
                charge2Expectation.fulfill()
            }

        // THEN
        wait(for: [charge2Expectation], timeout: 10)
        XCTAssertNil(charge2TransactionError)
        assertTransactionResponse(transaciton: charge2TransactionResult, status: .captured)

        // Close Batch

        // GIVEN
        sleep(1)
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: Error?

        // WHEN
        BatchService.closeBatch(batchReference: charge2TransactionResult?.batchSummary?.batchReference) {
            batchSummaryResult = $0
            batchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(batchSummaryError)
        assertBatchCloseResponse(batchSummary: batchSummaryResult, amount: 3.98)
    }

    func test_close_batch_refund_credit_track_data() {

        // Charge

        // GIVEN
        let chargeExecuteExpectation = expectation(description: "Authorize Execute Expectation")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        card.charge(amount: 1.99)
            .withCurrency(currency)
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExecuteExpectation], timeout: 10.0)
        XCTAssertNil(chargeTransactionError)
        assertTransactionResponse(transaciton: chargeTransactionResult, status: .captured)

        // Refund

        // GIVEN
        let refundExecuteExpectation = expectation(description: "Authorize Execute Expectation")
        var refundTransactionResult: Transaction?
        var refundTransactionError: Error?

        // WHEN
        chargeTransactionResult?
            .refund(amount: 1.99)
            .withCurrency(currency)
            .execute {
                refundTransactionResult = $0
                refundTransactionError = $1
                refundExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [refundExecuteExpectation], timeout: 10.0)
        XCTAssertNil(refundTransactionError)
        assertTransactionResponse(transaciton: refundTransactionResult, status: .captured)

        // Close Batch

        // GIVEN
        sleep(1)
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: Error?

        // WHEN
        BatchService.closeBatch(batchReference: chargeTransactionResult?.batchSummary?.batchReference) {
            batchSummaryResult = $0
            batchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(batchSummaryError)
        assertBatchCloseResponse(batchSummary: batchSummaryResult, amount: 0)
    }

    func test_close_batch_debit_track_data() {

        // Charge

        // GIVEN
        let debitCard = DebitTrackData()
        debitCard.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        debitCard.entryMethod = .swipe
        debitCard.pinBlock = "32539F50C245A6A93D123412324000AA"
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        debitCard
            .charge(amount: 1.99)
            .withCurrency(currency)
            .withTagData(tagData)
            .execute {
                transactionResult = $0
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        assertTransactionResponse(transaciton: transactionResult, status: .captured)

        // Close batch

        // GIVEN
        sleep(1)
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: Error?

        // WHEN
        BatchService.closeBatch(batchReference: transactionResult?.batchSummary?.batchReference) {
            batchSummaryResult = $0
            batchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(batchSummaryError)
        assertBatchCloseResponse(batchSummary: batchSummaryResult, amount: 1.99)
    }

    func test_close_batch_reverse_debit_track_data() {

        // Authorize

        // GIVEN
        let debitCard = DebitTrackData()
        debitCard.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        debitCard.entryMethod = .swipe
        debitCard.pinBlock = "32539F50C245A6A93D123412324000AA"
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        debitCard
            .authorize(amount: 1.99)
            .withCurrency(currency)
            .execute {
                transactionResult = $0
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        assertTransactionResponse(transaciton: transactionResult, status: .preauthorized)

        // Reverse

        // GIVEN
        let reverseExpectation = expectation(description: "Reverse Expectation")
        var reverseTransactionResult: Transaction?
        var reverseTransactionError: Error?

        // WHEN
        transactionResult?
            .reverse()
            .withCurrency(currency)
            .execute(completion: {
                reverseTransactionResult = $0
                reverseTransactionError = $1
                reverseExpectation.fulfill()
            })

        // THEN
        wait(for: [reverseExpectation], timeout: 10.0)
        XCTAssertNil(reverseTransactionError)
        assertTransactionResponse(transaciton: reverseTransactionResult, status: .reversed)

        // Close batch

        // GIVEN
        sleep(1)
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: GatewayException?

        // WHEN
        BatchService.closeBatch(batchReference: transactionResult?.batchSummary?.batchReference) {
            batchSummaryResult = $0
            if let error = $1 as? GatewayException {
                batchSummaryError = error
            }
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(batchSummaryResult)
        XCTAssertNotNil(batchSummaryError)
        XCTAssertEqual(batchSummaryError?.responseCode, "MANDATORY_DATA_MISSING")
        XCTAssertEqual(batchSummaryError?.responseMessage, "40223")
        if let message = batchSummaryError?.message {
            XCTAssertEqual(message, "Status Code: 400 - Request expects the batch_id")
        } else {
            XCTFail("batchSummaryError?.message cannot be nil")
        }
    }

    func test_close_batch_with_card_number_details() {

        // Charge

        // GIVEN
        let creditCard = CreditCardData()
        creditCard.number = "4263970000005262"
        creditCard.expMonth = 5
        creditCard.expYear = 2025
        creditCard.cvn = "123"
        let chargeExpectation = expectation(description: "Charge Expectation")
        let expectedAmount: NSDecimalNumber = 1.99
        let currency: String = "USD"
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        creditCard
            .charge(amount: expectedAmount)
            .withCurrency(currency)
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeTransactionError)
        assertTransactionResponse(transaciton: chargeTransactionResult, status: .captured)

        // Close Batch

        // GIVEN
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        let expectedBatchReference = chargeTransactionResult?.batchSummary?.batchReference
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
        assertBatchCloseResponse(batchSummary: closeBatchBatchSummaryResult, amount: expectedAmount)
    }

    func test_close_batch_with_card_number_details_declined_transaction() {

        // CHARGE

        // GIVEN
        let creditCard = CreditCardData()
        creditCard.number = "4263970000005262"
        creditCard.expMonth = 5
        creditCard.expYear = 2025
        creditCard.cvn = "852"
        let chargeExpectation = expectation(description: "Charge Expectation")
        let expectedAmount: NSDecimalNumber = 1.99
        let currency: String = "USD"
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        creditCard
            .charge(amount: expectedAmount)
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
        XCTAssertEqual(chargeTransactionResult?.responseCode, "DECLINED")
        XCTAssertEqual(chargeTransactionResult?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))

        // Close batch

        // GIVEN
        sleep(1)
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: GatewayException?

        // WHEN
        BatchService.closeBatch(batchReference: chargeTransactionResult?.batchSummary?.batchReference) {
            batchSummaryResult = $0
            if let error = $1 as? GatewayException {
                batchSummaryError = error
            }
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(batchSummaryResult)
        XCTAssertNotNil(batchSummaryError)
        XCTAssertEqual(batchSummaryError?.responseCode, "INVALID_BATCH_ACTION")
        XCTAssertEqual(batchSummaryError?.responseMessage, "40017")
        if let message = batchSummaryError?.message {
            XCTAssertEqual(message, "Status Code: 400 - 9,No transaction associated with batch")
        } else {
            XCTFail("batchSummaryError?.message cannot be nil")
        }
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
        assertTransactionResponse(transaciton: chargeTransactionResult, status: .captured)

        // Close Batch

        // GIVEN
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        let batchReference = chargeTransactionResult?.batchSummary?.batchReference
        var closeBatchBatchSummaryResult: BatchSummary?
        var closeBatchBatchSummaryError: Error?

        // WHEN
        sleep(1)
        BatchService.closeBatch(batchReference: batchReference) {
            closeBatchBatchSummaryResult = $0
            closeBatchBatchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(closeBatchBatchSummaryError)
        assertBatchCloseResponse(batchSummary: closeBatchBatchSummaryResult, amount: 1.99)

        // Close Batch - repeated

        // GIVEN
        let closeBatchRepeatExpectation = expectation(description: "Close Batch Repeat Expectation")
        var closeBatchRepeatBatchSummaryResult: BatchSummary?
        var closeBatchRepeatBatchSummaryError: GatewayException?

        // WHEN
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

    func test_close_batch_verify_missing_batch_id() {

        // Verify

        // GIVEN
        let verifyExpectation = expectation(description: "Verify Expectation")
        var verifyTransactionResult: Transaction?
        var verifyTransactionError: Error?

        // WHEN
        card.verify()
            .withCurrency(currency)
            .execute {
                verifyTransactionResult = $0
                verifyTransactionError = $1
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(verifyTransactionError)
        XCTAssertNotNil(verifyTransactionResult)
        XCTAssertEqual(verifyTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(verifyTransactionResult?.responseMessage, "VERIFIED")

        // Close batch

        // GIVEN
        sleep(1)
        let closeBatchExpectation = expectation(description: "Close Batch Expectation")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: GatewayException?

        // WHEN
        BatchService.closeBatch(batchReference: verifyTransactionResult?.batchSummary?.batchReference) {
            batchSummaryResult = $0
            if let error = $1 as? GatewayException {
                batchSummaryError = error
            }
            closeBatchExpectation.fulfill()
        }

        // THEN
        wait(for: [closeBatchExpectation], timeout: 10.0)
        XCTAssertNil(batchSummaryResult)
        XCTAssertNotNil(batchSummaryError)
        XCTAssertEqual(batchSummaryError?.responseCode, "MANDATORY_DATA_MISSING")
        XCTAssertEqual(batchSummaryError?.responseMessage, "40223")
        if let message = batchSummaryError?.message {
            XCTAssertEqual(message, "Status Code: 400 - Request expects the batch_id")
        } else {
            XCTFail("batchSummaryError?.message cannot be nil")
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

    private func assertTransactionResponse(transaciton: Transaction?, status: TransactionStatus) {
        XCTAssertNotNil(transaciton)
        XCTAssertEqual(transaciton?.responseCode, "SUCCESS")
        XCTAssertEqual(transaciton?.responseMessage, status.mapped(for: .gpApi))
    }

    private func assertBatchCloseResponse(batchSummary: BatchSummary?, amount: NSDecimalNumber) {
        XCTAssertNotNil(batchSummary)
        XCTAssertEqual(batchSummary?.status, "CLOSED")
        if let transactionCount = batchSummary?.transactionCount {
            XCTAssertTrue(transactionCount >= 1)
        } else {
            XCTFail("batchSummary?.transactionCount cannot be nil")
        }
        if let totalAmount = batchSummary?.totalAmount?.doubleValue {
            XCTAssertTrue(totalAmount >= amount.doubleValue)
        } else {
            XCTFail("batchSummary?.totalAmount cannot be nil")
        }
    }
}
