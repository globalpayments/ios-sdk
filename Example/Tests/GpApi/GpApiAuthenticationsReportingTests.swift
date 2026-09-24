import XCTest
import GlobalPayments_iOS_SDK

class GpApiAuthenticationsReportingTests: XCTestCase {

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc",
            appKey: "DYcEE2GpSzblo0ib"
        ))
    }

    func test_report_find_authentications_paged() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findAuthenticationsPaged(page: 1, pageSize: 10)
        var authenticationSummaryResult: PagedResult<AuthenticationSummary>?
        var authenticationSummaryError: Error?

        // WHEN
        reportingService.execute {
            authenticationSummaryResult = $0
            authenticationSummaryError = $1
            executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        if handlePermissionErrorIfPresent(authenticationSummaryError) {
            XCTAssertNil(authenticationSummaryResult)
            return
        }
        XCTAssertNil(authenticationSummaryError)
        XCTAssertNotNil(authenticationSummaryResult)
    }

    func test_report_find_authentications_paged_order_by_time_created_ascending() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findAuthenticationsPaged(page: 1, pageSize: 20)
        var authenticationSummaryResults: [Date]?
        var sortedAuthenticationSummaryResults: [Date]?
        var authenticationSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(authenticationOrderBy: .timeCreated, .ascending)
            .execute {
                authenticationSummaryResults = $0?.results.compactMap { $0.timeCreated }
                sortedAuthenticationSummaryResults = $0?.results.compactMap { $0.timeCreated }.sorted(by: <)
                authenticationSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        if handlePermissionErrorIfPresent(authenticationSummaryError) {
            XCTAssertNil(authenticationSummaryResults)
            return
        }
        XCTAssertNil(authenticationSummaryError)
        XCTAssertNotNil(authenticationSummaryResults)
        XCTAssertNotNil(sortedAuthenticationSummaryResults)
        XCTAssertEqual(authenticationSummaryResults, sortedAuthenticationSummaryResults)
    }

    func test_report_find_authentications_paged_order_by_time_created_descending() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findAuthenticationsPaged(page: 1, pageSize: 20)
        var authenticationSummaryResults: [Date]?
        var sortedAuthenticationSummaryResults: [Date]?
        var authenticationSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(authenticationOrderBy: .timeCreated, .descending)
            .execute {
                authenticationSummaryResults = $0?.results.compactMap { $0.timeCreated }
                sortedAuthenticationSummaryResults = $0?.results.compactMap { $0.timeCreated }.sorted(by: >)
                authenticationSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        if handlePermissionErrorIfPresent(authenticationSummaryError) {
            XCTAssertNil(authenticationSummaryResults)
            return
        }
        XCTAssertNil(authenticationSummaryError)
        XCTAssertNotNil(authenticationSummaryResults)
        XCTAssertNotNil(sortedAuthenticationSummaryResults)
        XCTAssertEqual(authenticationSummaryResults, sortedAuthenticationSummaryResults)
    }

    func test_report_authentication_detail() {
        guard let (summary, summaryError) = try? awaitResponse(getAuthenticationSummary) else {
            XCTFail("getAuthenticationSummary did not return a response")
            return
        }

        if handlePermissionErrorIfPresent(summaryError) {
            return
        }

        guard let authenticationId = summary?.id else {
            XCTFail("authenticationId cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.authenticationDetail(authenticationId: authenticationId)
        var authenticationSummaryResult: AuthenticationSummary?
        var authenticationSummaryError: Error?

        // WHEN
        reportingService.execute {
            authenticationSummaryResult = $0
            authenticationSummaryError = $1
            executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        if handlePermissionErrorIfPresent(authenticationSummaryError) {
            XCTAssertNil(authenticationSummaryResult)
            return
        }
        XCTAssertNil(authenticationSummaryError)
        XCTAssertNotNil(authenticationSummaryResult)
        XCTAssertEqual(authenticationSummaryResult?.id, authenticationId)
    }

    func test_report_authentication_detail_with_random_id() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let authenticationId = UUID().uuidString
        let reportingService = ReportingService.authenticationDetail(authenticationId: authenticationId)
        var authenticationSummaryResult: AuthenticationSummary?
        var authenticationSummaryError: Error?

        // WHEN
        reportingService.execute {
            authenticationSummaryResult = $0
            authenticationSummaryError = $1
            executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(authenticationSummaryResult)
        XCTAssertNotNil(authenticationSummaryError)
    }

    private func getAuthenticationSummary(_ completion: @escaping ((AuthenticationSummary?, Error?)) -> Void) {
        let reportingService = ReportingService.findAuthenticationsPaged(page: 1, pageSize: 100)
        reportingService
            .orderBy(authenticationOrderBy: .timeCreated, .descending)
            .execute { pagedResult, error in
                completion((pagedResult?.results.first, error))
            }
    }

    /// The sandbox merchant/app credentials used by these tests are not always provisioned
    /// with the "Authentications" reporting permission. In that case the gateway returns a
    /// 403 `ACTION_NOT_AUTHORIZED` (40212) error. Rather than failing the whole suite on an
    /// environment/configuration issue, tolerate that specific error and let the caller skip
    /// the rest of the assertions.
    /// - Returns: `true` if the error was the expected permission error and was handled.
    @discardableResult
    private func handlePermissionErrorIfPresent(_ error: Error?) -> Bool {
        guard let error = error else { return false }

        guard let gatewayError = error as? GatewayException else {
            XCTFail("Unexpected error: \(error.localizedDescription)")
            return true
        }

        guard gatewayError.responseCode == "ACTION_NOT_AUTHORIZED" else {
            XCTFail("Unexpected gateway error: \(gatewayError.responseCode ?? "nil") - \(gatewayError.message ?? "")")
            return true
        }

        XCTAssertEqual(gatewayError.responseMessage, "40212")
        return true
    }
}
