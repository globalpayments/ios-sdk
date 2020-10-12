import XCTest
import GlobalPayments_iOS_SDK

class GpApiReportingTests: XCTestCase {

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig (
            appId: "GkwdYGzQrEy1SdTz7S10P8uRjFMlEsJg",
            appKey: "zvXE2DmmoxPbQ6d0",
            channel: .cardNotPresent
        ))
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
            .orderBy(transactionSortProperty: .timeCreated, .descending)
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
        if let response = transactionsSummaryResponse {
            XCTAssertEqual(response.isEmpty, false)
        } else {
            XCTFail("transactionsSummaryResponse cannot be nil")
        }
    }

    func test_report_find_transactions_no_criteria() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "FindTransactionsExpectation")
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        ReportingService
            .findTransactions()
            .execute { list, error in
                transactionSummaryList = list
                transactionError = error
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNil(transactionError)
    }

    func test_report_find_deposits_with_criteria() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposits With Criteria")
        let thirtyDaysBefore = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        var depositSummaryList: [DepositSummary]?
        var depositError: Error?
        
        // WHEN
        ReportingService.findDeposits()
            .orderBy(depositOrderBy: .timeCreated, .descending)
            .withDepositStatus(.irreg)
            .withPaging(1, 10)
            .where(.startDate, thirtyDaysBefore)
            .execute { list, error in
                depositSummaryList = list
                depositError = error
                summaryExpectation.fulfill()
            }
            
        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(depositError)
        XCTAssertNotNil(depositSummaryList)
    }

    func test_report_find_deposit_with_id() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposit With id")
        let depositId = "DEP_2342423423"
        var depositSummary: DepositSummary?
        var depositError: Error?

        // WHEN
        ReportingService
            .depositDetail(depositId: depositId)
            .execute { summary, error in
                depositSummary = summary
                depositError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 20.0)
        XCTAssertNil(depositError)
        XCTAssertNotNil(depositSummary)
    }

    func test_report_find_deposit_with_invalid_id() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposit With id")
        let depositId = "INVALID_ID"
        var depositSummary: DepositSummary?
        var depositError: GatewayException?

        // WHEN
        ReportingService
            .depositDetail(depositId: depositId)
            .execute { summary, error in
                depositSummary = summary
                if let gatewayException = error as? GatewayException {
                    depositError = gatewayException
                }
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 20.0)
        XCTAssertNil(depositSummary)
        XCTAssertNotNil(depositError)
        XCTAssertEqual(depositError?.responseCode, "RESOURCE_NOT_FOUND")
    }

    // DISPUTES

    func test_report_find_disputes_with_criteria() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService.findDisputes()
            .orderBy(disputeOrderBy: .brand, .ascending)
            .withPaging(1, 10)
            .withDisputeStatus(.closed)
            .withDisputeStage(.compliance)
            .withAdjustmentFunding(.debit)
            .where(.startStageDate, oneYearBefore)
            .execute { summaryList, error in
                disputeSummaryList = summaryList
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
    }

    func test_report_find_dispute_by_given_id() {
        // GIVEN
        let summaryExpectation = expectation(description: "Find Dispute By Given ID")
        let disputeId = "DIS_SAND_abcd1253"
        var disputeSummary: DisputeSummary?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService
            .disputeDetail(disputeId: disputeId)
            .execute {
                disputeSummary = $0
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummary)
    }

    func test_report_find_settlement_disputes_with_criteria() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Settlement Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService.findSettlementDisputes()
            .orderBy(disputeOrderBy: .brand, .ascending)
            .withPaging(1, 10)
            .withDisputeStatus(.underReview)
            .withDisputeStage(.chargeback)
            .withAdjustmentFunding(.debit)
            .withAccountName("Settlement Reporting")
            .where(.startStageDate, oneYearBefore)
            .execute { summaryList, error in
                disputeSummaryList = summaryList
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
    }

    func test_report_accept_dispute_success() {
        // GIVEN
        let summaryExpectation = expectation(description: "Accept Dispute")
        let disputeId = "DIS_SAND_abcd1234"
        var disputeAction: DisputeAction?
        var disputeActionError: Error?

        // WHEN
        ReportingService
            .acceptDispute(id: disputeId)
            .execute {
                disputeAction = $0
                disputeActionError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNotNil(disputeAction)
        XCTAssertNil(disputeActionError)
    }

    func test_report_accept_dispute_failure() {
        // GIVEN
        let summaryExpectation = expectation(description: "Accept Dispute")
        let disputeId = "UNKNOWN"
        var disputeAction: DisputeAction?
        var disputeActionError: GatewayException?

        // WHEN
        ReportingService
            .acceptDispute(id: disputeId)
            .execute { action, error in
                disputeAction = action
                if let gatewayError = error as? GatewayException {
                    disputeActionError = gatewayError
                }
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeAction)
        XCTAssertNotNil(disputeActionError)
        XCTAssertEqual(disputeActionError?.responseCode, "INVALID_DISPUTE_ACTION")
    }

    func test_report_challange_dispute_success() {
        // GIVEN
        let challangeExpectation = expectation(description: "Challange Expectation")
        let disputeId = "DIS_SAND_abcd1234"
        let bundle = Bundle(for: type(of: self))
        let disputeDocuments = [
            DocumentInfo(
                type: .proofOfDelivery,
                b64Content: ResourceLoader.loadFile(name: "gp_logo", extension: .pdf, bundle: bundle)
            )
        ]
        var disputeAction: DisputeAction?
        var disputeActionError: Error?

        // WHEN
        ReportingService
            .challangeDispute(id: disputeId, documents: disputeDocuments)
            .execute { action, error in
                disputeAction = action
                disputeActionError = error
                challangeExpectation.fulfill()
            }

        // THEN
        wait(for: [challangeExpectation], timeout: 20.0)
        XCTAssertNotNil(disputeAction)
        XCTAssertNil(disputeActionError)
    }

    func test_load_test_resources() {
        // GIVEN
        let bundle = Bundle(for: type(of: self))

        //WHEN
        let pdfData = ResourceLoader.loadFile(
            name: "gp_logo",
            extension: .pdf,
            bundle: bundle
        )
        let pngData = ResourceLoader.loadFile(
            name: "gp_logo",
            extension: .png,
            bundle: bundle
        )

        // THEN
        XCTAssertNotNil(pdfData)
        XCTAssertNotNil(pngData)
    }
}
