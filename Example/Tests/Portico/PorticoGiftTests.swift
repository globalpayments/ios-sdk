//
//  PorticoGiftTests.swift
//  GlobalPayments-iOS-SDK_Tests
//
//  Created by Ranu Dhurandhar on 27/03/26.
//  Copyright © 2026 GlobalPayments. All rights reserved.
//

import Foundation

import XCTest
@testable import GlobalPayments_iOS_SDK

final class PorticoGiftTests: XCTestCase {
    // MARK: - Unit Tests
    
    private var card: GiftCard!
    private let amount = NSDecimalNumber(10.00)
    override func setUp() {
        super.setUp()
        configuration()
    }
    
    func configuration() {
        let config = PorticoConfig()
        config.secretApiKey = PorticoTestConstants.secretApiKey
        config.serviceUrl = PorticoTestConstants.serviceUrl
        try? ServicesContainer.configureService(config: config)

        card = GiftCard()
        card.trackData =  "mBpGUiryZp8Tc3xYT4FCahL6agmBbUVS84YUV7NF6va48exNxrCQTuv1ZSbt2ERsb6Elr6ljZ32PZqe8ycIkq7pTjxYIRkpHgPQ6sxh78ME="
        card.encryptionData = .version1()
        card.encryptionData?.version = "05"
        card.encryptionData?.trackNumber = "1"
        card.encryptionData?.ksn = "//89P4EAACAAAQ=="
        
    }
    
    func testGiftSale_returnsTransaction() {
       let expectation = XCTestExpectation(description: "Wait for execution...")
        var response: Transaction?
        var error: Error?

        card.charge(amount: amount)
            .withCurrency("USD")
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
    
        XCTAssertNotNil(response)
        XCTAssertNil(error)
        XCTAssertEqual(response?.serviceName, "GiftCardSale")
        XCTAssertEqual(response?.responseCode, "0")
        XCTAssertEqual(response?.responseMessage, "Success")
        XCTAssertNotNil(response?.transactionId)

    }
    
    // MARK: - Integration Tests
    
    func testGiftSale_againstGateway_returnsTransaction() {
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var response: Transaction?
        var error: Error?
        
        card.charge(amount: amount)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual(response?.serviceName, "GiftCardSale")
        XCTAssertEqual(response?.responseCode, "0")
        XCTAssertEqual(response?.responseMessage, "Success")
        XCTAssertNotNil(response?.transactionId)
        XCTAssertFalse((response?.transactionId ?? "").isEmpty)
        XCTAssertNotNil(response?.balanceAmount)
    }
}
