import XCTest
import GlobalPayments_iOS_SDK

class GpApiAuthenticationTests: XCTestCase {

    private var card: CreditCardData!

    override func setUp() {

        card = CreditCardData()
        card.number = "4263970000005262"
        card.expMonth = 5
        card.expYear = 2025
        card.cvn = "852"
    }

    override func tearDown() {
        card = nil
    }

    func test_generate_access_token_manual() {
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

    func test_generate_access_token_manual_with_correct_permissions() {
        // GIVEN
        let environment = Environment.test
        let appId = "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll"
        let appKey = "QDsW1ETQKHX6Y4TA"
        let permissions = ["PMT_POST_Create", "PMT_POST_Detokenize"]
        let generateTransactionKeyExpectation = expectation(description: "Generate Transaction Key Expectation")
        var accessTokenInfoResult: AccessTokenInfo?
        var accessTokenInfoError: Error?

        // WHEN
        GpApiService.generateTransactionKey(environment: environment, appId: appId, appKey: appKey, permissions: permissions) {
            accessTokenInfoResult = $0
            accessTokenInfoError = $1
            generateTransactionKeyExpectation.fulfill()
        }

        // THEN
        wait(for: [generateTransactionKeyExpectation], timeout: 10.0)
        XCTAssertNil(accessTokenInfoError)
        XCTAssertNotNil(accessTokenInfoResult)
        XCTAssertNotNil(accessTokenInfoResult?.token)
        XCTAssertNotNil(accessTokenInfoResult?.tokenizationAccountName)
        XCTAssertNil(accessTokenInfoResult?.dataAccountName)
        XCTAssertNil(accessTokenInfoResult?.disputeManagementAccountName)
        XCTAssertNil(accessTokenInfoResult?.transactionProcessingAccountName)
    }

    func test_generate_access_token_manual_with_incorrect_permissions() {
        // GIVEN
        let environment = Environment.test
        let appId = "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll"
        let appKey = "QDsW1ETQKHX6Y4TA"
        let permissions = ["UNKNOWN", "TEST"]
        let generateTransactionKeyExpectation = expectation(description: "Generate Transaction Key Expectation")
        var accessTokenInfoResult: AccessTokenInfo?
        var accessTokenInfoError: GatewayException?

        // WHEN
        GpApiService.generateTransactionKey(environment: environment, appId: appId, appKey: appKey, permissions: permissions) {
            accessTokenInfoResult = $0
            if let error = $1 as? GatewayException {
                accessTokenInfoError = error
            }
            generateTransactionKeyExpectation.fulfill()
        }

        // THEN
        wait(for: [generateTransactionKeyExpectation], timeout: 10.0)
        XCTAssertNil(accessTokenInfoResult)
        XCTAssertNotNil(accessTokenInfoError)
        XCTAssertEqual(accessTokenInfoError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(accessTokenInfoError?.responseMessage, "40119")
        if let message = accessTokenInfoError?.message {
            XCTAssertTrue(message.contains("Status Code: 400 - Invalid permissions"))
        } else {
            XCTFail("accessTokenInfoError message cannot be nil")
        }
    }

    func test_generate_access_token_with_specific_seconds_to_expire() {
        // GIVEN
        let gpApiConfig = GpApiConfig(
            appId: "JF2GQpeCrOivkBGsTRiqkpkdKp67Gxi0",
            appKey: "y7vALnUtFulORlTV",
            secondsToExpire: 60
        )
        try? ServicesContainer.configureService(config: gpApiConfig)
        let verifyExpectation = expectation(description: "Verify Expectation")
        var verifyTransactionResult: Transaction?
        var verifyTransactionError: Error?

        // WHEN
        card.verify()
            .withCurrency("USD")
            .execute {
                verifyTransactionResult = $0
                verifyTransactionError = $1
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(verifyTransactionError)
        XCTAssertNotNil(verifyTransactionResult)
        XCTAssertEqual(verifyTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(verifyTransactionResult?.responseMessage, "VERIFIED")
    }

    func test_generate_access_token_with_specific_interval_to_expire() {
        // GIVEN
        let gpApiConfig = GpApiConfig(
            appId: "JF2GQpeCrOivkBGsTRiqkpkdKp67Gxi0",
            appKey: "y7vALnUtFulORlTV",
            intervalToExpire: .fiveMinutes
        )
        try? ServicesContainer.configureService(config: gpApiConfig)
        let verifyExpectation = expectation(description: "Verify Expectation")
        var verifyTransactionResult: Transaction?
        var verifyTransactionError: Error?

        // WHEN
        card.verify()
            .withCurrency("USD")
            .execute {
                verifyTransactionResult = $0
                verifyTransactionError = $1
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(verifyTransactionError)
        XCTAssertNotNil(verifyTransactionResult)
        XCTAssertEqual(verifyTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(verifyTransactionResult?.responseMessage, "VERIFIED")
    }

    func test_generate_access_token_with_specific_seconds_to_expire_and_interval_to_expire() {
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
            appKey: appKey,
            secondsToExpire: 60,
            intervalToExpire: .fiveMinutes) { accessTokenInfo, error in
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

    func test_generate_access_token_wrong_app_id() {
        // GIVEN
        let keyExpectation = expectation(description: "Generate Transaction Key Expectation")
        let environment = Environment.test
        let appId = "WRONG"
        let appKey = "QDsW1ETQKHX6Y4TA"
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

    func test_generate_access_token_wrong_app_key() {
        // GIVEN
        let keyExpectation = expectation(description: "Generate Transaction Key Expectation")
        let environment = Environment.test
        let appId = "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll"
        let appKey = "WRONG"
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

    func test_generate_access_token_wrong_app_id_and_app_key() {
        // GIVEN
        let keyExpectation = expectation(description: "Generate Transaction Key Expectation")
        let environment = Environment.test
        let appId = "WRONG"
        let appKey = "WRONG"
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

    func test_generate_access_token_with_wrong_credentials() {
        // GIVEN
        let generateExpectation = expectation(description: "Generate Expectation")
        let environment = Environment.test
        let appId = "T53SFpeCrOivkBGs84FtlpkdKp32FkYl"
        let appKey = "j8rTLnUtFulOU7VL"
        var accessTokenInfoResult: AccessTokenInfo?
        var accessTokenInfoError: GatewayException?

        // WHEN
        GpApiService.generateTransactionKey(environment: environment, appId: appId, appKey: appKey) {
            accessTokenInfoResult = $0
            if let error = $1 as? GatewayException {
                accessTokenInfoError = error
            }
            generateExpectation.fulfill()
        }

        // THEN
        wait(for: [generateExpectation], timeout: 10.0)
        XCTAssertNil(accessTokenInfoResult)
        XCTAssertNotNil(accessTokenInfoError)
        XCTAssertEqual(accessTokenInfoError?.responseCode, "ACTION_NOT_AUTHORIZED")
        XCTAssertEqual(accessTokenInfoError?.responseMessage, "40004")
        if let message = accessTokenInfoError?.message {
            XCTAssertEqual(message, "Status Code: 403 - App credentials not recognized")
        } else {
            XCTFail("accessTokenInfoError? message cannot be nil")
        }
    }

    func test_use_invalid_access_token_info() {
        // GIVEN
        let accessTokenInfo = AccessTokenInfo(
            token: "token",
            dataAccountName: "dataAccountName",
            disputeManagementAccountName: "disputeManagementAccountName",
            tokenizationAccountName: "tokenizationAccountName",
            transactionProcessingAccountName: "transactionProcessingAccountName"
        )
        let gpApiConfig = GpApiConfig(appId: "", appKey: "", accessTokenInfo: accessTokenInfo)
        try? ServicesContainer.configureService(config: gpApiConfig)
        let verifyExpectation = expectation(description: "Verify Expectation")
        var transactionResult: Transaction?
        var transactionError: GatewayException?

        // WHEN
        card.verify()
            .withCurrency("USD")
            .execute {
                transactionResult = $0
                if let error = $1 as? GatewayException {
                    transactionError = error
                }
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
        XCTAssertEqual(transactionError?.responseCode, "NOT_AUTHENTICATED")
        XCTAssertEqual(transactionError?.responseMessage, "40001")
        if let message = transactionError?.message {
            XCTAssertEqual(message, "Status Code: 401 - Invalid access token")
        } else {
            XCTFail("ransactionError?.message cannot be nil")
        }
    }

    func test_use_expired_access_token_info() {
        // GIVEN
        let accessTokenInfo = AccessTokenInfo(
            token: "r1SzGAx2K9z5FNiMHkrapfRh8BC8",
            dataAccountName: "Settlement Reporting",
            disputeManagementAccountName: "Dispute Management",
            tokenizationAccountName: "Tokenization",
            transactionProcessingAccountName: "Transaction_Processing"
        )
        let gpApiConfig = GpApiConfig(appId: "", appKey: "", accessTokenInfo: accessTokenInfo)
        try? ServicesContainer.configureService(config: gpApiConfig)
        let verifyExpectation = expectation(description: "Verify Expectation")
        var transactionResult: Transaction?
        var transactionError: GatewayException?

        // WHEN
        card.verify()
            .withCurrency("USD")
            .execute {
                transactionResult = $0
                if let error = $1 as? GatewayException {
                    transactionError = error
                }
                verifyExpectation.fulfill()
            }

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
        XCTAssertEqual(transactionError?.responseCode, "NOT_AUTHENTICATED")
        XCTAssertEqual(transactionError?.responseMessage, "40001")
        if let message = transactionError?.message {
            XCTAssertEqual(message, "Status Code: 401 - Invalid access token")
        } else {
            XCTFail("ransactionError?.message cannot be nil")
        }
    }
}
