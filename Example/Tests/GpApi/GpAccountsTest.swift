import XCTest
import GlobalPayments_iOS_SDK

final class GpAccountsTest: XCTestCase {
    
    private static let FMA_APP_ID = "A1feRdMmEB6m0Y1aQ65H0bDi9ZeAEB2t"
    private static let FMA_APP_KEY = "5jPt1OpB6LLitgi7"
    private static let FMA_CONFIG = "FMA_CONFIG"
    private static let fmaMerchantId = "MER_5096d6b88b0b49019c870392bd98ddac"
    private static let fmaAccountId = "FMA_a78b841dfbd14803b3a31e4e0c514c72"
    private static let accountId = "MER_98f60f1a397c4dd7b7167bda61520292"
    
    private static let EDIT_APP_ID = "Srv0pDTqjySql8l2Wyt3SIOb8f0DxZoghdnqB8oySBIvPcQx"
    private static let EDIT_APP_KEY = "s5S8nF9puxvAWdEAWCRwSVtkKYLABC0k5RpqdIZo64aAIGnw7csBGA3zmODFQWsi"
    private static let EDIT_CONFIG = "EDIT_CONFIG"
    private static let editMerchantId = "MER_6d260d0f648b4dd5a6b06949486d3948"
    
    override class func setUp() {
        super.setUp()
        
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "hkjrcsGDhWiDt8GEhoDMKy3pzFz5R0Bo",
            appKey: "cQOKHoAAvNIcEN8s",
            channel: .cardNotPresent
        ))
        
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: FMA_APP_ID,
            appKey: FMA_APP_KEY,
            channel: .cardNotPresent
        ), configName: FMA_CONFIG)
        
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: EDIT_APP_ID,
            appKey: EDIT_APP_KEY,
            channel: .cardNotPresent
        ), configName: EDIT_CONFIG)
    }
    
    override func setUp() {
        super.setUp()
    }
    
    private func getFirstAccountId() -> String? {
        let accountExpectation = expectation(description: "Get First Account Expectation")
        var firstAccountId: String?
        
        ReportingService.findAccounts(1, pageSize: 10)
            .execute { result, _ in
                firstAccountId = result?.results.first?.id
                accountExpectation.fulfill()
            }
        
        wait(for: [accountExpectation], timeout: 5.0)
        return firstAccountId
    }
    
    private func getEditableAccountId() -> String? {
        let accountExpectation = expectation(description: "Get Editable Account Expectation")
        var editableAccountId: String?
        
        ReportingService.findAccounts(1, pageSize: 10)
            .withMerchantId(Self.editMerchantId)
            .execute(configName: Self.EDIT_CONFIG) { result, _ in
                editableAccountId = result?.results.first?.id
                accountExpectation.fulfill()
            }
        
        wait(for: [accountExpectation], timeout: 5.0)
        return editableAccountId
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
        
        let account = accountsSummaryResult?.results.first
        XCTAssertNotNil(account?.id)
        XCTAssertNotNil(account?.type)
        XCTAssertNotNil(account?.status)
        XCTAssertNotNil(account?.permissions)
    }
    
    public func test_get_accounts_with_id_filter() {
        // GIVEN
        let expectationSearch = expectation(description: "Get Accounts With Id Filter Expectation")
        var accountsSummaryResult: PagedResult<AccountSummary>?
        var accountsSummaryError: Error?
        
        // WHEN
        ReportingService.findAccounts(1, pageSize: 10)
            .withId(Self.accountId)
            .execute {
                accountsSummaryResult = $0
                accountsSummaryError = $1
                expectationSearch.fulfill()
            }
        
        // THEN
        wait(for: [expectationSearch], timeout: 5.0)
        XCTAssertNil(accountsSummaryError)
        XCTAssertNotNil(accountsSummaryResult)
        accountsSummaryResult?.results.forEach { XCTAssertEqual(Self.accountId, $0.id) }
    }
    
    public func test_get_accounts_with_name_filter() {
        // GIVEN
        let expectationSearch = expectation(description: "Get Accounts With Name Filter Expectation")
        var accountsSummaryResult: PagedResult<AccountSummary>?
        var accountsSummaryError: Error?
        
        // WHEN
        ReportingService.findAccounts(1, pageSize: 10)
            .withName("Test Account")
            .execute {
                accountsSummaryResult = $0
                accountsSummaryError = $1
                expectationSearch.fulfill()
            }
        
        // THEN
        wait(for: [expectationSearch], timeout: 5.0)
        XCTAssertNil(accountsSummaryError)
        XCTAssertNotNil(accountsSummaryResult)
    }
    
    public func test_get_account_by_id() {
        // GIVEN
        guard let accountId = getFirstAccountId() else {
            return XCTFail("No account available in this sandbox tenant to run the test against")
        }
        let accountExpectation = expectation(description: "Get Account Id Expectation")
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
        XCTAssertNotNil(accountResponse?.type)
        XCTAssertNotNil(accountResponse?.status)
        XCTAssertNotNil(accountResponse?.permissions)
    }
    
    public func test_get_account_by_id_wrong_id() {
        // GIVEN
        let accountExpectation = expectation(description: "Get Account Wrong Id Expectation")
        var accountResponse: AccountSummary?
        var accountError: GatewayException?
        
        // WHEN
        PayFacService.getAccountById(UUID().uuidString)
            .execute {
                accountResponse = $0
                accountError = $1 as? GatewayException
                accountExpectation.fulfill()
            }
        
        // THEN
        wait(for: [accountExpectation], timeout: 5.0)
        XCTAssertNil(accountResponse)
        XCTAssertNotNil(accountError)
    }
    
    public func test_edit_account_capabilities() throws {
        // GIVEN
        guard let accountId = getEditableAccountId() else {
            throw XCTSkip("No account available under merchant \(Self.editMerchantId) to run the test against")
        }
        let editExpectation = expectation(description: "Edit Account Capabilities Expectation")
        let editData = AccountEditData()
        editData.capabilities = [.PAY_IN_ENABLE]
        var editResponse: AccountSummary?
        var editError: Error?
        
        // WHEN
        PayFacService.editAccount(accountId)
            .withAccountEditData(editData)
            .execute(configName: Self.EDIT_CONFIG) {
                editResponse = $0
                editError = $1
                editExpectation.fulfill()
            }
        
        // THEN
        wait(for: [editExpectation], timeout: 5.0)
        XCTAssertNil(editError)
        XCTAssertNotNil(editResponse)
        XCTAssertEqual(accountId, editResponse?.id)
    }
    
    public func test_edit_account_status_change_reason() throws {
        // GIVEN
        guard let accountId = getEditableAccountId() else {
            throw XCTSkip("No account available under merchant \(Self.editMerchantId) to run the test against")
        }
        let editExpectation = expectation(description: "Edit Account Status Change Reason Expectation")
        let editData = AccountEditData()
        editData.statusChangeReason = .ACTIVE
        var editResponse: AccountSummary?
        var editError: Error?
        
        // WHEN
        PayFacService.editAccount(accountId)
            .withAccountEditData(editData)
            .execute(configName: Self.EDIT_CONFIG) {
                editResponse = $0
                editError = $1
                editExpectation.fulfill()
            }
        
        // THEN
        wait(for: [editExpectation], timeout: 5.0)
        XCTAssertNil(editError)
        XCTAssertNotNil(editResponse)
    }
    
    public func test_edit_account_wrong_id() {
        // GIVEN
        let editExpectation = expectation(description: "Edit Account Wrong Id Expectation")
        let editData = AccountEditData()
        editData.statusChangeReason = .ACTIVE
        var editResponse: AccountSummary?
        var editError: GatewayException?
        
        // WHEN
        PayFacService.editAccount(UUID().uuidString)
            .withAccountEditData(editData)
            .execute {
                editResponse = $0
                editError = $1 as? GatewayException
                editExpectation.fulfill()
            }
        
        // THEN
        wait(for: [editExpectation], timeout: 5.0)
        XCTAssertNil(editResponse)
        XCTAssertNotNil(editError)
    }
    
    public func test_get_fma_account_details() {
        // GIVEN
        let fmaExpectation = expectation(description: "Get FMA Account Details Expectation")
        var fmaResponse: AccountSummary?
        var fmaError: Error?
        
        // WHEN
        PayFacService.getFMAAccountDetails(Self.fmaAccountId, merchantId: Self.fmaMerchantId)
            .execute(configName: Self.FMA_CONFIG) {
                fmaResponse = $0
                fmaError = $1
                fmaExpectation.fulfill()
            }
        
        // THEN
        wait(for: [fmaExpectation], timeout: 5.0)
        XCTAssertNil(fmaError)
        XCTAssertNotNil(fmaResponse)
        XCTAssertEqual(Self.fmaAccountId, fmaResponse?.id)
        XCTAssertNotNil(fmaResponse?.type)
        XCTAssertNotNil(fmaResponse?.status)
        XCTAssertNotNil(fmaResponse?.permissions)
    }
    
    public func test_get_fma_account_details_wrong_merchant_id() {
        // GIVEN
        let fmaExpectation = expectation(description: "Get FMA Account Details Wrong Merchant Id Expectation")
        var fmaResponse: AccountSummary?
        var fmaError: GatewayException?
        
        // WHEN
        PayFacService.getFMAAccountDetails(Self.fmaAccountId, merchantId: "MER_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))")
            .execute(configName: Self.FMA_CONFIG) {
                fmaResponse = $0
                fmaError = $1 as? GatewayException
                fmaExpectation.fulfill()
            }
        
        // THEN
        wait(for: [fmaExpectation], timeout: 5.0)
        XCTAssertNil(fmaResponse)
        XCTAssertNotNil(fmaError)
    }
    
    public func test_get_fma_account_details_wrong_fma_id() {
        // GIVEN
        let fmaExpectation = expectation(description: "Get FMA Account Details Wrong Fma Id Expectation")
        var fmaResponse: AccountSummary?
        var fmaError: GatewayException?
        
        // WHEN
        PayFacService.getFMAAccountDetails("FMA_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))", merchantId: Self.fmaMerchantId)
            .execute(configName: Self.FMA_CONFIG) {
                fmaResponse = $0
                fmaError = $1 as? GatewayException
                fmaExpectation.fulfill()
            }
        
        // THEN
        wait(for: [fmaExpectation], timeout: 5.0)
        XCTAssertNil(fmaResponse)
        XCTAssertNotNil(fmaError)
    }
}

