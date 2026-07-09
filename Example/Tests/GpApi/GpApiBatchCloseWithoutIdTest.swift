import XCTest
import GlobalPayments_iOS_SDK

class GpApiBatchCloseWithoutIdTest: XCTestCase {

    private var card: CreditCardData!

    private static let currency = "GBP"
    private static let amount = NSDecimalNumber(string: "13.00")

    // Account-to-app mapping is environment-bound.
    private static let namedConfigAccount = "test_account_CungkardAk"
    private static let defaultInlineConfigAccount = "test_account_QxiWq2X9sg"

    private static let multiMerchantAppId = "wuqol13QQJu0vcjbdN9892cl5IcyJgPU"
    private static let multiMerchantAppKey = "jdOJNxsGbE0nLeTx"
    private static let multiMerchantTargetMerchantId = "MER_3abc0724f49c40e59a61309ae6d37dfd"

    private static let standaloneMerchantInlineAppId = "UDVB5ngQEEn6wPLA9gJZMj25Uw6B9wXcXbd9XTu7tEq9pbUg"
    private static let standaloneMerchantInlineAppKey = "UICgLDNtzLXK7L2p8AGcRfaf9PzvYPCuVGJxQoWjqUCr2BERs80xNBuSDe9uB9G7"

    private static let standaloneMerchantNamedAppId = "naL0LWpbHEHJSw9aSmap1u3W1rqusAA4587WzEBikVG4zbEK"
    private static let standaloneMerchantNamedAppKey = "LeC5h0BuYfVnvTe3b0732AHG2HGtxptNNq9RfoQcnP0sozfKkYyLvNtiQf5md3BB"

    private static let multiMerchantNamedConfig = "MultiMerchantNamedConfig"
    private static let standaloneMerchantNamedConfig = "StandaloneMerchantNamedConfig"

    override func setUp() {
        super.setUp()

        // Multi-merchant default + named config.
        let multiMerchantConfig = GpApiConfig(
            appId: Self.multiMerchantAppId,
            appKey: Self.multiMerchantAppKey,
            channel: .cardPresent
        )
        multiMerchantConfig.merchantId = Self.multiMerchantTargetMerchantId
        multiMerchantConfig.country = "US"
        multiMerchantConfig.accessTokenInfo = AccessTokenInfo(
            transactionProcessingAccountName: Self.namedConfigAccount
        )

        try? ServicesContainer.configureService(config: multiMerchantConfig)
        try? ServicesContainer.configureService(config: multiMerchantConfig, configName: Self.multiMerchantNamedConfig)

        // Standalone named config.
        let standaloneNamedConfig = GpApiConfig(
            appId: Self.standaloneMerchantNamedAppId,
            appKey: Self.standaloneMerchantNamedAppKey,
            channel: .cardPresent
        )
        standaloneNamedConfig.country = "US"
        standaloneNamedConfig.accessTokenInfo = AccessTokenInfo(
            transactionProcessingAccountName: Self.namedConfigAccount
        )

        try? ServicesContainer.configureService(config: standaloneNamedConfig, configName: Self.standaloneMerchantNamedConfig)

        card = CreditCardData()
        card.number = "5425230000004415"
        card.expMonth = 12
        card.expYear = 2026
        card.cvn = "123"
        card.cardPresent = true
    }

    override func tearDown() {
        card = nil
        super.tearDown()
    }

    func test_close_batch_without_batch_id_multi_merchant_default_config_account_only() {
        
        let multiMerchantDefaultInlineConfig = GpApiConfig(
            appId: Self.multiMerchantAppId,
            appKey: Self.multiMerchantAppKey,
            channel: .cardPresent
        )
        multiMerchantDefaultInlineConfig.merchantId = Self.multiMerchantTargetMerchantId
        multiMerchantDefaultInlineConfig.country = "US"
        multiMerchantDefaultInlineConfig.accessTokenInfo = AccessTokenInfo(
            transactionProcessingAccountName: Self.defaultInlineConfigAccount
        )
        try? ServicesContainer.configureService(config: multiMerchantDefaultInlineConfig)

        let chargeExpectation = expectation(description: "Charge multi-merchant default account-only")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        card.charge(amount: Self.amount)
            .withCurrency("USD")
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        wait(for: [chargeExpectation], timeout: 15.0)
        XCTAssertNil(chargeTransactionError)
        assertTransactionResponse(transaction: chargeTransactionResult, status: .captured)

        sleep(1)

        let closeBatchExpectation = expectation(description: "Close multi-merchant default account-only")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: Error?

        BatchService.closeBatch {
            batchSummaryResult = $0
            batchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        wait(for: [closeBatchExpectation], timeout: 15.0)
        XCTAssertNil(batchSummaryError)
        assertBatchCloseResponse(batchSummary: batchSummaryResult, amount: Self.amount)
    }

    func test_close_batch_without_batch_id_multi_merchant_named_config_with_currency_and_payment_methods() {
        let chargeExpectation = expectation(description: "Charge multi-merchant named scoped")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        card.charge(amount: Self.amount)
            .withCurrency(Self.currency)
            .execute(configName: Self.multiMerchantNamedConfig) {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        wait(for: [chargeExpectation], timeout: 15.0)
        XCTAssertNil(chargeTransactionError)
        assertTransactionResponse(transaction: chargeTransactionResult, status: .captured)

        sleep(1)

        let closeBatchExpectation = expectation(description: "Close multi-merchant named scoped")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: Error?

        BatchService.closeBatch(
            currency: Self.currency,
            paymentMethods: [.card],
            configName: Self.multiMerchantNamedConfig
        ) {
            batchSummaryResult = $0
            batchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        wait(for: [closeBatchExpectation], timeout: 15.0)
        XCTAssertNil(batchSummaryError)
        assertBatchCloseResponse(batchSummary: batchSummaryResult, amount: Self.amount)
    }

    func test_close_batch_without_batch_id_multi_merchant_default_config_with_currency_and_payment_methods() {
        
        let multiMerchantDefaultInlineConfig = GpApiConfig(
            appId: Self.multiMerchantAppId,
            appKey: Self.multiMerchantAppKey,
            channel: .cardPresent
        )
        multiMerchantDefaultInlineConfig.merchantId = Self.multiMerchantTargetMerchantId
        multiMerchantDefaultInlineConfig.country = "US"
        multiMerchantDefaultInlineConfig.accessTokenInfo = AccessTokenInfo(
            transactionProcessingAccountName: Self.defaultInlineConfigAccount
        )
        try? ServicesContainer.configureService(config: multiMerchantDefaultInlineConfig)

        let chargeExpectation = expectation(description: "Charge multi-merchant default scoped")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        card.charge(amount: Self.amount)
            .withCurrency("USD")
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        wait(for: [chargeExpectation], timeout: 15.0)
        XCTAssertNil(chargeTransactionError)
        assertTransactionResponse(transaction: chargeTransactionResult, status: .captured)

        sleep(1)

        let closeBatchExpectation = expectation(description: "Close multi-merchant default scoped")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: Error?

        BatchService.closeBatch(
            currency: "USD",
            paymentMethods: [.card]
        ) {
            batchSummaryResult = $0
            batchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        wait(for: [closeBatchExpectation], timeout: 15.0)
        XCTAssertNil(batchSummaryError)
        assertBatchCloseResponse(batchSummary: batchSummaryResult, amount: Self.amount)
    }

    func test_close_batch_without_batch_id_invalid_currency_returns_configuration_error() {
        let closeBatchExpectation = expectation(description: "Close invalid currency")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: GatewayException?

        BatchService.closeBatch(
            currency: "PLN",
            paymentMethods: [.card],
            configName: Self.multiMerchantNamedConfig
        ) {
            batchSummaryResult = $0
            batchSummaryError = $1 as? GatewayException
            closeBatchExpectation.fulfill()
        }

        wait(for: [closeBatchExpectation], timeout: 15.0)
        XCTAssertNil(batchSummaryResult)
        XCTAssertNotNil(batchSummaryError)
        XCTAssertEqual(batchSummaryError?.responseCode, "CONFIGURATION_DOES_NOT_EXIST")
        XCTAssertEqual(batchSummaryError?.responseMessage, "40041")
        XCTAssertTrue(batchSummaryError?.message?.contains("Merchant configuration does not exist") ?? false)
    }

    func test_close_batch_without_batch_id_multi_merchant_default_config_currency_mismatch_returns_configuration_error() {
        
        let chargeExpectation = expectation(description: "Charge mismatch default")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        card.charge(amount: Self.amount)
            .withCurrency(Self.currency)
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        wait(for: [chargeExpectation], timeout: 15.0)
        XCTAssertNil(chargeTransactionError)
        assertTransactionResponse(transaction: chargeTransactionResult, status: .captured)

        sleep(1)

        let closeBatchExpectation = expectation(description: "Close mismatch default")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: GatewayException?

        BatchService.closeBatch(
            currency: "USD",
            paymentMethods: [.card]
        ) {
            batchSummaryResult = $0
            batchSummaryError = $1 as? GatewayException
            closeBatchExpectation.fulfill()
        }

        wait(for: [closeBatchExpectation], timeout: 15.0)
        XCTAssertNil(batchSummaryResult)
        XCTAssertNotNil(batchSummaryError)
        XCTAssertEqual(batchSummaryError?.responseCode, "CONFIGURATION_DOES_NOT_EXIST")
        XCTAssertEqual(batchSummaryError?.responseMessage, "40041")
        XCTAssertTrue(batchSummaryError?.message?.contains("Merchant configuration does not exist") ?? false)
    }

    func test_close_batch_without_batch_id_multi_merchant_named_config_currency_mismatch_returns_configuration_error() {
        let chargeExpectation = expectation(description: "Charge mismatch named")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        card.charge(amount: Self.amount)
            .withCurrency(Self.currency)
            .execute(configName: Self.multiMerchantNamedConfig) {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        wait(for: [chargeExpectation], timeout: 15.0)
        XCTAssertNil(chargeTransactionError)
        assertTransactionResponse(transaction: chargeTransactionResult, status: .captured)

        sleep(1)

        let closeBatchExpectation = expectation(description: "Close mismatch named")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: GatewayException?

        BatchService.closeBatch(
            currency: "USD",
            paymentMethods: [.card],
            configName: Self.multiMerchantNamedConfig
        ) {
            batchSummaryResult = $0
            batchSummaryError = $1 as? GatewayException
            closeBatchExpectation.fulfill()
        }

        wait(for: [closeBatchExpectation], timeout: 15.0)
        XCTAssertNil(batchSummaryResult)
        XCTAssertNotNil(batchSummaryError)
        XCTAssertEqual(batchSummaryError?.responseCode, "CONFIGURATION_DOES_NOT_EXIST")
        XCTAssertEqual(batchSummaryError?.responseMessage, "40041")
        XCTAssertTrue(batchSummaryError?.message?.contains("Merchant configuration does not exist") ?? false)
    }

    func test_close_batch_without_batch_id_standalone_merchant_default_config_account_only() {
        let standaloneInlineConfig = GpApiConfig(
            appId: Self.standaloneMerchantInlineAppId,
            appKey: Self.standaloneMerchantInlineAppKey,
            channel: .cardPresent
        )
        standaloneInlineConfig.country = "US"
        standaloneInlineConfig.accessTokenInfo = AccessTokenInfo(
            transactionProcessingAccountName: Self.defaultInlineConfigAccount
        )
        try? ServicesContainer.configureService(config: standaloneInlineConfig)

        let chargeExpectation = expectation(description: "Charge standalone default account-only")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        card.charge(amount: Self.amount)
            .withCurrency("USD")
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        wait(for: [chargeExpectation], timeout: 15.0)
        XCTAssertNil(chargeTransactionError)
        assertTransactionResponse(transaction: chargeTransactionResult, status: .captured)

        sleep(1)

        let closeBatchExpectation = expectation(description: "Close standalone default account-only")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: Error?

        BatchService.closeBatch {
            batchSummaryResult = $0
            batchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        wait(for: [closeBatchExpectation], timeout: 15.0)
        XCTAssertNil(batchSummaryError)
        assertBatchCloseResponse(batchSummary: batchSummaryResult, amount: Self.amount)
    }

    func test_close_batch_without_batch_id_standalone_merchant_named_config_with_currency_and_payment_methods() {
        let chargeExpectation = expectation(description: "Charge standalone named scoped")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        card.charge(amount: Self.amount)
            .withCurrency(Self.currency)
            .execute(configName: Self.standaloneMerchantNamedConfig) {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        wait(for: [chargeExpectation], timeout: 15.0)
        XCTAssertNil(chargeTransactionError)
        assertTransactionResponse(transaction: chargeTransactionResult, status: .captured)

        sleep(1)

        let closeBatchExpectation = expectation(description: "Close standalone named scoped")
        var batchSummaryResult: BatchSummary?
        var batchSummaryError: Error?

        BatchService.closeBatch(
            currency: Self.currency,
            paymentMethods: [.card],
            configName: Self.standaloneMerchantNamedConfig
        ) {
            batchSummaryResult = $0
            batchSummaryError = $1
            closeBatchExpectation.fulfill()
        }

        wait(for: [closeBatchExpectation], timeout: 15.0)
        XCTAssertNil(batchSummaryError)
        assertBatchCloseResponse(batchSummary: batchSummaryResult, amount: Self.amount)
    }

    private func assertBatchCloseResponse(batchSummary: BatchSummary?, amount: NSDecimalNumber) {
        XCTAssertNotNil(batchSummary)
        XCTAssertEqual(batchSummary?.status, "CLOSED")

        if let transactionCount = batchSummary?.transactionCount {
            XCTAssertTrue(transactionCount >= 1)
        } else {
            XCTFail("batchSummary?.transactionCount cannot be nil")
        }

        if let totalAmount = batchSummary?.totalAmount?.doubleValue {
            XCTAssertTrue(totalAmount >= amount.doubleValue)
        } else {
            XCTFail("batchSummary?.totalAmount cannot be nil")
        }
    }

    private func assertTransactionResponse(transaction: Transaction?, status: TransactionStatus) {
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction?.responseCode, "SUCCESS")
        XCTAssertEqual(transaction?.responseMessage, status.mapped(for: .gpApi))
    }
}
