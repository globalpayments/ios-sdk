import XCTest
import GlobalPayments_iOS_SDK

class GpApiEbtTests: XCTestCase {

    private var card: EBTCardData!
    private var track: EBTTrackData!
    private var amount: NSDecimalNumber = 10.0
    private var currency: String = "USD"

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(
            config: GpApiConfig(
                appId: "x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc",
                appKey: "DYcEE2GpSzblo0ib",
                channel: .cardPresent
            )
        )
    }

    override func setUp() {
        super.setUp()

        card = EBTCardData()
        card.number = "4012002000060016"
        card.expMonth = 12
        card.expYear = 2025
        card.cvn = "123"
        card.pinBlock = "32539F50C245A6A93D123412324000AA"
        card.cardPresent = true

        track = EBTTrackData()
        track.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        track.entryMethod = .swipe
        track.pinBlock = "32539F50C245A6A93D123412324000AA"
    }

    override func tearDown() {
        super.tearDown()

        card = nil
        track = nil
    }

    func test_ebt_sale_manual() {
        // GIVEN
        let ebtSaleExpectation = expectation(description: "EBT sale expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card.charge(amount: amount)
            .withCurrency(currency)
            .execute {
                transactionResult = $0
                transactionError = $1
                ebtSaleExpectation.fulfill()
        }

        // THEN
        wait(for: [ebtSaleExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResult)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_ebt_sale_swipe() {
        // GIVEN
        let ebtSaleExpectation = expectation(description: "EBT sale expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        track.charge(amount: amount)
            .withCurrency(currency)
            .withAllowDuplicates(true)
            .execute {
                transactionResult = $0
                transactionError = $1
                ebtSaleExpectation.fulfill()
        }

        // THEN
        wait(for: [ebtSaleExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResult)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_ebt_refund() {
        // GIVEN
        let ebtRefundExpectation = expectation(description: "EBT refund expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card.refund(amount: amount)
            .withCurrency(currency)
            .execute {
                transactionResult = $0
                transactionError = $1
                ebtRefundExpectation.fulfill()
        }

        // THEN
        wait(for: [ebtRefundExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResult)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_ebt_transaction_refund() {

        // Charge

        // GIVEN
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        card.charge(amount: amount)
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

        // Refund

        // GIVEN
        let refundExpectation = expectation(description: "Refund Expectation")
        var refundTransactionResult: Transaction?
        var refundTransactionError: Error?

        // WHEN
        chargeTransactionResult?
            .refund()
            .withCurrency(currency)
            .execute {
                refundTransactionResult = $0
                refundTransactionError = $1
                refundExpectation.fulfill()
            }

        // THEN
        wait(for: [refundExpectation], timeout: 10.0)
        XCTAssertNil(refundTransactionError)
        XCTAssertNotNil(refundTransactionResult)
        XCTAssertEqual(refundTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(refundTransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }
}
