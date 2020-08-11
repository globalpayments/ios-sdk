import XCTest
import GlobalPayments_iOS_SDK

class GpApiEbtTests: XCTestCase {

    var card: EBTCardData!

    override func setUpWithError() throws {
        try ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardPresent
            )
        )

        card = EBTCardData()
        card.number = "4012002000060016"
        card.expMonth = 12
        card.expYear = 2025
        card.cvn = "123"
        card.pinBlock = "32539F50C245A6A93D123412324000AA"
    }

    override func tearDown() {
        card = nil
    }

    func test_ebt_balance_inquiry() {
        // GIVEN
        let balanceInquiryExpectation = expectation(description: "EBT Balance Inquiry expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card.balanceInquiry()
            .execute { transaction, error in
                transactionResult = transaction
                transactionError = error
                balanceInquiryExpectation.fulfill()
        }

        // THEN
        wait(for: [balanceInquiryExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResult)
        XCTAssertNil(transactionError)
    }

    func test_ebt_sale() {
        // GIVEN
        let ebtSaleExpectation = expectation(description: "EBT sale expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card.charge(amount: 10)
            .withCurrency("USD")
            .execute { transaction, error in
                transactionResult = transaction
                transactionError = error
                ebtSaleExpectation.fulfill()
        }

        // THEN
        wait(for: [ebtSaleExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResult)
        XCTAssertNil(transactionError)
    }

    func test_ebt_refund() {
        // GIVEN
        let ebtRefundExpectation = expectation(description: "EBT refund expectation")
        var transactionResult: Transaction?
        var transactionError: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        card.refund(amount: 10)
            .withCurrency("USD")
            .execute { transaction, error in
                transactionResult = transaction
                transactionError = error
                transactionStatusResponse = TransactionStatus(rawValue: transaction!.responseMessage!)
                ebtRefundExpectation.fulfill()
        }

        // THEN
        wait(for: [ebtRefundExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResult)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatusResponse, TransactionStatus.captured)
    }
}
