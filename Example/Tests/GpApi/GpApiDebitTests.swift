import XCTest
import GlobalPayments_iOS_SDK

class GpApiDebitTests: XCTestCase {

    override func setUpWithError() throws {
        try ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardPresent
            )
        )
    }

    func test_debit_sale_swipe() {
        // GIVEN
        let trackChargeExpectation = expectation(description: "Track Charge Expectation")
        let track = DebitTrackData()
        track.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        track.pinBlock = "32539F50C245A6A93D123412324000AA"
        track.entryMethod = .swipe
        var transactionResponse: Transaction?
        var transactionError: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        track.charge(amount: 17.01)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionError = error
                transactionStatusResponse = TransactionStatus(rawValue: transaction!.responseMessage!)
                trackChargeExpectation.fulfill()
        }

        // THEN
        wait(for: [trackChargeExpectation], timeout: 1000000.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatusResponse, TransactionStatus.captured)
    }
}
