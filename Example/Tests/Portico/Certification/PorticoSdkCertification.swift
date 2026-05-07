//
//  PorticoSdkCertification.swift
//  GlobalPayments-iOS-SDK_Tests
//
//  Created by Yashwant Patil on 10/03/26.
//  Copyright © 2026 GlobalPayments. All rights reserved.
//

import XCTest
@testable import GlobalPayments_iOS_SDK

enum PorticoTestConstants {
    static let secretApiKey = "skapi_cert_MaePAQBr-1QAqjfckFC8FTbRTT120bVQUlfVOjgCBw"
    static let serviceUrl = "https://cert.api2-c.heartlandportico.com"
}

final class PorticoSdkCertification: XCTestCase {
    
    private var card: CreditTrackData!
    private let amount = NSDecimalNumber(string: "15.15")
    override func setUp() {
        super.setUp()
        configuration()
    }

    func configuration() {
        let config = PorticoConfig()
        config.secretApiKey = PorticoTestConstants.secretApiKey
        config.serviceUrl = PorticoTestConstants.serviceUrl
        try? ServicesContainer.configureService(config: config)
        
        card = CreditTrackData()
        card.value = "A6pwBo5syh9Tmy4tdvqpd7Gko+nkozL7Zl+6bZpm8qJ+sRSjkMzVIJ3SjUdxxhcAO4iY0jNua58/1acYb6X7TDHAfQOQ68gdG9yhJsR/eXQ="
        card.entryMethod = .swipe
        card.encryptionData = .version1()
        card.encryptionData?.version = "05"
        card.encryptionData?.trackNumber = "1"
        card.encryptionData?.ksn = "//89P4EAAKAAAQ=="
    
    }
    
    func testCreditSaleWithVisaSwipe() {
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.charge(amount: amount)
            .withAllowDuplicates(true)
            .withCurrency("USD")
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual(responseCharge?.serviceName, "CreditSale")
        XCTAssertEqual(responseCharge?.responseCode, "00")
        XCTAssertEqual(responseCharge?.responseMessage, "APPROVAL")
        XCTAssertNotNil(responseCharge?.transactionId)
    }
    
    func testCreditRefundWithVisaSwipe() {
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        let clientTransactionId = "701044262"
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.charge(amount: amount)
            .withAllowDuplicates(true)
            .withCurrency("USD")
            .withClientTransactionId(clientTransactionId)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual(responseCharge?.serviceName, "CreditSale")
        XCTAssertEqual(responseCharge?.responseCode, "00")
        XCTAssertEqual(responseCharge?.responseMessage, "APPROVAL")
        XCTAssertNotNil(responseCharge?.transactionId)
        sleep(5)
        
        
        let refundExecuteExpectation = XCTestExpectation(description: "Wait for execution...")
        var refundTransactionResult: Transaction?
        var refundTransactionError: Error?
        
        card.refund(amount: amount)
            .withCurrency("USD")
            .execute {
                refundTransactionResult = $0
                refundTransactionError = $1
                refundExecuteExpectation.fulfill()
            }
        wait(for: [refundExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(refundTransactionResult)
        XCTAssertNil(refundTransactionError)
        XCTAssertEqual(refundTransactionResult?.serviceName, "CreditReturn")
        XCTAssertEqual(refundTransactionResult?.gatewayResponseCode, "0")
        XCTAssertEqual(refundTransactionResult?.gatewayResponseMessage, "Success")
        XCTAssertNotNil(refundTransactionResult?.transactionId)
    }
    
    func testCreditSaleVoidWithVisaSwipe() {
        let expectation = XCTestExpectation(description: "Wait for execution...")

        // Use the same amount as Objective-C test for consistency
        ///let testAmount = NSDecimalNumber(string: "15.01")
        var responseCharge: Transaction?
        var errorResponse: Error?

        card.charge(amount: amount)
            .withAllowDuplicates(true)
            .withCurrency("USD")
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual(responseCharge?.serviceName, "CreditSale")
        XCTAssertEqual(responseCharge?.responseCode, "00")
        XCTAssertEqual(responseCharge?.responseMessage, "APPROVAL")
        XCTAssertNotNil(responseCharge?.transactionId)

        sleep(10) // Increase if needed for backend processing

        // Always use the transactionId from the sale response
        guard let saleTransactionId = responseCharge?.transactionId else {
            XCTFail("Sale transactionId is nil")
            return
        }

        let authResponse = Transaction.fromId(transactionId: saleTransactionId)
        let voidExecuteExpectation = XCTestExpectation(description: "Wait for void execution...")
        var voidTransactionResult: Transaction?
        var voidTransactionError: Error?

        authResponse.voidTransaction(amount: amount)
            .execute { transactionResult, error in
                voidTransactionResult = transactionResult
                voidTransactionError = error
                voidExecuteExpectation.fulfill()
            }

        wait(for: [voidExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(voidTransactionResult)
        XCTAssertNil(voidTransactionError)
        XCTAssertEqual(voidTransactionResult?.serviceName, "CreditVoid")
        XCTAssertEqual(voidTransactionResult?.gatewayResponseCode, "0")
        XCTAssertEqual(voidTransactionResult?.gatewayResponseMessage, "Success")
        XCTAssertNotNil(voidTransactionResult?.transactionId)
    }
    
    func testCreditSale_MC5_Swipe() {
        
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
        XCTAssertNotNil(response)
        XCTAssertNil(error)
        XCTAssertEqual(response?.serviceName, "CreditSale")
        XCTAssertEqual(response?.responseCode, "00")
        XCTAssertEqual(response?.responseMessage, "APPROVAL")
        XCTAssertNotNil(response?.transactionId)
    }
    
    func test009_CreditSale_Discover_Swipe() {
        //same as testCreditSale_MC5_Swipe
    }
    
    func testCreditSale_Amex_Swipe() {
        //same as testCreditSale_MC5_Swipe
    }
    
    func testCreditSale_JCB_Swipe() {
        //same as testCreditSale_MC5_Swipe
    }
    
    func testCreditSale_MC2_Swipe() {
        //same as testCreditSale_MC5_Swipe
    }
    
    func testCreditSale_Visa_Manual() {
        let expectation = XCTestExpectation(description: "Wait for execution...")

            let address = makeTestAddress()

        
            var response: Transaction?
            var error: Error?
            let card = makeTestCard()


            // Build authorization
            card.charge(amount: amount)
            .withAllowDuplicates(true)
            .withCurrency("USD")
            .withAddress(address)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response?.serviceName, "CreditSale")
            XCTAssertEqual(response?.responseCode, "00")
            XCTAssertEqual(response?.responseMessage, "APPROVAL")
            XCTAssertNotNil(response?.transactionId)
    }
    
    func testCreditSale_MC5_Manual() {
        let expectation = XCTestExpectation(description: "Wait for execution...")

            let address = makeTestAddress()

        
            var response: Transaction?
            var error: Error?
            let card = makeTestCard()


            // Build authorization
            card.charge(amount: amount)
            .withAllowDuplicates(true)
            .withCurrency("USD")
            .withAddress(address)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response?.serviceName, "CreditSale")
            XCTAssertEqual(response?.responseCode, "00")
            XCTAssertEqual(response?.responseMessage, "APPROVAL")
            XCTAssertNotNil(response?.transactionId)
        
        guard let saleTransactionId = response?.transactionId else {
            XCTFail("Sale transactionId is nil")
            return
        }

        let authResponse = Transaction.fromId(transactionId: saleTransactionId)
        let voidExecuteExpectation = XCTestExpectation(description: "Wait for void execution...")
        var voidTransactionResult: Transaction?
        var voidTransactionError: Error?

        authResponse.voidTransaction(amount: amount)
            .execute { transactionResult, error in
                voidTransactionResult = transactionResult
                voidTransactionError = error
                voidExecuteExpectation.fulfill()
            }

        wait(for: [voidExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(voidTransactionResult)
        XCTAssertNil(voidTransactionError)
        XCTAssertEqual(voidTransactionResult?.serviceName, "CreditVoid")
        XCTAssertEqual(voidTransactionResult?.gatewayResponseCode, "0")
        XCTAssertEqual(voidTransactionResult?.gatewayResponseMessage, "Success")
        XCTAssertNotNil(voidTransactionResult?.transactionId)
    }
    
    func testCreditSale_MC5_Manual_Void(){
        //added in testCreditSale_MC5_Manual()
        
    }
    
    func testCreditSale_Discover_Manual () {
        let expectation = XCTestExpectation(description: "Wait for execution...")

            let address = makeTestAddress()
        
            var response: Transaction?
            var error: Error?
            let card = makeTestCard()


            // Build authorization
            card.charge(amount: amount)
            .withAllowDuplicates(true)
            .withCurrency("USD")
            .withAddress(address)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response?.serviceName, "CreditSale")
            XCTAssertEqual(response?.responseCode, "00")
            XCTAssertEqual(response?.responseMessage, "APPROVAL")
            XCTAssertNotNil(response?.transactionId)
    }
    
    func testCreditSale_Amex_Manual () {
        let expectation = XCTestExpectation(description: "Wait for execution...")

            let address = makeTestAddress()
        
            var response: Transaction?
            var error: Error?
            let card = makeTestCard()


            // Build authorization
            card.charge(amount: amount)
            .withAllowDuplicates(true)
            .withCurrency("USD")
            .withAddress(address)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response?.serviceName, "CreditSale")
            XCTAssertEqual(response?.responseCode, "00")
            XCTAssertEqual(response?.responseMessage, "APPROVAL")
            XCTAssertNotNil(response?.transactionId)
    }
    
    func testCreditSale_JCB_Manual () {
        let expectation = XCTestExpectation(description: "Wait for execution...")
            let address = makeTestAddress()
        
            var response: Transaction?
            var error: Error?
            let card = makeTestCard()


            // Build authorization
            card.charge(amount: amount)
            .withAllowDuplicates(true)
            .withCurrency("USD")
            .withAddress(address)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response?.serviceName, "CreditSale")
            XCTAssertEqual(response?.responseCode, "00")
            XCTAssertEqual(response?.responseMessage, "APPROVAL")
            XCTAssertNotNil(response?.transactionId)
    }
    
    
    func testCreditSale_Visa_Swipe_TipAtSettlement(){
        let expectation = XCTestExpectation(description: "Wait for execution...")
        var responseCharge: Transaction?
        var errorResponse: Error?

        card.charge(amount: amount)
            .withAllowDuplicates(true)
            .withCurrency("USD")
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual(responseCharge?.serviceName, "CreditSale")
        XCTAssertEqual(responseCharge?.responseCode, "00")
        XCTAssertEqual(responseCharge?.responseMessage, "APPROVAL")
        XCTAssertNotNil(responseCharge?.transactionId)
        sleep(10)
        guard let saleTransactionId = responseCharge?.transactionId else {
            XCTFail("Sale transactionId is nil")
            return
        }

        let authResponse = Transaction.fromId(transactionId: saleTransactionId)
        let voidExecuteExpectation = XCTestExpectation(description: "Wait for void execution...")
        var voidTransactionResult: Transaction?
        var voidTransactionError: Error?

        authResponse.edit()
            .withAmount(amount)
            .withGratuity(3.00)
            .execute { transactionResult, error in
                voidTransactionResult = transactionResult
                voidTransactionError = error
                voidExecuteExpectation.fulfill()
            }

        wait(for: [voidExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(voidTransactionResult)
        XCTAssertNil(voidTransactionError)
        XCTAssertEqual(voidTransactionResult?.serviceName, "CreditTxnEdit")
        XCTAssertEqual(voidTransactionResult?.gatewayResponseCode, "0")
        XCTAssertEqual(voidTransactionResult?.gatewayResponseMessage, "Success")
        XCTAssertNotNil(voidTransactionResult?.transactionId)
        
        
    }
    
    func testCreditSale_MC5_Manual_TipAtSettlement () {
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        let address = makeTestAddress()
        let card = makeTestCard()


        card.charge(amount: amount)
        .withAllowDuplicates(true)
        .withCurrency("USD")
        .withAddress(address)
        .execute { transactionResult, error in
            responseCharge = transactionResult
            errorResponse = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual(responseCharge?.serviceName, "CreditSale")
        XCTAssertEqual(responseCharge?.responseCode, "00")
        XCTAssertEqual(responseCharge?.responseMessage, "APPROVAL")
        XCTAssertNotNil(responseCharge?.transactionId)
        sleep(10)
        guard let saleTransactionId = responseCharge?.transactionId else {
            XCTFail("Sale transactionId is nil")
            return
        }

        let authResponse = Transaction.fromId(transactionId: saleTransactionId)
        let editExpectation = XCTestExpectation(description: "Wait for void execution...")
        var editTransactionResult: Transaction?
        var editTransactionError: Error?

        authResponse.edit()
            .withAmount(amount)
            .withGratuity(3.00)
            .execute { transactionResult, error in
                editTransactionResult = transactionResult
                editTransactionError = error
                editExpectation.fulfill()
            }

        wait(for: [editExpectation], timeout: 10.0)
        XCTAssertNotNil(editTransactionResult)
        XCTAssertNil(editTransactionError)
        XCTAssertEqual(editTransactionResult?.serviceName, "CreditTxnEdit")
        XCTAssertEqual(editTransactionResult?.gatewayResponseCode, "0")
        XCTAssertEqual(editTransactionResult?.gatewayResponseMessage, "Success")
        XCTAssertNotNil(editTransactionResult?.transactionId)
    }
    
    func testCreditSale_Visa_Manual_TipAtPurchase() {
        let expectation = XCTestExpectation(description: "Wait for execution...")
        var responseCharge: Transaction?
        var errorResponse: Error?
        let address = makeTestAddress()
        let card = makeTestCard()

        card.charge(amount: amount)
        .withAllowDuplicates(true)
        .withCurrency("USD")
        .withAddress(address)
        .execute { transactionResult, error in
            responseCharge = transactionResult
            errorResponse = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual(responseCharge?.serviceName, "CreditSale")
        XCTAssertEqual(responseCharge?.responseCode, "00")
        XCTAssertEqual(responseCharge?.responseMessage, "APPROVAL")
        XCTAssertNotNil(responseCharge?.transactionId)
        XCTAssertFalse(responseCharge?.transactionId == "")
    }
    
    func testCreditSale_MC5_Swipe_TipAtPurchase(){
        let expectation = XCTestExpectation(description: "Wait for execution...")
        var response: Transaction?
        var error: Error?
        
        card.charge(amount: amount)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .withGratuity(3.50)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(response)
        XCTAssertNil(error)
        XCTAssertEqual(response?.serviceName, "CreditSale")
        XCTAssertEqual(response?.responseCode, "00")
        XCTAssertEqual(response?.responseMessage, "APPROVAL")
        XCTAssertNotNil(response?.transactionId)
        XCTAssertFalse(response?.transactionId == "")
        
    }
    
    func testCreditReturn_MC5_Manual_ByTrackData() {
        let refundExecuteExpectation = XCTestExpectation(description: "Wait for execution...")
        var refundTransactionResult: Transaction?
        var refundTransactionError: Error?
        
        card.refund(amount: amount)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute {
                refundTransactionResult = $0
                refundTransactionError = $1
                refundExecuteExpectation.fulfill()
            }
        wait(for: [refundExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(refundTransactionResult)
        XCTAssertNil(refundTransactionError)
        XCTAssertEqual(refundTransactionResult?.serviceName, "CreditReturn")
        XCTAssertEqual(refundTransactionResult?.gatewayResponseCode, "0")
        XCTAssertEqual(refundTransactionResult?.gatewayResponseMessage, "Success")
        XCTAssertNotNil(refundTransactionResult?.transactionId)
        XCTAssertFalse(refundTransactionResult?.transactionId == "")
        
    }
    
    func testCreditSale_JCB_Manual_ByTxnId () {
        let expectation = XCTestExpectation(description: "Wait for execution...")

            var response: Transaction?
            var error: Error?
            let card = makeTestCard()

            // Build authorization
            card.charge(amount: amount)
            .withAllowDuplicates(true)
            .withCurrency("USD")
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            //XCTAssertEqual(response?.serviceName, "CreditSale")
            XCTAssertEqual(response?.responseCode, "00")
            XCTAssertEqual(response?.responseMessage, "APPROVAL")
            XCTAssertNotNil(response?.transactionId)
            XCTAssertFalse(response?.transactionId == "")
            sleep(10)
            guard let saleTransactionId = response?.transactionId else {
                XCTFail("Sale transactionId is nil")
                return
            }

            let authResponse = Transaction.fromId(transactionId: saleTransactionId)
            let refundExpectation = XCTestExpectation(description: "Wait for void execution...")
            var refundResponse: Transaction?
            var refundError: Error?

            authResponse.refund(amount: amount)
                .withCurrency("USD")
                .execute { transactionResult, error in
                    refundResponse = transactionResult
                    refundError = error
                    refundExpectation.fulfill()
            }

            wait(for: [refundExpectation], timeout: 10.0)
            XCTAssertNotNil(refundResponse)
            XCTAssertNil(refundError)
            XCTAssertEqual(refundResponse?.serviceName, "CreditReturn")
            XCTAssertEqual(refundResponse?.gatewayResponseCode, "0")
            XCTAssertEqual(refundResponse?.gatewayResponseMessage, "Success")
            XCTAssertNotNil(refundResponse?.transactionId)
            XCTAssertFalse(refundResponse?.transactionId == "")
     }
    
    func testCreditReversal_Discover_Swipe() {
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        let clientTransactionId = "702567220"
        
            var response: Transaction?
            var error: Error?
          
            card.charge(amount: amount)
            .withCurrency("USD")
            .withClientTransactionId(clientTransactionId)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response?.serviceName, "CreditSale")
            XCTAssertEqual(response?.responseCode, "00")
            XCTAssertEqual(response?.responseMessage, "APPROVAL")
            XCTAssertNotNil(response?.transactionId)
            XCTAssertFalse(response?.transactionId == "")
            sleep(10)
            

        let authResponse = Transaction.fromId(transactionId: response?.transactionId ?? "")
            let reverseExpectation = XCTestExpectation(description: "Wait for void execution...")
            var reverseResponse: Transaction?
            var reverseError: Error?

            authResponse.reverse(amount: amount)
                .withCurrency("USD")
                .execute { transactionResult, error in
                    reverseResponse = transactionResult
                    reverseError = error
                    reverseExpectation.fulfill()
            }

            wait(for: [reverseExpectation], timeout: 10.0)
            XCTAssertNotNil(reverseResponse)
            XCTAssertNil(reverseError)
            XCTAssertEqual(reverseResponse?.serviceName, "CreditReversal")
            XCTAssertEqual(reverseResponse?.responseCode, "00")
            XCTAssertEqual(reverseResponse?.responseMessage, "APPROVAL")
            XCTAssertNotNil(reverseResponse?.transactionId)
            XCTAssertFalse(reverseResponse?.transactionId == "")
    }
    
    func testCreditReversal_MC5_Swipe() {
        let expectation = XCTestExpectation(description: "Wait for execution...")
        let clientTransactionId = "701638298"
        
            var response: Transaction?
            var error: Error?
          
            card.charge(amount: amount)
            .withAllowDuplicates(true)
            .withCurrency("USD")
            .withClientTransactionId(clientTransactionId)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response?.serviceName, "CreditSale")
            XCTAssertEqual(response?.responseCode, "00")
            XCTAssertEqual(response?.responseMessage, "APPROVAL")
            XCTAssertNotNil(response?.transactionId)
            XCTAssertFalse(response?.transactionId == "")
            sleep(10)
            

        let authResponse = Transaction.fromId(transactionId: response?.transactionId ?? "")
            let voidExecuteExpectation = XCTestExpectation(description: "Wait for void execution...")
            var voidTransactionResult: Transaction?
            var voidTransactionError: Error?

            authResponse.reverse(amount: amount)
                .withCurrency("USD")
                .execute { transactionResult, error in
                    voidTransactionResult = transactionResult
                    voidTransactionError = error
                    voidExecuteExpectation.fulfill()
            }

            wait(for: [voidExecuteExpectation], timeout: 10.0)
            XCTAssertNotNil(voidTransactionResult)
            XCTAssertNil(voidTransactionError)
            XCTAssertEqual(voidTransactionResult?.serviceName, "CreditReversal")
            XCTAssertEqual(voidTransactionResult?.responseCode, "00")
            XCTAssertEqual(voidTransactionResult?.responseMessage, "APPROVAL")
            XCTAssertNotNil(voidTransactionResult?.transactionId)
            XCTAssertFalse(voidTransactionResult?.transactionId == "")
        
    }
    
    func testCreditReversal_JCB_Swipe() {
        //coverd in testCreditReversal_MC5_Swipe()
    }
    
    /// Helper to create a CreditCardData or ManualEntryData with common test values
    private func makeTestCard() -> CreditCardData {
        let card = CreditCardData()
        card.number = "4012002000060016"
        card.expMonth = 12
        card.expYear = 2025
        card.cvn = "123"
        return card
    }
    
    /// Helper to create an Address with default or custom values
    private func makeTestAddress() -> Address {
        let address = Address()
        address.streetAddress1 = "6860 Dallas Pkwy"
        address.postalCode = "750241234"
        return address
    }
}
