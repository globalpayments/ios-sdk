import XCTest
import GlobalPayments_iOS_SDK

class GpApiAuthenticationTests: XCTestCase {

    func test_generate_token_manual() {
        // GIVEN
        let keyExpectation = expectation(description: "Generate Transaction Key Expectation")
        let environment = Environment.test
        let appId = "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll"
        let appKey = "QDsW1ETQKHX6Y4TA"
        var infoResult: AccessTokenInfo?
        var errorResult: Error?

        // WHEN
        GpApiService.generateTransactionKey(
            environment: environment,
            appId: appId,
            appKey: appKey) { accessTokenInfo, error in
            infoResult = accessTokenInfo
            errorResult = error
            keyExpectation.fulfill()
        }

        // THEN
        wait(for: [keyExpectation], timeout: 10.0)
        XCTAssertNil(errorResult)
        XCTAssertNotNil(infoResult)
        XCTAssertNotNil(infoResult?.token)
        XCTAssertNotNil(infoResult?.dataAccountName)
        XCTAssertNotNil(infoResult?.disputeManagementAccountName)
        XCTAssertNotNil(infoResult?.tokenizationAccountName)
        XCTAssertNotNil(infoResult?.transactionProcessingAccountName)
    }

    func test_generate_token_manual_error() {
        // GIVEN
        let keyExpectation = expectation(description: "Generate Transaction Key Expectation")
        let environment = Environment.test
        let appId = "UNKNOWN"
        let appKey = "UNKNOWN"
        var infoResult: AccessTokenInfo?
        var errorResult: GatewayException?

        // WHEN
        GpApiService.generateTransactionKey(
            environment: environment,
            appId: appId,
            appKey: appKey) { accessTokenInfo, error in
            infoResult = accessTokenInfo
            if let resultError = error as? GatewayException {
                errorResult = resultError
            }
            keyExpectation.fulfill()
        }

        // THEN
        wait(for: [keyExpectation], timeout: 10.0)
        XCTAssertNil(infoResult)
        XCTAssertNotNil(errorResult)
        XCTAssertEqual(errorResult?.responseCode, "ACTION_NOT_AUTHORIZED")
        XCTAssertEqual(errorResult?.responseMessage, "40004")
    }
}
