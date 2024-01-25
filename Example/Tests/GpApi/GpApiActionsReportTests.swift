import XCTest
import GlobalPayments_iOS_SDK

class GpApiActionsReportTests: XCTestCase {

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc",
            appKey: "DYcEE2GpSzblo0ib"
        ))
    }

    func test_report_action_detail() {
        guard let actionId = try? awaitResponse(getActionSummary)?.id else {
            XCTFail("actionId cannot be nil")
            return
        }
        
        print(actionId)

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.actionDetail(actionId: actionId)
        var actionSummaryResult: ActionSummary?
        var actionSummaryError: Error?

        // WHEN
        reportingService.execute {
            actionSummaryResult = $0
            actionSummaryError = $1
            executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResult)
        XCTAssertEqual(actionSummaryResult?.id, actionId)
    }

    func test_report_action_detail_with_random_id() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let actionId = "ACT_\(UUID().uuidString)"
        let reportingService = ReportingService.actionDetail(actionId: actionId)
        var actionSummaryResult: ActionSummary?
        var actionSummaryError: GatewayException?

        // WHEN
        reportingService.execute {
            actionSummaryResult = $0
            if let error = $1 as? GatewayException {
                actionSummaryError = error
            }
            executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryResult)
        XCTAssertNotNil(actionSummaryError)
        XCTAssertEqual(actionSummaryError?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(actionSummaryError?.responseMessage, "40118")
        if let message = actionSummaryError?.message {
            XCTAssertEqual(message, "Status Code: 404 - Actions \(actionId) not found at this /ucp/actions/\(actionId)")
        } else {
            XCTFail("actionSummaryError?.message cannot be nil")
        }
    }

    func test_report_find_actions_paged_by_id() {
        guard let actionId = try? awaitResponse(getActionSummary)?.id else {
            XCTFail("actionId cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.actionId, actionId)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        actionSummaryResults?.forEach {
            XCTAssertEqual($0.id, actionId)
        }
    }

    func test_report_find_actions_paged_by_random_id() {
        // GIVEN
        let actionId = UUID().uuidString
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.actionId, actionId)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, true)
    }

    func test_report_find_actions_paged_by_type() {
        guard let actionType = try? awaitResponse(getActionSummary)?.type else {
            XCTFail("actionType cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.actionType, actionType)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        actionSummaryResults?.forEach {
            XCTAssertEqual($0.type, actionType)
        }
    }

    func test_report_find_actions_paged_by_random_type() {
        // GIVEN
        let actionType = UUID().uuidString
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.actionType, actionType)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, true)
    }

    func test_report_find_actions_paged_by_resource() {
        guard let actionResource = try? awaitResponse(getActionSummary)?.resource else {
            XCTFail("actionType cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.resource, actionResource)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        actionSummaryResults?.forEach {
            XCTAssertEqual($0.resource, actionResource)
        }
    }

    func test_report_find_actions_paged_by_status() {
        guard let actionResourceStatus = try? awaitResponse(getActionSummary)?.resourceStatus else {
            XCTFail("actionResourceStatus cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.resourceStatus, actionResourceStatus)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        actionSummaryResults?.forEach {
            XCTAssertEqual($0.resourceStatus, actionResourceStatus)
        }
    }

    func test_report_find_actions_paged_by_resource_id() {
        guard let actionResourceId = try? awaitResponse(getActionSummary)?.resourceId else {
            XCTFail("actionResourceId cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.resourceId, actionResourceId)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        actionSummaryResults?.forEach {
            XCTAssertEqual($0.resourceId, actionResourceId)
        }
    }

    func test_report_find_actions_paged_by_random_resource_id() {
        // GIVEN
        let actionResourceId = UUID().uuidString
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.resourceId, actionResourceId)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, true)
    }

    func test_report_find_actions_paged_by_start_date_and_end_date() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 5)
        let startDate = Date().addDays(-40)
        let startDateOfStartDay = Date().addDays(-40).startDayTime()
        let endDate = Date().addDays(-10)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        
        if let results = actionSummaryResults{
            for actionSummary in results {
                guard let timeCreated = actionSummary.timeCreated else {
                    continue
                }
                XCTAssertTrue(timeCreated.format() >= startDateOfStartDay.format())
                XCTAssertTrue(timeCreated.format() <= endDate.format())
            }
        }
    }

    func test_report_find_actions_paged_by_merchant_name() {
        guard let actionMerchantName = try? awaitResponse(getActionSummary)?.merchantName else {
            XCTFail("actionMerchantName cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.merchantName, actionMerchantName)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        actionSummaryResults?.forEach {
            XCTAssertEqual($0.merchantName, actionMerchantName)
        }
    }

    func test_report_find_actions_paged_by_random_merchant_name() {
        // GIVEN
        let actionMerchantName = UUID().uuidString
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: GatewayException?

        // WHEN
        reportingService
            .where(.merchantName, actionMerchantName)
            .execute {
                actionSummaryResults = $0?.results
                if let error = $1 as? GatewayException {
                    actionSummaryError = error
                }
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryResults)
        XCTAssertNotNil(actionSummaryError)
        XCTAssertEqual(actionSummaryError?.responseCode, "ACTION_NOT_AUTHORIZED")
        XCTAssertEqual(actionSummaryError?.responseMessage, "40003")
    }

    func test_report_find_actions_paged_by_account_name() {
        guard let actionAccountName = try? awaitResponse(getActionSummary)?.accountName else {
            XCTFail("actionAccountName cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.accountName, actionAccountName)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        actionSummaryResults?.forEach {
            XCTAssertEqual($0.accountName, actionAccountName)
        }
    }

    func test_report_find_actions_paged_by_app_name() {
        guard let actionAppName = try? awaitResponse(getActionSummary)?.appName else {
            XCTFail("actionAppName cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.appName, actionAppName)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        actionSummaryResults?.forEach {
            XCTAssertEqual($0.appName, actionAppName)
        }
    }

    func test_report_find_actions_paged_by_version() {
        guard let actionVersion = try? awaitResponse(getActionSummary)?.version else {
            XCTFail("actionVersion cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.version, actionVersion)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        actionSummaryResults?.forEach {
            XCTAssertEqual($0.version, actionVersion)
        }
    }

    func test_report_find_actions_paged_by_wrong_version() {
        // GIVEN
        let actionVersion = "2020-05-10"
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.version, actionVersion)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, true)
    }

    func test_report_find_actions_paged_by_response_code() {
        guard let actionResponseCode = try? awaitResponse(getActionSummary)?.responseCode else {
            XCTFail("actionResponseCode cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.responseCode, actionResponseCode)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        actionSummaryResults?.forEach {
            XCTAssertEqual($0.responseCode, actionResponseCode)
        }
    }

    func test_report_find_actions_paged_by_http_response_code() {
        guard let actionHttpResponseCode = try? awaitResponse(getActionSummary)?.httpResponseCode else {
            XCTFail("actionHttpResponseCode cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.httpResponseCode, actionHttpResponseCode)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        actionSummaryResults?.forEach {
            XCTAssertEqual($0.httpResponseCode, actionHttpResponseCode)
        }
    }

    func test_report_find_actions_paged_by_502_http_response_code() {
        // GIVEN
        let actionHttpResponseCode = "502"
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.httpResponseCode, actionHttpResponseCode)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        actionSummaryResults?.forEach {
            XCTAssertEqual($0.httpResponseCode, actionHttpResponseCode)
        }
    }

    func test_report_find_actions_paged_by_multiple_filters() {
        // GIVEN
        let resource: String = "TRANSACTIONS"
        let actionType: String = "AUTHORIZE"
        let resourceStatus: String = "DECLINED"
        let startDate: Date = Date().addMonths(-3)
        let endDate: Date = Date().addDays(-3)
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        var actionSummaryResults: [ActionSummary]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .where(.resource, resource)
            .and(searchCriteria: .actionType, value: actionType)
            .and(searchCriteria: .resourceStatus, value: resourceStatus)
            .and(searchCriteria: .startDate, value: startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .execute {
                actionSummaryResults = $0?.results
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        for actionSummary in actionSummaryResults! {
            XCTAssertEqual(actionSummary.resource, resource)
            XCTAssertEqual(actionSummary.type, actionType)
            XCTAssertEqual(actionSummary.resourceStatus, resourceStatus)
            guard let timeCreated = actionSummary.timeCreated else { continue }
            XCTAssertTrue(timeCreated.format() >= startDate.format())
            XCTAssertTrue(timeCreated.format() <= endDate.format())
        }
    }

    func test_report_find_actions_paged_order_by_time_created_ascending() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 20)
        var actionSummaryResults: [Date]?
        var sortedActionSummaryResults: [Date]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(actionOrderBy: .timeCreated, .ascending)
            .execute {
                actionSummaryResults = $0?.results.compactMap { $0.timeCreated }
                sortedActionSummaryResults = $0?.results.compactMap { $0.timeCreated }.sorted(by: <)
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertNotNil(sortedActionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        XCTAssertEqual(sortedActionSummaryResults?.isEmpty, false)
        XCTAssertEqual(actionSummaryResults, sortedActionSummaryResults)
    }

    func test_report_find_actions_paged_order_by_time_created_descending() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 20)
        var actionSummaryResults: [Date]?
        var sortedActionSummaryResults: [Date]?
        var actionSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(actionOrderBy: .timeCreated, .descending)
            .execute {
                actionSummaryResults = $0?.results.compactMap { $0.timeCreated }
                sortedActionSummaryResults = $0?.results.compactMap { $0.timeCreated }.sorted(by: >)
                actionSummaryError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(actionSummaryError)
        XCTAssertNotNil(actionSummaryResults)
        XCTAssertNotNil(sortedActionSummaryResults)
        XCTAssertEqual(actionSummaryResults?.isEmpty, false)
        XCTAssertEqual(sortedActionSummaryResults?.isEmpty, false)
        XCTAssertEqual(actionSummaryResults, sortedActionSummaryResults)
    }

    private func getActionSummary(_ completion: @escaping ((ActionSummary?) -> Void)) {
        let reportingService = ReportingService.findActionsPaged(page: 1, pageSize: 100)
        reportingService
            .orderBy(actionOrderBy: .timeCreated, .descending)
            .where(.startDate, Date().addYears(-2).addDays(1))
            .execute { pagedResult, _ in
                let results = pagedResult?.results.filter {
                    !$0.id.isNilOrEmpty &&
                        !$0.type.isNilOrEmpty &&
                        !$0.resource.isNilOrEmpty &&
                        !$0.resourceStatus.isNilOrEmpty &&
                        !$0.resourceId.isNilOrEmpty &&
                        !$0.merchantName.isNilOrEmpty &&
                        !$0.accountName.isNilOrEmpty &&
                        !$0.appName.isNilOrEmpty &&
                        !$0.version.isNilOrEmpty &&
                        !$0.responseCode.isNilOrEmpty &&
                        !$0.httpResponseCode.isNilOrEmpty
                }

                completion(results?.first)
            }
    }
}
