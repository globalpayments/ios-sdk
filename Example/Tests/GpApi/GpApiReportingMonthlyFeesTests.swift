import XCTest
import GlobalPayments_iOS_SDK

class GpApiReportingMonthlyFeesTests: XCTestCase {

    private let startDate = Date().addYears(-1).addDays(1)

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc",
            appKey: "DYcEE2GpSzblo0ib"
        ))
    }

    func test_report_find_monthly_fees_paged() throws {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Monthly Fees Paged")
        let reportingService = ReportingService.findMonthlyFeesPaged(page: 1, pageSize: 10)
        var monthlyFeeSummaryList: [MonthlyFeeSummary]?
        var monthlyFeeTotalRecordCount: Int?
        var monthlyFeeActionType: String?
        var monthlyFeeError: Error?

        // WHEN
        reportingService
            .orderBy(monthlyFeeOrderBy: .timeCreated, .descending)
            .where(.startDate, startDate)
            .execute {
                monthlyFeeSummaryList = $0?.results
                monthlyFeeTotalRecordCount = $0?.totalRecordCount
                monthlyFeeActionType = $0?.action?.type
                monthlyFeeError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 20.0)
        try skipIfMonthlyFeesUnavailable(monthlyFeeError)
        XCTAssertNil(monthlyFeeError)
        XCTAssertNotNil(monthlyFeeSummaryList)
        XCTAssertEqual(monthlyFeeActionType, "MONTHLY_FEES_LIST")
        XCTAssertEqual(monthlyFeeSummaryList?.count, monthlyFeeTotalRecordCount)
        for monthlyFee in monthlyFeeSummaryList ?? [] {
            XCTAssertNotNil(monthlyFee.timeCreated)
            XCTAssertNotNil(monthlyFee.status)
            XCTAssertNotNil(monthlyFee.currency)
            XCTAssertNotNil(monthlyFee.amount)
        }
    }

    func test_report_find_monthly_fees_order_by_time_created() throws {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Monthly Fees Order By Time Created")
        let reportingService = ReportingService.findMonthlyFeesPaged(page: 1, pageSize: 10)
        var monthlyFeeSummaryDates: [Date]?
        var expectedSortedDates: [Date]?
        var monthlyFeeError: Error?

        // WHEN
        reportingService
            .orderBy(monthlyFeeOrderBy: .timeCreated, .descending)
            .where(.startDate, startDate)
            .execute {
                monthlyFeeSummaryDates = $0?.results.compactMap { $0.timeCreated }
                expectedSortedDates = $0?.results.compactMap { $0.timeCreated }.sorted(by: >)
                monthlyFeeError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 20.0)
        try skipIfMonthlyFeesUnavailable(monthlyFeeError)
        XCTAssertNil(monthlyFeeError)
        XCTAssertNotNil(monthlyFeeSummaryDates)
        XCTAssertEqual(monthlyFeeSummaryDates, expectedSortedDates)
    }

    func test_report_find_monthly_fees_with_start_and_end_date() throws {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Monthly Fees With Start And End Date")
        let reportingService = ReportingService.findMonthlyFeesPaged(page: 1, pageSize: 10)
        let endDate = Date()
        var monthlyFeeSummaryList: [MonthlyFeeSummary]?
        var monthlyFeeError: Error?

        // WHEN
        reportingService
            .orderBy(monthlyFeeOrderBy: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .execute {
                monthlyFeeSummaryList = $0?.results
                monthlyFeeError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 20.0)
        try skipIfMonthlyFeesUnavailable(monthlyFeeError)
        XCTAssertNil(monthlyFeeError)
        XCTAssertNotNil(monthlyFeeSummaryList)
        for monthlyFee in monthlyFeeSummaryList ?? [] {
            guard let timeCreated = monthlyFee.timeCreated else {
                XCTFail("timeCreated cannot be nil")
                return
            }
            XCTAssertTrue(timeCreated >= startDate)
            XCTAssertTrue(timeCreated <= endDate)
        }
    }

    func test_report_find_monthly_fees_with_merchant_id() throws {
        guard let expectedMerchantId = try? awaitResponse(getMonthlyFeeSummary)?.system?.mid,
              !expectedMerchantId.isEmpty else {
            XCTSkip("No Monthly Fee Report is available for this sandbox account")
            return
        }

        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Monthly Fees With Merchant Id")
        let reportingService = ReportingService.findMonthlyFeesPaged(page: 1, pageSize: 10)
        var monthlyFeeSummaryList: [MonthlyFeeSummary]?
        var monthlyFeeError: Error?

        // WHEN
        reportingService
            .orderBy(monthlyFeeOrderBy: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(dataServiceCriteria: .merchantId, value: expectedMerchantId)
            .execute {
                monthlyFeeSummaryList = $0?.results
                monthlyFeeError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 20.0)
        try skipIfMonthlyFeesUnavailable(monthlyFeeError)
        XCTAssertNil(monthlyFeeError)
        XCTAssertNotNil(monthlyFeeSummaryList)
        for monthlyFee in monthlyFeeSummaryList ?? [] {
            XCTAssertEqual(monthlyFee.system?.mid, expectedMerchantId)
        }
    }

    func test_report_find_monthly_fees_with_system_hierarchy() throws {
        guard let expectedHierarchy = try? awaitResponse(getMonthlyFeeSummary)?.system?.hierarchy,
              !expectedHierarchy.isEmpty else {
            XCTSkip("No Monthly Fee Report is available for this sandbox account")
            return
        }

        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Monthly Fees With System Hierarchy")
        let reportingService = ReportingService.findMonthlyFeesPaged(page: 1, pageSize: 10)
        var monthlyFeeSummaryList: [MonthlyFeeSummary]?
        var monthlyFeeError: Error?

        // WHEN
        reportingService
            .orderBy(monthlyFeeOrderBy: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(dataServiceCriteria: .systemHierarchy, value: expectedHierarchy)
            .execute {
                monthlyFeeSummaryList = $0?.results
                monthlyFeeError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 20.0)
        try skipIfMonthlyFeesUnavailable(monthlyFeeError)
        XCTAssertNil(monthlyFeeError)
        XCTAssertNotNil(monthlyFeeSummaryList)
        for monthlyFee in monthlyFeeSummaryList ?? [] {
            XCTAssertEqual(monthlyFee.system?.hierarchy, expectedHierarchy)
        }
    }

    func test_report_find_monthly_fees_paging() throws {
        // GIVEN
        let firstPageExpectation = expectation(description: "Report Find Monthly Fees First Page")
        var firstPageIds: [String]?
        var firstPageError: Error?

        // WHEN
        let reportingService = ReportingService.findMonthlyFeesPaged(page: 1, pageSize: 10)
        reportingService
            .orderBy(monthlyFeeOrderBy: .timeCreated, .descending)
            .where(.startDate, startDate)
            .execute {
                firstPageIds = $0?.results.compactMap { $0.timeCreated?.description }
                firstPageError = $1
                firstPageExpectation.fulfill()
            }

        // THEN
        wait(for: [firstPageExpectation], timeout: 20.0)
        try skipIfMonthlyFeesUnavailable(firstPageError)
        XCTAssertNil(firstPageError)
        XCTAssertNotNil(firstPageIds)
    }

    /// The sandbox account must be configured with the Monthly Fee Report feature.
    /// When it is not, the gateway rejects the request before returning any data.
    private func skipIfMonthlyFeesUnavailable(_ error: Error?) throws {
        guard let error = error as? GatewayException else { return }

        let unavailableCodes = ["MANDATORY_DATA_MISSING", "INVALID_REQUEST_DATA"]
        guard unavailableCodes.contains(error.responseCode ?? "") else { return }

        throw XCTSkip("Monthly Fee Report is not enabled for this sandbox account")
    }

    // MARK: - Utils

    private func getMonthlyFeeSummary(_ completion: @escaping ((MonthlyFeeSummary?) -> Void)) {
        let reportingService = ReportingService.findMonthlyFeesPaged(page: 1, pageSize: 10)
        reportingService
            .orderBy(monthlyFeeOrderBy: .timeCreated, .descending)
            .where(.startDate, startDate)
            .execute { pagedResult, _ in
                let results = pagedResult?.results.filter {
                    $0.timeCreated != nil && !$0.currency.isNilOrEmpty
                }

                completion(results?.first)
            }
    }
}