//
//  PorticoCreditTest.swift
//  GlobalPayments-iOS-SDK_Tests
//
//  Created by Yashwant Patil on 16/03/26.
//  Copyright © 2026 GlobalPayments. All rights reserved.
//

import XCTest
import GlobalPayments_iOS_SDK

final class PorticoCreditTest: XCTestCase {

    private var card: CreditTrackData!
    private let amount = NSDecimalNumber(string: "2.02")
    private let tagData = "9F1A0208409C0150950500000088009F0702FF009F03060000000000009F2701809F3901059F0D05B850AC88009F350121500B56697361204372656469745F3401019F0802008C9F120B56697361204372656469749F0E0500000000009F360200759F40057E0000A0019F0902008C9F0F05B870BC98009F370425D254AC5F280208409F33036028C882023C004F07A00000000310109F4104000000899F0607A00000000310105F2A0208409A031911229F02060000000001009F2608D4EC434B9C1CBB358407A00000000310109F100706010A03A088069B02E8009F34031E0300"
    private let address = Address()
    private var visaCard = CreditCardData()
    
    override func setUp() {
        super.setUp()
        configuration()
    }
    
    func configuration() {
        let config = PorticoConfig()
        config.secretApiKey = PorticoTestConstants.secretApiKey
        config.serviceUrl = PorticoTestConstants.serviceUrl
        try? ServicesContainer.configureService(config: config)
        
        address.streetAddress1 = "6860 Dallas Pkwy"
        address.postalCode = "750241234"
        
        visaCard.number = "4012002000060016"
        visaCard.expMonth = 12
        visaCard.expYear = 2025
        visaCard.cvn = "123"
        visaCard.cardPresent = false
        visaCard.readerPresent = false
    }
    
    private func getEMVCreditTrack() -> CreditTrackData {
        let card = CreditTrackData()
        card.value = "oDA60Hw+9/K2wx+DA3Xn/q+8AZzl2ojR"
        card.entryMethod = .swipe
        card.encryptionData = .version1()
        card.encryptionData?.version = "05"
        card.encryptionData?.trackNumber = "2"
        card.encryptionData?.ksn = "//89P4EAAEAACA=="
        return card
    }
    
    private func getCreditTrack() -> CreditTrackData {
        let card = CreditTrackData()
        card.value = "A6pwBo5syh9Tmy4tdvqpd7Gko+nkozL7Zl+6bZpm8qJ+sRSjkMzVIJ3SjUdxxhcAO4iY0jNua58/1acYb6X7TDHAfQOQ68gdG9yhJsR/eXQ="
        card.entryMethod = .swipe
        card.encryptionData = .version1()
        card.encryptionData?.version = "05"
        card.encryptionData?.trackNumber = "1"
        card.encryptionData?.ksn = "//89P4EAAKAAAQ=="
        return card
    }

    func testCreditVerifyReturnsTransaction() {
        card = getEMVCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.verify()
            .withTagData(tagData)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.responseMessage == "CARD OK")
    }
    
    func testCreditSaleWithCardHolderNamePart1ReturnsTransaction() {
        visaCard.cardHolderName = "James"
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        visaCard.charge(amount: amount)
            .withCurrency("USD")
            .withAddress(address)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
    }
    
    func testCreditSaleWithCardHolderNamePart2ReturnsTransaction() {
        visaCard.cardHolderName = "James Mason"
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        visaCard.charge(amount: amount)
            .withCurrency("USD")
            .withAddress(address)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
    }
    
    func testCreditSaleWithCardHolderNamePart3ReturnsTransaction() {
        visaCard.cardHolderName = "James John Mason"
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        visaCard.charge(amount: amount)
            .withCurrency("USD")
            .withAddress(address)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
    }
    
    func testCreditSaleWithCardHolderNamePart2WithEmptyPrefixReturnsTransaction() {
        visaCard.cardHolderName = " James Mason"
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        visaCard.charge(amount: amount)
            .withCurrency("USD")
            .withAddress(address)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
    }
    
    func testCreditSaleWithCardHolderNamePart2WithEmptySuffixReturnsTransaction() {
        visaCard.cardHolderName = "James Mason "
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        visaCard.charge(amount: amount)
            .withCurrency("USD")
            .withAddress(address)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
    }
    
    func testCreditSaleSupportDuplicateData() {
        card = getEMVCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.charge(amount: amount)
            .withCurrency("USD")
            .withTagData(tagData)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
    }
    
    func testCreditVerifyWithContactEMVReturnsTransaction() {
        card = getEMVCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.verify()
            .withAllowDuplicates(true)
            .withTagData(tagData)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
    }
    
    func testCreditVerifyWithTrackReturnsTransaction() {
        card = getCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card = getCreditTrack()
        
        card.verify()
            .withAllowDuplicates(true)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
    }
    
    func testCreditVerifyWithEMVFallbackReturnsTransaction() {
        card = getCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.verify()
            .withAllowDuplicates(true)
            .withChipCondition(.chipFailPreviousSuccess)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditAccountVerify")
    }
    
    func testCreditAuthorizeWithContactEMVReturnsTransaction() {
        card = getEMVCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.authorize(amount: amount)
            .withCurrency("USD")
            .withTagData(tagData)
            .withAllowDuplicates(true)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditAuth")
    }
    
    func testCreditAuthorizeChipDeclineWithContactEMVReturnsTransaction() {
        card = getEMVCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.authorize(amount: amount)
            .withAllowDuplicates(true)
            .withTransactionType(.decline)
            .withTransactionModifier(.chipDecline)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("Transaction was rejected because the track data could not be read.", responseCharge?.gatewayResponseMessage)
    }
    
    func testCreditAuthorizeWithTrackReturnsTransaction() {
        card = getCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.authorize(amount: amount)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditAuth")
    }
    
    func testCreditAuthorizeWithEMVFallbackReturnsTransaction() {
        card = getCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.authorize(amount: amount)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .withChipCondition(.chipFailPreviousSuccess)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditAuth")
    }
    
    func testCreditSaleWithContactEMVReturnsTransaction() {
        card = getEMVCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.charge(amount: amount)
            .withCurrency("USA")
            .withTagData(tagData)
            .withAllowDuplicates(true)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditSale")
    }
    
    func testCreditSaleWithTrackReturnsTransaction() {
        card = getCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.charge(amount: amount)
            .withCurrency("USA")
            .withAllowDuplicates(true)
            .withGratuity(NSDecimalNumber(string: "4.28"))
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditSale")
    }
    
    func testCreditSaleWithEMVFallbackReturnsTransaction() {
        card = getCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.charge(amount: amount)
            .withCurrency("USA")
            .withAllowDuplicates(true)
            .withChipCondition(.chipFailPreviousSuccess)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditSale")
    }
    
    func testCreditSaleLevel2WithTrackReturnsTransaction() {
        card = getCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.charge(amount: amount)
            .withCurrency("USA")
            .withAllowDuplicates(true)
            .withCommercialRequest(true)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditSale")
        
        // level 2 edit request
        let authResponse = Transaction.fromId(transactionId: responseCharge?.transactionId ?? "")
        
        let authExecuteExpectation = XCTestExpectation(description: "Wait for execution...")
        
        authResponse.edit()
            .withTaxType(.salesTax)
            .withTaxAmount(NSDecimalNumber(1.00))
            .withPoNumber("123456")
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                authExecuteExpectation.fulfill()
            }
        
        wait(for: [authExecuteExpectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditCPCEdit")
    }
    
    func testCreditSaleFalseForLevel2WithTrackReturnsTransaction() {
        card = getCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.charge(amount: amount)
            .withCurrency("USA")
            .withAllowDuplicates(true)
            .withCommercialRequest(false)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditSale")
        
        // level 2 edit request
        let authExecuteExpectation = XCTestExpectation(description: "Wait for execution...")
        
        let authResponse = Transaction.fromId(transactionId: responseCharge?.transactionId ?? "")
        
        authResponse.edit()
            .withTaxType(.salesTax)
            .withTaxAmount(NSDecimalNumber(1.00))
            .withPoNumber("123456")
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                authExecuteExpectation.fulfill()
            }
        
        wait(for: [authExecuteExpectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditCPCEdit")
    }
    
    func testCreditAuthCaptureWithTrackReturnsTransaction() {
        card = getCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.authorize(amount: amount)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditAuth")
        
        let captureExecuteExpectation = XCTestExpectation(description: "Wait for execution...")
        
        let authResponse = Transaction.fromId(transactionId: responseCharge?.transactionId ?? "")
        
        authResponse.capture()
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                captureExecuteExpectation.fulfill()
            }
        
        wait(for: [captureExecuteExpectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditAddToBatch")
    }
    
    func testCreditReturnWithContactEMVReturnsTransaction() {
        card = getEMVCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.refund(amount: amount)
            .withCurrency("USD")
            .withTagData(tagData)
            .withAllowDuplicates(true)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditReturn")
    }
    
    func testCreditReturnWithCreditTrackReturnsTransaction() {
        card = getCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.refund(amount: amount)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditReturn")
    }
    
    func testCreditAuthCaptureWithTipEditPartialReversalWithTrackReturnsTransaction() {
        card = getCreditTrack()
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        card.authorize(amount: NSDecimalNumber(10.00))
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditAuth")
        
        // capture
        let captureExecuteExpectation = XCTestExpectation(description: "Wait for execution...")
        let authResponse = Transaction.fromId(transactionId: responseCharge?.transactionId ?? "")
        
        authResponse.capture(amount: NSDecimalNumber(string: "13.00"))
            .withGratuity(NSDecimalNumber(string: "3.00"))
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                captureExecuteExpectation.fulfill()
            }
        
        wait(for: [captureExecuteExpectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditAddToBatch")
        
        // edit
        let editExecuteExpectation = XCTestExpectation(description: "Wait for execution...")
        
        authResponse.edit()
            .withAmount(NSDecimalNumber(string: "10.00"))
            .withGratuity(NSDecimalNumber(string: "0.0"))
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                editExecuteExpectation.fulfill()
            }
        wait(for: [editExecuteExpectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditTxnEdit")
        
        // reverse
        let reverseExecuteExpectation = XCTestExpectation(description: "Wait for execution...")
        
        authResponse.reverse(amount: NSDecimalNumber(10.00))
            .withAuthAmount(NSDecimalNumber(8.00))
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                reverseExecuteExpectation.fulfill()
            }
        wait(for: [reverseExecuteExpectation], timeout: 120.0)
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("0", responseCharge?.gatewayResponseCode)
        XCTAssertEqual("Success", responseCharge?.gatewayResponseMessage)
        XCTAssertTrue(responseCharge?.serviceName == "CreditReversal")
    }
}
