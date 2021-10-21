import XCTest
import GlobalPayments_iOS_SDK

class GpApiReportingDepositsTests: XCTestCase {

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "GkwdYGzQrEy1SdTz7S10P8uRjFMlEsJg",
            appKey: "zvXE2DmmoxPbQ6d0",
            channel: .cardNotPresent
        ))
    }

    func test_report_deposit_detail() {
        guard let depositReference = try? awaitResponse(getDepositSummary)?.depositId else {
            XCTFail("transactionId cannot be nil")
            return
        }

        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposit With id")
        var depositSummary: DepositSummary?
        var depositError: Error?

        // WHEN
        ReportingService
            .depositDetail(depositReference: depositReference)
            .execute { summary, error in
                depositSummary = summary
                depositError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 20.0)
        XCTAssertNil(depositError)
        XCTAssertNotNil(depositSummary)
        XCTAssertEqual(depositSummary?.depositId, depositReference)
    }

    func test_report_deposit_detail_invalid_id() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposit With id")
        let depositReference = "INVALID_ID"
        var depositSummary: DepositSummary?
        var depositError: GatewayException?

        // WHEN
        ReportingService
            .depositDetail(depositReference: depositReference)
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

    func test_report_find_deposits_by_startDate() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposits With Criteria")
        let startDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findDepositsPaged(page: 1, pageSize: 10)
        var depositSummaryList: [DepositSummary]?
        var depositError: Error?

        // WHEN
        reportingService
            .orderBy(depositOrderBy: .timeCreated, .descending)
            .where(.startDate, startDate)
            .execute {
                depositSummaryList = $0?.results
                depositError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(depositError)
        XCTAssertNotNil(depositSummaryList)
        if let responseList = depositSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for deposit in responseList {
                guard let depositDate = deposit.depositDate else {
                    XCTFail("depositDate cannot be nil")
                    return
                }
                XCTAssertTrue(depositDate >= startDate)
            }
        } else {
            XCTFail("transactionSummaryList cannot be nil")
        }
    }

    func test_report_find_deposits_order_by_depositId() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposits With Criteria")
        let startDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findDepositsPaged(page: 1, pageSize: 10)
        var depositSummaryList: [String]?
        var sortedDepositSummaryList: [String]?
        var depositError: Error?

        // WHEN
        reportingService
            .orderBy(depositOrderBy: .depositId, .descending)
            .where(.startDate, startDate)
            .execute {
                depositSummaryList = $0?.results.compactMap { $0.depositId }
                sortedDepositSummaryList = $0?.results.compactMap { $0.depositId }.sorted(by: > )
                depositError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(depositError)
        XCTAssertNotNil(depositSummaryList)
        XCTAssertEqual(depositSummaryList, sortedDepositSummaryList)
    }

    func test_report_find_deposits_order_by_status() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposits With Criteria")
        let reportingService = ReportingService.findDepositsPaged(page: 1, pageSize: 10)
        let startDate = Date().addYears(-2).addDays(1)
        var depositSummaryList: [String]?
        var sortedDepositSummaryList: [String]?
        var depositError: Error?

        // WHEN
        reportingService
            .orderBy(depositOrderBy: .status, .ascending)
            .where(.startDate, startDate)
            .execute {
                depositSummaryList = $0?.results.compactMap { $0.status }
                sortedDepositSummaryList = $0?.results.compactMap { $0.status }.sorted(by: <)
                depositError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(depositError)
        XCTAssertNotNil(depositSummaryList)
        XCTAssertEqual(depositSummaryList, sortedDepositSummaryList)
    }

    func test_report_find_deposits_order_by_type() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposits With Criteria")
        let reportingService = ReportingService.findDepositsPaged(page: 1, pageSize: 10)
        let startDate = Date().addYears(-2).addDays(1)
        var depositSummaryList: [String]?
        var sortedDepositSummaryList: [String]?
        var depositError: Error?

        // WHEN
        reportingService
            .orderBy(depositOrderBy: .type, .ascending)
            .where(.startDate, startDate)
            .execute {
                depositSummaryList = $0?.results.compactMap { $0.type }
                sortedDepositSummaryList = $0?.results.compactMap { $0.type }.sorted(by: <)
                depositError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(depositError)
        XCTAssertNotNil(depositSummaryList)
        XCTAssertEqual(depositSummaryList, sortedDepositSummaryList)
    }

    // MARK: - Utils

    private func getDepositSummary(_ completion: @escaping ((DepositSummary?) -> Void)) {
        let reportingService = ReportingService.findDepositsPaged(page: 1, pageSize: 100)
        reportingService
            .orderBy(depositOrderBy: .timeCreated, .descending)
            .where(.startDate, Date().addYears(-2).addDays(1))
            .execute { pagedResult, _ in
                let results = pagedResult?.results.filter { !$0.depositId.isNilOrEmpty }

                completion(results?.first)
            }
    }
}
