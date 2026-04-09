//
//  GpApiDataResidencyTest.swift
//  GlobalPayments-iOS-SDK_Tests
//

import XCTest
import GlobalPayments_iOS_SDK

final class GpApiDataResidencyTest: XCTestCase {

    private let EU_APP_ID = "QlI6DivlPcXboV1AAG3NGtf340bJO6A34SqUa5REJojQMzat"
    private let EU_APP_KEY = "G3Gdx6biXAXgJJFaMnuLo0hlBCCMH18rCXnPzySl37nwctMAmrV1EykuXi6GQCrh"
    private let APP_ID = "4gPqnGBkppGYvoE5UX9EWQlotTxGUDbs"
    private let APP_KEY = "FQyJA5VuEQfcji2M"
    
    private var masterCard =  CreditCardData()
    private let amount: NSDecimalNumber = 12.02
    private let currency = "EUR"
    
    override func setUp() {
        super.setUp()
        configuration()
    }
    
    func configuration() {
        masterCard.number = "4263970000005262"
        masterCard.expMonth = 12
        masterCard.expYear = 2026
        masterCard.cvn = "852"
    }
    
    func configureDataResidency() {
        let config = GpApiConfig(
            appId: EU_APP_ID,
            appKey: EU_APP_KEY)
        config.channel = .cardNotPresent
        config.dataResidency = .eu
        
        let accessTokenInfo =  AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "internet"
        config.accessTokenInfo = accessTokenInfo
        try? ServicesContainer.configureService(config: config)
    }
    
    func configureGpApiDefault() {
        let config = GpApiConfig(
            appId: APP_ID,
            appKey: APP_KEY)
        config.channel = .cardNotPresent
        
        let accessTokenInfo =  AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "transaction_processing"
        config.accessTokenInfo = accessTokenInfo
        try? ServicesContainer.configureService(config: config)
    }
    
    
    func testDataResidencyEuQaRoutesToQaEuEndpoint() {
        let config = GpApiConfig(
            appId: EU_APP_ID,
            appKey: EU_APP_KEY)
        config.channel = .cardNotPresent
        config.dataResidency = .eu
        config.environment = .qa
        
        let accessTokenInfo =  AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "internet"
        config.accessTokenInfo = accessTokenInfo
        try? ServicesContainer.configureService(config: config)

        XCTAssertEqual(ServiceEndpoints.gpApiQAEU.rawValue,config.serviceUrl )
    }
    
    func testDataResidencyEU() {
        configureDataResidency()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        masterCard.charge(amount: amount)
            .withCurrency(currency)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
    }
    
    func testDataResidencyDefaultsToNone() {
        configureGpApiDefault()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        masterCard.charge(amount: amount)
            .withCurrency(currency)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
    }
    
    func testDataResidencyEUWithInvalidCurrencyReturnsError() {
        configureDataResidency()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var captureErrorResponse: GatewayException?
        
        masterCard.charge(amount: amount)
            .withCurrency("US")
            .execute { transactionResult, error in
                responseCharge = transactionResult
                if let error = error as? GatewayException {
                    captureErrorResponse = error
                }
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNil(responseCharge)
        XCTAssertNotNil(captureErrorResponse)
        XCTAssertEqual(captureErrorResponse?.message, "Status Code: 400 - currency contains unexpected data")
    }
}
