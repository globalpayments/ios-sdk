import XCTest
import GlobalPayments_iOS_SDK

final class GpAccountsTest: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "A1feRdMmEB6m0Y1aQ65H0bDi9ZeAEB2t",
            appKey: "5jPt1OpB6LLitgi7",
            channel: .cardNotPresent
        ))
    }
    
    override func setUp() {
        super.setUp()
    }
    
    public func test_get_accounts() {
        // GIVEN
        let expectationSearch = expectation(description: "Get Accounts Expectation")
        let userReportService = ReportingService.findAccounts(1, pageSize: 10)
        var accountsSummaryResult: PagedResult<AccountSummary>?
        var accountsSummaryError: Error?
        
        // WHEN
        userReportService.execute {
            accountsSummaryResult = $0
            accountsSummaryError = $1
            expectationSearch.fulfill()
        }
        
        // THEN
        wait(for: [expectationSearch], timeout: 5.0)
        XCTAssertNil(accountsSummaryError)
        XCTAssertNotNil(accountsSummaryResult)
        XCTAssertTrue(accountsSummaryResult?.totalRecordCount ?? 0 > 0)
        XCTAssertTrue(accountsSummaryResult?.results.count ?? 0 <= 10)
    }
    
    public func test_get_account_by_id() {
        // GIVEN
        let accountExpectation = expectation(description: "Get Account Id Expectation")
        let accountId = "MER_98f60f1a397c4dd7b7167bda61520292"
        var accountResponse: AccountSummary?
        var accountError: Error?
        
        // WHEN
        PayFacService.getAccountById(accountId)
            .execute {
                accountResponse = $0
                accountError = $1
                accountExpectation.fulfill()
            }
        
        // THEN
        wait(for: [accountExpectation], timeout: 5.0)
        XCTAssertNil(accountError)
        XCTAssertNotNil(accountResponse)
        XCTAssertEqual(accountId, accountResponse?.id)
    }
}
