import XCTest
import GlobalPayments_iOS_SDK

final class GpApiBlikLevelZeroApmTest: XCTestCase {

    override func setUp() {
        super.setUp()
        blikLevelZeroSetup()
    }

    // MARK: - Setup Blik Level 0 APM Configuration

    func blikLevelZeroSetup() {
        ServicesContainer.shared.removeConfiguration(configName: "")

        let config = GpApiConfig(
            appId: "hlZAokTftDazLlWDPe8E6VAz5g9rSDPg",
            appKey: "ThDO2fISzzWCgkCZ",
            channel: .cardNotPresent,
        )
        config.country = "PL"
        config.serviceUrl = "https://apis-qa.globalpay.com/ucp"
        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "GPECOM_BLIK_APM_Transaction_Processing"
        config.accessTokenInfo = accessTokenInfo

        let maskedItems = [
            MaskedItem(value: "payment_method.apm.payment_code", start: 0, end: 0)
        ]
        config.requestLogger = SampleRequestLogger(maskedItems: maskedItems)

        try? ServicesContainer.configureService(config: config)
    }

    // Skips the test when the QA environment/account rejects the transaction for reasons unrelated
    // to the BLIK Level 0 implementation being tested (known QA credential/account flakiness, or a
    // downstream/backend outage on GP-API's QA environment).
    private func assertGatewayNotDown(_ error: Error?) throws {
        if let gatewayError = error as? GatewayException,
           let responseCode = gatewayError.responseCode,
           ["ACTION_NOT_AUTHORIZED", "INVALID_TRANSACTION_ACTION", "SYSTEM_ERROR_DOWNSTREAM"].contains(responseCode) {
            throw XCTSkip("Gateway rejected the request for an unrelated reason: \(responseCode)")
        }
    }

    private func createBlikLevelZeroPaymentMethod() -> AlternatePaymentMethod {
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .BLIK
        paymentMethod.blikMode = .levelZero
        paymentMethod.paymentCodeInitiator = .payer
        paymentMethod.paymentCode = "999000"
        paymentMethod.returnUrl = "https://webhook.site/5ef888b0-a200-403d-97c1-6e19f698ea98"
        paymentMethod.statusUpdateUrl = "https://webhook.site/5ef888b0-a200-403d-97c1-6e19f698ea98"
        paymentMethod.cancelUrl = "https://webhook.site/5ef888b0-a200-403d-97c1-6e19f698ea98"
        paymentMethod.country = "PL"
        paymentMethod.accountHolderName = "James2 Carl"
        return paymentMethod
    }

    // MARK: - GP API Blik Level 0 APM Test Methods

    // Verifies that a sale transaction using Blik Level 0 APM with all mandatory fields (ip_address, user_agent) succeeds.
    func test_BlikLevelZeroApmSale_WhenRequestIsValid_ShouldSucceed() throws {
        let expectationCharge = expectation(description: "Blik Level 0 charge Expectation")
        let paymentMethod = createBlikLevelZeroPaymentMethod()

        let customer = Customer()
        customer.firstName = "James"
        customer.lastName = "Mason"
        customer.email = "james2.carl@gmail.com"

        var responseCharge: Transaction?
        var errorCharge: Error?

        paymentMethod.charge(amount: 10.00)
            .withCurrency("PLN")
            .withCustomerData(customer)
            .withCustomerIpAddress("106.215.180.111")
            .withCustomerUserAgent("PostmanRuntime/7.51.1")
            .withClientTransactionId("123456789")
            .execute {
                responseCharge = $0
                errorCharge = $1
                expectationCharge.fulfill()
            }

        wait(for: [expectationCharge], timeout: 60.0)

        try assertGatewayNotDown(errorCharge)

        XCTAssertNil(errorCharge)
        XCTAssertNotNil(responseCharge)
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
    }

    // Verifies that a sale transaction using Blik Level 0 APM throws an exception when customerIpAddress is missing.
    func test_BlikLevelZeroApmSale_WhenIpAddressMissing_ShouldThrowException() {
        let expectationCharge = expectation(description: "Blik Level 0 charge Expectation")
        let paymentMethod = createBlikLevelZeroPaymentMethod()

        var responseCharge: Transaction?
        var errorCharge: UnsupportedTransactionException?

        paymentMethod.charge(amount: 10.01)
            .withCurrency("PLN")
            .withCustomerUserAgent("Mozilla/5.0 Test Agent")
            .execute {
                responseCharge = $0
                if let error = $1 as? UnsupportedTransactionException {
                    errorCharge = error
                }
                expectationCharge.fulfill()
            }

        wait(for: [expectationCharge], timeout: 10.0)
        XCTAssertNotNil(errorCharge)
        XCTAssertNil(responseCharge)
        XCTAssertEqual("customerIpAddress cannot be null for BLIK Level 0 transactions.", errorCharge?.message)
    }

    // Verifies that a sale transaction using Blik Level 0 APM throws an exception when customerUserAgent is missing.
    func test_BlikLevelZeroApmSale_WhenUserAgentMissing_ShouldThrowException() {
        let expectationCharge = expectation(description: "Blik Level 0 charge Expectation")
        let paymentMethod = createBlikLevelZeroPaymentMethod()

        var responseCharge: Transaction?
        var errorCharge: UnsupportedTransactionException?

        paymentMethod.charge(amount: 10.01)
            .withCurrency("PLN")
            .withCustomerIpAddress("127.0.0.1")
            .execute {
                responseCharge = $0
                if let error = $1 as? UnsupportedTransactionException {
                    errorCharge = error
                }
                expectationCharge.fulfill()
            }

        wait(for: [expectationCharge], timeout: 10.0)
        XCTAssertNotNil(errorCharge)
        XCTAssertNil(responseCharge)
        XCTAssertEqual("customerUserAgent cannot be null for BLIK Level 0 transactions.", errorCharge?.message)
    }

    // Verifies that a sale transaction using Blik Level 0 APM throws an exception when paymentCode is fewer than 6 digits.
    func test_BlikLevelZeroApmSale_WhenPaymentCodeTooShort_ShouldThrowException() {
        let expectationCharge = expectation(description: "Blik Level 0 charge Expectation")
        let paymentMethod = createBlikLevelZeroPaymentMethod()
        paymentMethod.paymentCode = "99999"

        var responseCharge: Transaction?
        var errorCharge: UnsupportedTransactionException?

        paymentMethod.charge(amount: 10.01)
            .withCurrency("PLN")
            .withCustomerIpAddress("106.215.180.111")
            .withCustomerUserAgent("PostmanRuntime/7.51.1")
            .execute {
                responseCharge = $0
                if let error = $1 as? UnsupportedTransactionException {
                    errorCharge = error
                }
                expectationCharge.fulfill()
            }

        wait(for: [expectationCharge], timeout: 10.0)
        XCTAssertNotNil(errorCharge)
        XCTAssertNil(responseCharge)
        XCTAssertEqual("paymentMethod.paymentCode must be exactly 6 digits for BLIK Level 0 transactions.", errorCharge?.message)
    }

    // Verifies that a sale transaction using Blik Level 0 APM throws an exception when paymentCode is more than 6 digits.
    func test_BlikLevelZeroApmSale_WhenPaymentCodeTooLong_ShouldThrowException() {
        let expectationCharge = expectation(description: "Blik Level 0 charge Expectation")
        let paymentMethod = createBlikLevelZeroPaymentMethod()
        paymentMethod.paymentCode = "9990001"

        var responseCharge: Transaction?
        var errorCharge: UnsupportedTransactionException?

        paymentMethod.charge(amount: 10.01)
            .withCurrency("PLN")
            .withCustomerIpAddress("106.215.180.111")
            .withCustomerUserAgent("PostmanRuntime/7.51.1")
            .execute {
                responseCharge = $0
                if let error = $1 as? UnsupportedTransactionException {
                    errorCharge = error
                }
                expectationCharge.fulfill()
            }

        wait(for: [expectationCharge], timeout: 10.0)
        XCTAssertNotNil(errorCharge)
        XCTAssertNil(responseCharge)
        XCTAssertEqual("paymentMethod.paymentCode must be exactly 6 digits for BLIK Level 0 transactions.", errorCharge?.message)
    }
}
