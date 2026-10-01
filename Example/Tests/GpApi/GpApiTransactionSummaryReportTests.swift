import XCTest
import GlobalPayments_iOS_SDK

class GpApiTransactionSummaryReportTests: XCTestCase {

    // GP-API rejects a from_time_created that is more than 31 days old.
    private let startDate = Date().addDays(-30)
    private let endDate = Date()

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "4gPqnGBkppGYvoE5UX9EWQlotTxGUDbs",
            appKey: "FQyJA5VuEQfcji2M"
        ))
    }

    // MARK: - Integration

    /// `/reports` must be enabled on the merchant configuration; without it GP-API answers 403 ACTION_NOT_AUTHORIZED.
    private func skipIfNotEntitled(_ error: Error?) throws {
        guard let exception = error as? GatewayException,
              exception.responseCode == "ACTION_NOT_AUTHORIZED" else { return }
        throw XCTSkip("Transaction Summary Report is not enabled for the test credentials")
    }

    func test_transaction_summary_report() throws {
        // GIVEN
        let reportExpectation = expectation(description: "Transaction Summary Report")
        var pagedResult: PagedResult<TransactionSummaryReport>?
        var reportError: Error?

        // WHEN
        ReportingService
            .transactionSummaryReport()
            .execute {
                pagedResult = $0
                reportError = $1
                reportExpectation.fulfill()
            }

        // THEN
        wait(for: [reportExpectation], timeout: 20.0)
        try skipIfNotEntitled(reportError)
        XCTAssertNil(reportError)
        XCTAssertNotNil(pagedResult)
        pagedResult?.results.forEach {
            XCTAssertEqual($0.type, "TRANSACTION_SUMMARY")
        }
    }

    func test_transaction_summary_report_by_payment_method_category() throws {
        // GIVEN
        let reportExpectation = expectation(description: "Transaction Summary Report By Category")
        var pagedResult: PagedResult<TransactionSummaryReport>?
        var reportError: Error?

        // WHEN
        ReportingService
            .transactionSummaryReport()
            .withPaymentMethodCategory(.card)
            .execute {
                pagedResult = $0
                reportError = $1
                reportExpectation.fulfill()
            }

        // THEN
        wait(for: [reportExpectation], timeout: 20.0)
        try skipIfNotEntitled(reportError)
        XCTAssertNil(reportError)
        XCTAssertNotNil(pagedResult)
        pagedResult?.results
            .compactMap { $0.paymentMethodBreakdown }
            .flatMap { $0 }
            .forEach { XCTAssertEqual($0.category, .card) }
    }
    
    func test_transaction_summary_report_by_payment_method_brand() throws {
        // GIVEN
        let reportExpectation = expectation(description: "Transaction Summary Report By Brand")
        let brand = "VISA"
        var pagedResult: PagedResult<TransactionSummaryReport>?
        var reportError: Error?

        // WHEN
        ReportingService
            .transactionSummaryReport()
            .withPaymentMethodCategory(.card)
            .withPaymentMethodBrand(brand)
            .execute {
                pagedResult = $0
                reportError = $1
                reportExpectation.fulfill()
            }

        // THEN
        wait(for: [reportExpectation], timeout: 20.0)
        try skipIfNotEntitled(reportError)
        XCTAssertNil(reportError)
        XCTAssertNotNil(pagedResult)
        pagedResult?.results
            .compactMap { $0.paymentMethodBreakdown }
            .flatMap { $0 }
            .forEach { XCTAssertEqual($0.brand, brand) }
    }

    // MARK: - Positive

    func test_transaction_summary_report_with_all_filters() throws {
        // GIVEN
        let reportExpectation = expectation(description: "Transaction Summary Report With All Filters")
        let brand = "VISA"
        var pagedResult: PagedResult<TransactionSummaryReport>?
        var reportError: Error?

        // WHEN
        ReportingService
            .transactionSummaryReport()
            .withPaymentMethodCategory(.card)
            .withPaymentMethodBrand(brand)
            .execute {
                pagedResult = $0
                reportError = $1
                reportExpectation.fulfill()
            }

        // THEN
        wait(for: [reportExpectation], timeout: 20.0)
        try skipIfNotEntitled(reportError)
        XCTAssertNil(reportError)
        XCTAssertNotNil(pagedResult)

        pagedResult?.results.forEach { report in
            XCTAssertEqual(report.type, "TRANSACTION_SUMMARY")
            report.paymentMethodBreakdown?.forEach {
                XCTAssertEqual($0.category, .card)
                XCTAssertEqual($0.brand, brand)
                XCTAssertNotNil($0.count)
                XCTAssertNotNil($0.amount)
            }
        }
    }

    // MARK: - Negative

    func test_transaction_summary_report_with_invalid_credentials() {
        // GIVEN
        let configName = "invalidCredentialsConfig"
        try? ServicesContainer.configureService(
            config: GpApiConfig(appId: "INVALID_APP_ID", appKey: "INVALID_APP_KEY"),
            configName: configName
        )
        let reportExpectation = expectation(description: "Transaction Summary Report Invalid Credentials")
        var pagedResult: PagedResult<TransactionSummaryReport>?
        var reportError: GatewayException?

        // WHEN
        ReportingService
            .transactionSummaryReport()
            .execute(configName: configName) {
                pagedResult = $0
                reportError = $1 as? GatewayException
                reportExpectation.fulfill()
            }

        // THEN
        wait(for: [reportExpectation], timeout: 20.0)
        XCTAssertNil(pagedResult)
        XCTAssertNotNil(reportError)
        XCTAssertEqual(reportError?.responseCode, "ACTION_NOT_AUTHORIZED")
        XCTAssertEqual(reportError?.message, "Status Code: 403 - App credentials not recognized")

        ServicesContainer.shared.removeConfiguration(configName: configName)
    }

    func test_transaction_summary_report_with_date_range_older_than_allowed() throws {
        // GIVEN
        let reportExpectation = expectation(description: "Transaction Summary Report Out Of Range Date")
        var pagedResult: PagedResult<TransactionSummaryReport>?
        var reportError: Error?

        // WHEN
        ReportingService
            .transactionSummaryReport()
            .withStartDate(Date().addYears(-1))
            .withEndDate(endDate)
            .execute {
                pagedResult = $0
                reportError = $1
                reportExpectation.fulfill()
            }

        // THEN
        wait(for: [reportExpectation], timeout: 20.0)
        try skipIfNotEntitled(reportError)
        XCTAssertNil(pagedResult)
        let gatewayError = try XCTUnwrap(reportError as? GatewayException)
        XCTAssertEqual(gatewayError.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(gatewayError.responseMessage, "40115")
    }

    func test_transaction_summary_report_with_invalid_payment_method_brand() throws {
        // GIVEN
        let reportExpectation = expectation(description: "Transaction Summary Report Invalid Brand")
        var pagedResult: PagedResult<TransactionSummaryReport>?
        var reportError: Error?

        // WHEN
        ReportingService
            .transactionSummaryReport()
            .withPaymentMethodCategory(.card)
            .withPaymentMethodBrand("INVALID_BRAND")
            .execute {
                pagedResult = $0
                reportError = $1
                reportExpectation.fulfill()
            }

        // THEN
        wait(for: [reportExpectation], timeout: 20.0)
        try skipIfNotEntitled(reportError)
        XCTAssertNil(reportError)
        XCTAssertNotNil(pagedResult)
        XCTAssertTrue(pagedResult?.results.isEmpty ?? false)
    }
}
