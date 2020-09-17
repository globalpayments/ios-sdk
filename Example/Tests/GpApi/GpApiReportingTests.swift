import XCTest
import GlobalPayments_iOS_SDK

class GpApiReportingTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()

        try ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA"
            )
        )
    }

    func test_report_transaction_detail() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let transactionId = "TRN_TvY1QFXxQKtaFSjNaLnDVdo3PZ7ivz"
        var transactionSummaryResponse: TransactionSummary?
        var transactionSummaryError: Error?

        // WHEN
        ReportingService
            .transactionDetail(transactionId: transactionId)
            .execute { transactionSummary, error in
                transactionSummaryResponse = transactionSummary
                transactionSummaryError = error
                reportingExecuteExpectation.fulfill()
        }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionSummaryResponse)
        XCTAssertNil(transactionSummaryError)
        XCTAssertEqual(transactionId, transactionSummaryResponse?.transactionId)
    }

    func test_report_find_transactions_with_criteria() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let thirtyDaysBefore = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        ReportingService.findTransactions()
            .orderBy(.timeCreated, .descending)
            .where(.startDate, thirtyDaysBefore)
            //.and(criteria: .transactionStatus, transactionStatus: .captured)
            .execute { transactionsSummary, error in
                transactionsSummaryResponse = transactionsSummary
                transactionsSummaryError = error
                reportingExecuteExpectation.fulfill()
        }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNil(transactionsSummaryError)
        XCTAssertEqual(transactionsSummaryResponse!.isEmpty, false)
    }
}
