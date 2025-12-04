import XCTest
import GlobalPayments_iOS_SDK

final class GpApiCreateTokenWithPorticoCredentialsTest: XCTestCase {
            
    private let APP_ID = "DAua5WpU5jjES2ZPjwdjqKDF75xUknQY"
    private let APP_KEY = "test"
    private var masterCard =  CreditCardData()
    private var visaCard =  CreditCardData()
    private let amount = NSDecimalNumber(2.02)
    private let currency = "USD"
    
    private var legacyPorticoConfig = GpApiConfig()
    private var secretApiKeyConfig = GpApiConfig()
    private var fullPorticoConfig = GpApiConfig()
    private var legacyPorticoAppIdConfig = GpApiConfig()
    private var secretApiKeyAppIdConfig = GpApiConfig()
    private var gpApiFailingConfig = GpApiConfig()
    
    override func setUp() {
        super.setUp()
        porticoSetUp()
    }
    
    func porticoSetUp() {
        configureFullPortico()
        configureLegacyPortico()
        configureSecretApiKey()
        configureLegacyPorticoAppIdConfig()
        configureSecretApiKeyAppIdConfig()
        configureGpApiFailingConfig()
        configureGpApiConfig()
        
        masterCard.number = "5546259023665054"
        masterCard.expMonth = 12
        masterCard.expYear = 2026
        masterCard.cvn = "123"
        masterCard.cardPresent = false
        masterCard.readerPresent = false
        
        visaCard.number = "4263970000005262"
        visaCard.expMonth = 12
        visaCard.expYear = 2026
        visaCard.cvn = "123"
        visaCard.cardPresent = false
        visaCard.readerPresent = false
    }
    
    // MARK: - ConfigureFullPortico
    func configureFullPortico() {
        fullPorticoConfig.channel = .cardNotPresent
        fullPorticoConfig.country = "US"
        fullPorticoConfig.serviceUrl = "https://apis-qa.globalpay.com/ucp"
        
        let porticoTokenConfig = PorticoTokenConfig()
        porticoTokenConfig.siteId = 418948
        porticoTokenConfig.licenseId = 388244
        porticoTokenConfig.deviceId = 11753
        porticoTokenConfig.username = "gateway1213846"
        porticoTokenConfig.password = "$Test1234"
        porticoTokenConfig.secretApiKey = "skapi_cert_MVISAgC05V8Amnxg2jARLKW-K4ONQeXejrWYCCA_Cw"
        fullPorticoConfig.porticoTokenConfig = porticoTokenConfig
        
        try? ServicesContainer.configureService(config: fullPorticoConfig, configName: "fullPorticoConfig")
    }
    
    // MARK: - ConfigureLegacyPortico
    func configureLegacyPortico() {
        legacyPorticoConfig.channel = .cardNotPresent
        legacyPorticoConfig.country = "US"
        legacyPorticoConfig.serviceUrl = "https://apis-qa.globalpay.com/ucp"
        
        let porticoTokenConfig = PorticoTokenConfig()
        porticoTokenConfig.siteId = 418948
        porticoTokenConfig.licenseId = 388244
        porticoTokenConfig.deviceId = 11753
        porticoTokenConfig.username = "gateway1213846"
        porticoTokenConfig.password = "$Test1234"
        legacyPorticoConfig.porticoTokenConfig = porticoTokenConfig
        
        try? ServicesContainer.configureService(config: legacyPorticoConfig, configName: "legacyPorticoConfig")
    }
    
    // MARK: - ConfigureSecretApiKey
    func configureSecretApiKey() {
        secretApiKeyConfig.channel = .cardNotPresent
        secretApiKeyConfig.country = "US"
        secretApiKeyConfig.serviceUrl = "https://apis-qa.globalpay.com/ucp"
        
        let porticoTokenConfig = PorticoTokenConfig()
        porticoTokenConfig.secretApiKey = "skapi_cert_MVISAgC05V8Amnxg2jARLKW-K4ONQeXejrWYCCA_Cw"
        secretApiKeyConfig.porticoTokenConfig = porticoTokenConfig
        
        try? ServicesContainer.configureService(config: secretApiKeyConfig, configName: "secretApiKeyConfig")
    }
    
    // MARK: - ConfigureLegacyPorticoAppIdConfig
    func configureLegacyPorticoAppIdConfig() {
        legacyPorticoAppIdConfig = GpApiConfig(appId: "jYtVGox8yvG6KQwlNHPxbfyDa13kwOGt")
        legacyPorticoAppIdConfig.channel = .cardNotPresent
        legacyPorticoAppIdConfig.country = "US"
        legacyPorticoAppIdConfig.serviceUrl = "https://apis-qa.globalpay.com/ucp"
        
        let porticoTokenConfig = PorticoTokenConfig()
        porticoTokenConfig.siteId = 418948
        porticoTokenConfig.licenseId = 388244
        porticoTokenConfig.deviceId = 11753
        porticoTokenConfig.username = "gateway1213846"
        porticoTokenConfig.password = "$Test1234"
        legacyPorticoAppIdConfig.porticoTokenConfig = porticoTokenConfig
        
        try? ServicesContainer.configureService(config: legacyPorticoAppIdConfig, configName: "legacyPorticoAppIdConfig")
    }
    
    // MARK: - ConfigureSecretApiKeyAppIdConfig
    func configureSecretApiKeyAppIdConfig() {
        secretApiKeyAppIdConfig = GpApiConfig(appId: "jYtVGox8yvG6KQwlNHPxbfyDa13kwOGt")
        secretApiKeyAppIdConfig.channel = .cardNotPresent
        secretApiKeyAppIdConfig.country = "US"
        secretApiKeyAppIdConfig.serviceUrl = "https://apis-qa.globalpay.com/ucp"
        
        let porticoTokenConfig = PorticoTokenConfig()
        porticoTokenConfig.siteId = 418948
        porticoTokenConfig.licenseId = 388244
        porticoTokenConfig.deviceId = 11753
        porticoTokenConfig.username = "gateway1213846"
        porticoTokenConfig.password = "$Test1234"
        porticoTokenConfig.secretApiKey = "skapi_cert_MVISAgC05V8Amnxg2jARLKW-K4ONQeXejrWYCCA_Cw"
        secretApiKeyAppIdConfig.porticoTokenConfig = porticoTokenConfig
        
        try? ServicesContainer.configureService(config: secretApiKeyAppIdConfig, configName: "secretApiKeyAppIdConfig")
    }
    
    // MARK: - ConfigureGpApiFailingConfig
    func configureGpApiFailingConfig() {
        gpApiFailingConfig.channel = .cardNotPresent
        gpApiFailingConfig.country = "US"
        gpApiFailingConfig.serviceUrl = "https://apis-qa.globalpay.com/ucp"
        
        let porticoTokenConfig = PorticoTokenConfig()
        porticoTokenConfig.siteId = 418948
        porticoTokenConfig.licenseId = 388244
        porticoTokenConfig.deviceId = 11753
        porticoTokenConfig.username = ""
        porticoTokenConfig.password = ""
        porticoTokenConfig.secretApiKey = ""
        gpApiFailingConfig.porticoTokenConfig = porticoTokenConfig
        
        try? ServicesContainer.configureService(config: gpApiFailingConfig, configName: "gpApiFailingConfig")
    }
    
    // MARK: - ConfigureGpApiConfig
    func configureGpApiConfig() {
        let config = GpApiConfig(
            appId: "4gPqnGBkppGYvoE5UX9EWQlotTxGUDbs",
            appKey: "FQyJA5VuEQfcji2M",
            channel: .cardNotPresent,
        )
        config.country = "US"
        try? ServicesContainer.configureService(config: config)
    }
    
    func testCreditSaleShouldReturnsCapturedTransactionWhenUsingFullPorticoConfig() {
        let expectation = expectation(description: "Wait for execution...")
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        masterCard.charge(amount: amount)
            .withCurrency(currency)
            .execute(configName: "fullPorticoConfig") { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("CAPTURED", responseCharge?.responseMessage)
    }
    
    func testCreditSaleShouldReturnsCapturedTransactionWhenUsingLegacyConfig() {
        let expectation = expectation(description: "Wait for execution...")
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        masterCard.charge(amount: amount)
            .withCurrency(currency)
            .execute(configName: "legacyPorticoConfig") { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("CAPTURED", responseCharge?.responseMessage)
    }
    
    func testCreditSaleShouldReturnCapturedTransactionWithPorticoApiKey() {
        let expectation = expectation(description: "Wait for execution...")
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        masterCard.charge(amount: amount)
            .withCurrency(currency)
            .execute(configName: "secretApiKeyConfig") { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("CAPTURED", responseCharge?.responseMessage)
    }
    
    func testCreditSaleShouldReturnCapturedTransactionWithPorticoCredentialsAndAppID() {
        let expectation = expectation(description: "Wait for execution...")
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        masterCard.charge(amount: amount)
            .withCurrency(currency)
            .execute(configName: "legacyPorticoAppIdConfig") { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("CAPTURED", responseCharge?.responseMessage)
    }
    
    func testCreditSaleShouldReturnCapturedTransactionWithPorticoApiKeyAndAppID() {
        let expectation = expectation(description: "Wait for execution...")
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        masterCard.charge(amount: amount)
            .withCurrency(currency)
            .execute(configName: "secretApiKeyAppIdConfig") { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("CAPTURED", responseCharge?.responseMessage)
    }
    
    func testCreditSaleShouldReturnCapturedTransactionWithPorticoInvalidCredentials() {
        let expectation = expectation(description: "Wait for execution...")
        
        var errorResponse: GatewayException?
        
        masterCard.charge(amount: amount)
            .withCurrency(currency)
            .execute(configName: "gpApiFailingConfig") { transactionResult, error in
                errorResponse = error as? GatewayException
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertEqual("INVALID_REQUEST_DATA", errorResponse?.responseCode)
        XCTAssertEqual("40004", errorResponse?.responseMessage)
        XCTAssertEqual("Status Code: 400 - Credentials not recognized to create access token", errorResponse?.message)
    }
    
    func testsCreditSaleShouldReturnCapturedTransactionWhenUsingGpApiCredentials() {
        let expectation = expectation(description: "Wait for execution...")
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        visaCard.charge(amount: amount)
            .withCurrency(currency)
            .execute() { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("CAPTURED", responseCharge?.responseMessage)
    }
}
