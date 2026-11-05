import XCTest
import GlobalPayments_iOS_SDK

class GpApiDccBinRangesReportTests: XCTestCase {

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "hkjrcsGDhWiDt8GEhoDMKy3pzFz5R0Bo",
            appKey: "cQOKHoAAvNIcEN8s"
        ))
    }

    func test_find_dcc_bin_ranges() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var result: DccBinRangeResponse?
        var resultError: Error?

        // WHEN
        ReportingService.findDccBinRanges()
            .withAccountName("GPECOM_DCC_BIN_Download")
            .withCountry("US")
            .withMerchantCurrency("EUR")
            .execute {
                result = $0
                resultError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(resultError)
        assertDccBinRangeResponse(result)
    }

    func test_find_dcc_bin_ranges_by_account_id() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var result: DccBinRangeResponse?
        var resultError: Error?

        // WHEN
        ReportingService.findDccBinRanges()
            .withAccountId("TRA_9e0f4cf3285c40128ca083022b62f8f0")
            .withCountry("GB")
            .withMerchantCurrency("EUR")
            .execute {
                result = $0
                resultError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(resultError)
        assertDccBinRangeResponse(result)
    }

    func test_find_dcc_bin_ranges_with_last_index() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var result: DccBinRangeResponse?
        var resultError: Error?

        // WHEN
        ReportingService.findDccBinRanges()
            .withAccountName("GPECOM_DCC_BIN_Download")
            .withCountry("US")
            .withMerchantCurrency("EUR")
            .withLastIndex(5)
            .execute {
                result = $0
                resultError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(resultError)
        assertDccBinRangeResponse(result)
    }

    private func assertDccBinRangeResponse(_ response: DccBinRangeResponse?) {
        XCTAssertNotNil(response)
        XCTAssertNotNil(response?.timeCreated)
        XCTAssertNotNil(response?.isLastPage)
        XCTAssertNotNil(response?.timeRetrieved)
        XCTAssertNotNil(response?.currentIndex)
        XCTAssertNotNil(response?.currentPageSize)
        XCTAssertNotNil(response?.merchantId)
        XCTAssertNotNil(response?.merchantName)
        XCTAssertNotNil(response?.accountId)
        XCTAssertNotNil(response?.accountName)
        XCTAssertNotNil(response?.country)
        XCTAssertNotNil(response?.merchantCurrency)
        XCTAssertNotNil(response?.binRanges)
        XCTAssertFalse(response?.binRanges?.isEmpty ?? true)
        XCTAssertNotNil(response?.binRanges?.first?.lowPrefixNumber)
        XCTAssertNotNil(response?.binRanges?.first?.highPrefixNumber)
        XCTAssertNotNil(response?.binRanges?.first?.status)
        XCTAssertNotNil(response?.action?.id)
        XCTAssertEqual("DCC_BIN_RANGE_LIST", response?.action?.type)
        XCTAssertEqual("SUCCESS", response?.action?.resultCode)
        XCTAssertNotNil(response?.action?.appId)
        XCTAssertNotNil(response?.action?.appName)
    }

}
