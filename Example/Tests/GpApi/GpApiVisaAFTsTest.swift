//
//  GpApiVisaAFTsTest.swift
//  GlobalPayments-iOS-SDK_Tests
//
//  Created by Yashwant Patil on 03/04/26.
//  Copyright © 2026 GlobalPayments. All rights reserved.
//

import XCTest
import GlobalPayments_iOS_SDK

final class GpApiVisaAFTsTest: XCTestCase {

    private let amount = NSDecimalNumber(2.02)
    private let APP_ID = "4gPqnGBkppGYvoE5UX9EWQlotTxGUDbs"
    private let APP_KEY = "FQyJA5VuEQfcji2M"
    private let currency = "GBP"
    private var visaCard = CreditCardData()
    
    override func setUp() {
        super.setUp()
        configuration()
    }
    
    func configuration() {
        let config = GpApiConfig(
            appId: APP_ID,
            appKey: APP_KEY
        )
        config.channel = .cardNotPresent
        config.country = "UK"
        
        let accessTokenInfo =  AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "transaction_processing"
        config.accessTokenInfo = accessTokenInfo
        try? ServicesContainer.configureService(config: config)
        
        visaCard.number = "4263970000005262"
        visaCard.expMonth = 12
        visaCard.expYear = 2026
        visaCard.cvn = "123"
        visaCard.cardPresent = false
        visaCard.readerPresent = false
        visaCard.cardHolderName = "James Mason"
    }

    // MARK: - Helpers

    private func makeAFTData() -> OrderSupplementaryData {
        let aftData = OrderSupplementaryData()
        aftData.type = "VISA_DIRECT_AFT"
        aftData.fields = [
            "John Smith",
            "10 High Street",
            "Nottingham",
            "GBR",
            "02",
            "123456789"
        ]
        return aftData
    }

    // MARK: - Positive Test

    func testVisaAFTs() {
        // GIVEN
        let expectation = XCTestExpectation(description: "Wait for execution...")
        var responseCharge: Transaction?
        var errorResponse: Error?

        // WHEN
        visaCard.charge(amount: amount)
            .withCurrency(currency)
            .withClientTransactionId("APM-20200417")
            .withOrderSupplementaryData([makeAFTData()])
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
    }

    // MARK: - Negative Tests

    func testVisaAFTsMissingAmount() {
        // GIVEN
        let expectation = XCTestExpectation(description: "Wait for execution...")
        var responseCharge: Transaction?
        var errorResponse: Error?

        // WHEN
        visaCard.charge()
            .withCurrency(currency)
            .withClientTransactionId("APM-20200417")
            .withOrderSupplementaryData([makeAFTData()])
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNil(responseCharge)
        XCTAssertNotNil(errorResponse)
    }

    func testVisaAFTsMissingCurrency() {
        // GIVEN
        let expectation = XCTestExpectation(description: "Missing currency expectation")
        var responseCharge: Transaction?
        var builderError: BuilderException?

        // WHEN
        visaCard.charge(amount: amount)
            .withClientTransactionId("APM-20200417")
            .withOrderSupplementaryData([makeAFTData()])
            .execute { transactionResult, error in
                responseCharge = transactionResult
                builderError = error as? BuilderException
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 30.0)
        XCTAssertNil(responseCharge)
        XCTAssertNotNil(builderError)
    }

    func testVisaAFTsInvalidCardNumber() {
        // GIVEN
        let expectation = XCTestExpectation(description: "Invalid card number expectation")
        var responseCharge: Transaction?
        var gatewayError: GatewayException?

        let testCard = CreditCardData()
        testCard.number = "0000000000000000"
        testCard.expMonth = 12
        testCard.expYear = 2026
        testCard.cvn = "123"
        testCard.cardHolderName = "James Mason"

        // WHEN
        testCard.charge(amount: amount)
            .withCurrency(currency)
            .withClientTransactionId("APM-20200417")
            .withOrderSupplementaryData([makeAFTData()])
            .execute { transactionResult, error in
                responseCharge = transactionResult
                if let error = error as? GatewayException {
                    gatewayError = error
                }
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNil(responseCharge)
        XCTAssertNotNil(gatewayError)
        XCTAssertEqual("INVALID_REQUEST_DATA", gatewayError?.responseCode)
    }

    func testVisaAFTsInvalidCurrency() {
        // GIVEN
        let expectation = XCTestExpectation(description: "Invalid currency expectation")
        var responseCharge: Transaction?
        var gatewayError: GatewayException?

        // WHEN
        visaCard.charge(amount: amount)
            .withCurrency("INVALID")
            .withClientTransactionId("APM-20200417")
            .withOrderSupplementaryData([makeAFTData()])
            .execute { transactionResult, error in
                responseCharge = transactionResult
                if let error = error as? GatewayException {
                    gatewayError = error
                }
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNil(responseCharge)
        XCTAssertNotNil(gatewayError)
        XCTAssertEqual("INVALID_REQUEST_DATA", gatewayError?.responseCode)
    }

    func testVisaAFTsZeroAmount() {
        // GIVEN
        let expectation = XCTestExpectation(description: "Zero amount expectation")
        var responseCharge: Transaction?
        var gatewayError: GatewayException?

        // WHEN
        visaCard.charge(amount: NSDecimalNumber(0))
            .withCurrency(currency)
            .withClientTransactionId("APM-20200417")
            .withOrderSupplementaryData([makeAFTData()])
            .execute { transactionResult, error in
                responseCharge = transactionResult
                if let error = error as? GatewayException {
                    gatewayError = error
                }
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNil(responseCharge)
        XCTAssertNotNil(gatewayError)
        XCTAssertEqual("INVALID_REQUEST_DATA", gatewayError?.responseCode)
    }

    func testVisaAFTsEmptySupplementaryDataFields() {
        // GIVEN
        let expectation = XCTestExpectation(description: "Empty supplementary data fields expectation")
        var responseCharge: Transaction?
        var gatewayError: GatewayException?

        let aftData = OrderSupplementaryData()
        aftData.type = "VISA_DIRECT_AFT"
        aftData.fields = []

        // WHEN
        visaCard.charge(amount: amount)
            .withCurrency(currency)
            .withClientTransactionId("APM-20200417")
            .withOrderSupplementaryData([aftData])
            .execute { transactionResult, error in
                responseCharge = transactionResult
                if let error = error as? GatewayException {
                    gatewayError = error
                }
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNil(responseCharge)
        XCTAssertNotNil(gatewayError)
        XCTAssertEqual("Status Code: 400 - order.supplementary_data.fields value is invalid. Please check the format and data provided is correct.", gatewayError?.message)
    }
    
    func testVisaAFTsNullSupplementaryDataFields() {
        // GIVEN
        let expectation = XCTestExpectation(description: "Null supplementary data fields expectation")
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        // WHEN
        visaCard.charge(amount: amount)
            .withCurrency(currency)
            .withClientTransactionId("APM-20200417")
            .withOrderSupplementaryData(nil)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
    }
    
    func testVisaAFTsInsufficientFields() {
        // GIVEN
        let expectation = XCTestExpectation(description: "Insufficient fields Invalid expectation")
        var responseCharge: Transaction?
        var gatewayError: GatewayException?
        
        let aftData = OrderSupplementaryData()
        aftData.type = "VISA_DIRECT_AFT"
        aftData.fields = [
            "John Smith",
            "10 High Street"
            // Missing required fields...
        ]
        
        // WHEN
        visaCard.charge(amount: amount)
            .withCurrency(currency)
            .withClientTransactionId("APM-20200417")
            .withOrderSupplementaryData([aftData])
            .execute { transactionResult, error in
                responseCharge = transactionResult
                if let error = error as? GatewayException {
                    gatewayError = error
                }
                expectation.fulfill()
            }
        
        // THEN
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNil(responseCharge)
        XCTAssertNotNil(gatewayError)
        XCTAssertEqual("Status Code: 400 - order.supplementary_data.fields value is invalid. Please check the format and data provided is correct.", gatewayError?.message)
    }
    
    func testVisaAFTsInvalidSupplementaryDataList() {
        // GIVEN
        let expectation = XCTestExpectation(description: "Empty string fields Invalid expectation")
        var responseCharge: Transaction?
        var gatewayError: GatewayException?
        
        let aftData = OrderSupplementaryData()
        aftData.type = "VISA_DIRECT_AFT"
        aftData.fields = [
            "",
            "",
            "",
            "",
            "",
            ""
        ]
        
        // WHEN
        visaCard.charge(amount: amount)
            .withCurrency(currency)
            .withClientTransactionId("APM-20200417")
            .withOrderSupplementaryData([aftData])
            .execute { transactionResult, error in
                responseCharge = transactionResult
                if let error = error as? GatewayException {
                    gatewayError = error
                }
                expectation.fulfill()
            }
        
        // THEN
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNil(responseCharge)
        XCTAssertNotNil(gatewayError)
        XCTAssertEqual("Status Code: 400 - order.supplementary_data.fields value is invalid. Please check the format and data provided is correct.", gatewayError?.message)
    }
    
    func testVisaAFTsNullFieldsArray() {
        // GIVEN
        let expectation = XCTestExpectation(description: "Null fields array Invalid expectation")
        var responseCharge: Transaction?
        var gatewayError: GatewayException?
        
        let aftData = OrderSupplementaryData()
        aftData.type = "VISA_DIRECT_AFT"
        aftData.fields = nil  // Fields array is null
        
        // WHEN
        visaCard.charge(amount: amount)
            .withCurrency(currency)
            .withClientTransactionId("APM-20200417")
            .withOrderSupplementaryData([aftData])
            .execute { transactionResult, error in
                responseCharge = transactionResult
                if let error = error as? GatewayException {
                    gatewayError = error
                }
                expectation.fulfill()
            }
        
        // THEN
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNil(responseCharge)
        XCTAssertNotNil(gatewayError)
        XCTAssertEqual("Status Code: 400 - order.supplementary_data.fields value is invalid. Please check the format and data provided is correct.", gatewayError?.message)
    }
}
