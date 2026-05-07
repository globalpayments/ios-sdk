//
//  PorticoBatchServiceTest.swift
//  GlobalPayments-iOS-SDK_Tests
//
//  Created by Yashwant Patil on 27/03/26.
//  Copyright © 2026 GlobalPayments. All rights reserved.
//

import XCTest
import GlobalPayments_iOS_SDK

final class PorticoBatchServiceTest: XCTestCase {

    override func setUp() {
        super.setUp()
        configuration()
    }
    
    func configuration() {
        let config = PorticoConfig()
        config.secretApiKey = "skapi_cert_MaePAQBr-1QAqjfckFC8FTbRTT120bVQUlfVOjgCBw"
        config.serviceUrl = "https://cert.api2-c.heartlandportico.com"
        try? ServicesContainer.configureService(config: config)
    }

    func testBatchClose() {
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        PorticoBatchService.closeBatch { transaction, error in
            XCTAssertNotNil(transaction)
            XCTAssertNil(error)
            responseCharge = transaction
            errorResponse = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
    }
}
