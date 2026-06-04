//
//  GpApiApacPHCreditTests.swift
//  GlobalPayments-iOS-SDK
//
//  Created by Ranu Dhurandhar on 21/05/26.

import XCTest
import GlobalPayments_iOS_SDK


class GpApiApacPHCreditTests: XCTestCase {

    // MARK: - Configuration

    private var visaCard: CreditCardData!
    private var mastercardCard: CreditCardData!

    private let AMOUNT: NSDecimalNumber = 10.00
    private let CURRENCY = "PHP"
    private let EXPECTED_CODE = "SUCCESS"

    override func setUp() {
        super.setUp()

        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = GpApiApacTestConfig.accountName

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: GpApiApacTestConfig.appId,
            appKey: GpApiApacTestConfig.appKey,
            channel: .cardNotPresent,
            country: "PH",
            accessTokenInfo: accessTokenInfo
        ))

        visaCard = CreditCardData()
        visaCard.number = "4263970000005262"
        visaCard.expMonth = 12
        visaCard.expYear = 2026
        visaCard.cvn = "852"
        visaCard.cardHolderName = "APAC PH Visa Test"

        mastercardCard = CreditCardData()
        mastercardCard.number = "5425230000004415"
        mastercardCard.expMonth = 12
        mastercardCard.expYear = 2026
        mastercardCard.cvn = "123"
        mastercardCard.cardHolderName = "APAC PH Mastercard Test"
    }

    override func tearDown() {
        super.tearDown()
        visaCard = nil
        mastercardCard = nil
    }

    // MARK: - 1. Sale

    func test_ph_sale_visa() {
        // GIVEN
        let saleExpectation = expectation(description: "PH Sale Visa Expectation")
        var saleResult: Transaction?
        var saleError: Error?

        // WHEN
        visaCard.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                saleResult = $0
                saleError = $1
                saleExpectation.fulfill()
            }

        // THEN
        wait(for: [saleExpectation], timeout: 10.0)
        XCTAssertNil(saleError)
        XCTAssertNotNil(saleResult)
        XCTAssertEqual(EXPECTED_CODE, saleResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, saleResult?.responseMessage)
    }

    func test_ph_sale_mastercard() {
        // GIVEN
        let saleExpectation = expectation(description: "PH Sale Mastercard Expectation")
        var saleResult: Transaction?
        var saleError: Error?

        // WHEN
        mastercardCard.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                saleResult = $0
                saleError = $1
                saleExpectation.fulfill()
            }

        // THEN
        wait(for: [saleExpectation], timeout: 10.0)
        XCTAssertNil(saleError)
        XCTAssertNotNil(saleResult)
        XCTAssertEqual(EXPECTED_CODE, saleResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, saleResult?.responseMessage)
    }

    // MARK: - 2. Auth (Authorization – no capture)

    func test_ph_auth_visa() {
        // GIVEN
        let authExpectation = expectation(description: "PH Auth Visa Expectation")
        var authResult: Transaction?
        var authError: Error?

        // WHEN
        visaCard.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                authResult = $0
                authError = $1
                authExpectation.fulfill()
            }

        // THEN
        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertNil(authError)
        XCTAssertNotNil(authResult)
        XCTAssertEqual(EXPECTED_CODE, authResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, authResult?.responseMessage)
    }

    func test_ph_auth_mastercard() {
        // GIVEN
        let authExpectation = expectation(description: "PH Auth Mastercard Expectation")
        var authResult: Transaction?
        var authError: Error?

        // WHEN
        mastercardCard.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                authResult = $0
                authError = $1
                authExpectation.fulfill()
            }

        // THEN
        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertNil(authError)
        XCTAssertNotNil(authResult)
        XCTAssertEqual(EXPECTED_CODE, authResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, authResult?.responseMessage)
    }

    // MARK: - 3. Pre-Auth

    func test_ph_preauth_visa() {
        // GIVEN
        let preAuthExpectation = expectation(description: "PH Pre-Auth Visa Expectation")
        var preAuthResult: Transaction?
        var preAuthError: Error?

        // WHEN
        visaCard.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                preAuthResult = $0
                preAuthError = $1
                preAuthExpectation.fulfill()
            }

        // THEN
        wait(for: [preAuthExpectation], timeout: 10.0)
        XCTAssertNil(preAuthError)
        XCTAssertNotNil(preAuthResult)
        XCTAssertEqual(EXPECTED_CODE, preAuthResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, preAuthResult?.responseMessage)
    }

    func test_ph_preauth_mastercard() {
        // GIVEN
        let preAuthExpectation = expectation(description: "PH Pre-Auth Mastercard Expectation")
        var preAuthResult: Transaction?
        var preAuthError: Error?

        // WHEN
        mastercardCard.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                preAuthResult = $0
                preAuthError = $1
                preAuthExpectation.fulfill()
            }

        // THEN
        wait(for: [preAuthExpectation], timeout: 10.0)
        XCTAssertNil(preAuthError)
        XCTAssertNotNil(preAuthResult)
        XCTAssertEqual(EXPECTED_CODE, preAuthResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, preAuthResult?.responseMessage)
    }

    // MARK: - 4. Capture (Auth then full Capture)

    func test_ph_auth_then_capture_visa() {
        // GIVEN
        let authExpectation = expectation(description: "PH Auth Expectation")
        var authResult: Transaction?
        var authError: Error?

        // WHEN
        visaCard.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                authResult = $0
                authError = $1
                authExpectation.fulfill()
            }

        // THEN
        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertNil(authError)
        XCTAssertNotNil(authResult)
        XCTAssertEqual(EXPECTED_CODE, authResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, authResult?.responseMessage)

        // GIVEN
        let captureExpectation = expectation(description: "PH Capture Expectation")
        var captureResult: Transaction?
        var captureError: Error?

        // WHEN
        authResult?.capture(amount: AMOUNT)
            .execute {
                captureResult = $0
                captureError = $1
                captureExpectation.fulfill()
            }

        // THEN
        wait(for: [captureExpectation], timeout: 10.0)
        XCTAssertNil(captureError)
        XCTAssertNotNil(captureResult)
        XCTAssertEqual(EXPECTED_CODE, captureResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, captureResult?.responseMessage)
    }

    func test_ph_auth_then_capture_mastercard() {
        // GIVEN
        let authExpectation = expectation(description: "PH Auth Mastercard Expectation")
        var authResult: Transaction?
        var authError: Error?

        // WHEN
        mastercardCard.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                authResult = $0
                authError = $1
                authExpectation.fulfill()
            }

        // THEN
        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertNil(authError)
        XCTAssertNotNil(authResult)
        XCTAssertEqual(EXPECTED_CODE, authResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, authResult?.responseMessage)

        // GIVEN
        let captureExpectation = expectation(description: "PH Capture Mastercard Expectation")
        var captureResult: Transaction?
        var captureError: Error?

        // WHEN
        authResult?.capture(amount: AMOUNT)
            .execute {
                captureResult = $0
                captureError = $1
                captureExpectation.fulfill()
            }

        // THEN
        wait(for: [captureExpectation], timeout: 10.0)
        XCTAssertNil(captureError)
        XCTAssertNotNil(captureResult)
        XCTAssertEqual(EXPECTED_CODE, captureResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, captureResult?.responseMessage)
    }

    // MARK: - 5. Void (reverse a captured Sale)

    func test_ph_void_visa() {
        // GIVEN
        let saleExpectation = expectation(description: "PH Sale Expectation")
        var saleResult: Transaction?
        var saleError: Error?

        // WHEN
        visaCard.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                saleResult = $0
                saleError = $1
                saleExpectation.fulfill()
            }

        // THEN
        wait(for: [saleExpectation], timeout: 10.0)
        XCTAssertNil(saleError)
        XCTAssertNotNil(saleResult)
        XCTAssertEqual(EXPECTED_CODE, saleResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, saleResult?.responseMessage)

        // GIVEN
        let voidExpectation = expectation(description: "PH Void Expectation")
        var voidResult: Transaction?
        var voidError: Error?

        // WHEN
        saleResult?.reverse(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                voidResult = $0
                voidError = $1
                voidExpectation.fulfill()
            }

        // THEN
        wait(for: [voidExpectation], timeout: 10.0)
        XCTAssertNil(voidError)
        XCTAssertNotNil(voidResult)
        XCTAssertEqual(EXPECTED_CODE, voidResult?.responseCode)
        XCTAssertEqual(TransactionStatus.reversed.rawValue, voidResult?.responseMessage)
    }

    func test_ph_void_mastercard() {
        // GIVEN
        let saleExpectation = expectation(description: "PH Sale Mastercard Expectation")
        var saleResult: Transaction?
        var saleError: Error?

        // WHEN
        mastercardCard.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                saleResult = $0
                saleError = $1
                saleExpectation.fulfill()
            }

        // THEN
        wait(for: [saleExpectation], timeout: 10.0)
        XCTAssertNil(saleError)
        XCTAssertNotNil(saleResult)
        XCTAssertEqual(EXPECTED_CODE, saleResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, saleResult?.responseMessage)

        // GIVEN
        let voidExpectation = expectation(description: "PH Void Mastercard Expectation")
        var voidResult: Transaction?
        var voidError: Error?

        // WHEN
        saleResult?.reverse(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                voidResult = $0
                voidError = $1
                voidExpectation.fulfill()
            }

        // THEN
        wait(for: [voidExpectation], timeout: 10.0)
        XCTAssertNil(voidError)
        XCTAssertNotNil(voidResult)
        XCTAssertEqual(EXPECTED_CODE, voidResult?.responseCode)
        XCTAssertEqual(TransactionStatus.reversed.rawValue, voidResult?.responseMessage)
    }

    // MARK: - 6. Auth Reversal

    func test_ph_auth_reversal_visa() {
        // GIVEN
        let authExpectation = expectation(description: "PH Auth Expectation")
        var authResult: Transaction?
        var authError: Error?

        // WHEN
        visaCard.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                authResult = $0
                authError = $1
                authExpectation.fulfill()
            }

        // THEN
        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertNil(authError)
        XCTAssertNotNil(authResult)
        XCTAssertEqual(EXPECTED_CODE, authResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, authResult?.responseMessage)

        // GIVEN
        let reversalExpectation = expectation(description: "PH Auth Reversal Expectation")
        var reversalResult: Transaction?
        var reversalError: Error?

        // WHEN
        authResult?.reverse(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                reversalResult = $0
                reversalError = $1
                reversalExpectation.fulfill()
            }

        // THEN
        wait(for: [reversalExpectation], timeout: 10.0)
        XCTAssertNil(reversalError)
        XCTAssertNotNil(reversalResult)
        XCTAssertEqual(EXPECTED_CODE, reversalResult?.responseCode)
        XCTAssertEqual(TransactionStatus.reversed.rawValue, reversalResult?.responseMessage)
    }

    func test_ph_auth_reversal_mastercard() {
        // GIVEN
        let authExpectation = expectation(description: "PH Auth Mastercard Expectation")
        var authResult: Transaction?
        var authError: Error?

        // WHEN
        mastercardCard.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                authResult = $0
                authError = $1
                authExpectation.fulfill()
            }

        // THEN
        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertNil(authError)
        XCTAssertNotNil(authResult)
        XCTAssertEqual(EXPECTED_CODE, authResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, authResult?.responseMessage)

        // GIVEN
        let reversalExpectation = expectation(description: "PH Auth Reversal Mastercard Expectation")
        var reversalResult: Transaction?
        var reversalError: Error?

        // WHEN
        authResult?.reverse(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                reversalResult = $0
                reversalError = $1
                reversalExpectation.fulfill()
            }

        // THEN
        wait(for: [reversalExpectation], timeout: 10.0)
        XCTAssertNil(reversalError)
        XCTAssertNotNil(reversalResult)
        XCTAssertEqual(EXPECTED_CODE, reversalResult?.responseCode)
        XCTAssertEqual(TransactionStatus.reversed.rawValue, reversalResult?.responseMessage)
    }

    // MARK: - 7. Refund

    func test_ph_refund_visa() {
        // GIVEN
        let saleExpectation = expectation(description: "PH Sale Visa Expectation")
        var saleResult: Transaction?
        var saleError: Error?

        // WHEN
        visaCard.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                saleResult = $0
                saleError = $1
                saleExpectation.fulfill()
            }

        // THEN
        wait(for: [saleExpectation], timeout: 10.0)
        XCTAssertNil(saleError)
        XCTAssertNotNil(saleResult)
        XCTAssertEqual(EXPECTED_CODE, saleResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, saleResult?.responseMessage)

        // GIVEN
        let refundExpectation = expectation(description: "PH Refund Visa Expectation")
        var refundResult: Transaction?
        var refundError: Error?

        // WHEN
        saleResult?.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                refundResult = $0
                refundError = $1
                refundExpectation.fulfill()
            }

        // THEN
        wait(for: [refundExpectation], timeout: 10.0)
        XCTAssertNil(refundError)
        XCTAssertNotNil(refundResult)
        XCTAssertEqual(EXPECTED_CODE, refundResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.mapped(for: .gpApi), refundResult?.responseMessage)
    }

    func test_ph_refund_mastercard() {
        // GIVEN
        let saleExpectation = expectation(description: "PH Sale Mastercard Expectation")
        var saleResult: Transaction?
        var saleError: Error?

        // WHEN
        mastercardCard.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                saleResult = $0
                saleError = $1
                saleExpectation.fulfill()
            }

        // THEN
        wait(for: [saleExpectation], timeout: 10.0)
        XCTAssertNil(saleError)
        XCTAssertNotNil(saleResult)
        XCTAssertEqual(EXPECTED_CODE, saleResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, saleResult?.responseMessage)

        // GIVEN
        let refundExpectation = expectation(description: "PH Refund Mastercard Expectation")
        var refundResult: Transaction?
        var refundError: Error?

        // WHEN
        saleResult?.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                refundResult = $0
                refundError = $1
                refundExpectation.fulfill()
            }

        // THEN
        wait(for: [refundExpectation], timeout: 10.0)
        XCTAssertNil(refundError)
        XCTAssertNotNil(refundResult)
        XCTAssertEqual(EXPECTED_CODE, refundResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.mapped(for: .gpApi), refundResult?.responseMessage)
    }

    // MARK: - 8. Partial Capture through VT

    func test_ph_partial_capture_visa() {
        let partialAmount: NSDecimalNumber = 5.00

        // GIVEN
        let authExpectation = expectation(description: "PH Auth Expectation")
        var authResult: Transaction?
        var authError: Error?

        // WHEN
        visaCard.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                authResult = $0
                authError = $1
                authExpectation.fulfill()
            }

        // THEN
        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertNil(authError)
        XCTAssertNotNil(authResult)
        XCTAssertEqual(EXPECTED_CODE, authResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, authResult?.responseMessage)

        // GIVEN
        let captureExpectation = expectation(description: "PH Partial Capture Expectation")
        var captureResult: Transaction?
        var captureError: Error?

        // WHEN
        authResult?.capture(amount: partialAmount)
            .execute {
                captureResult = $0
                captureError = $1
                captureExpectation.fulfill()
            }

        // THEN
        wait(for: [captureExpectation], timeout: 10.0)
        XCTAssertNil(captureError)
        XCTAssertNotNil(captureResult)
        XCTAssertEqual(EXPECTED_CODE, captureResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, captureResult?.responseMessage)
    }

    func test_ph_partial_capture_mastercard() {
        let partialAmount: NSDecimalNumber = 5.00

        // GIVEN
        let authExpectation = expectation(description: "PH Auth Mastercard Expectation")
        var authResult: Transaction?
        var authError: Error?

        // WHEN
        mastercardCard.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                authResult = $0
                authError = $1
                authExpectation.fulfill()
            }

        // THEN
        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertNil(authError)
        XCTAssertNotNil(authResult)
        XCTAssertEqual(EXPECTED_CODE, authResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, authResult?.responseMessage)

        // GIVEN
        let captureExpectation = expectation(description: "PH Partial Capture Mastercard Expectation")
        var captureResult: Transaction?
        var captureError: Error?

        // WHEN
        authResult?.capture(amount: partialAmount)
            .execute {
                captureResult = $0
                captureError = $1
                captureExpectation.fulfill()
            }

        // THEN
        wait(for: [captureExpectation], timeout: 10.0)
        XCTAssertNil(captureError)
        XCTAssertNotNil(captureResult)
        XCTAssertEqual(EXPECTED_CODE, captureResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, captureResult?.responseMessage)
    }


    // MARK: - 9. Manual Key-In Transaction (MOTO)

    func test_ph_moto_visa() {
        // GIVEN
        visaCard.entryMethod = .MOTO

        let motoExpectation = expectation(description: "PH MOTO Visa Expectation")
        var motoResult: Transaction?
        var motoError: Error?

        // WHEN
        visaCard.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                motoResult = $0
                motoError = $1
                motoExpectation.fulfill()
            }

        // THEN
        wait(for: [motoExpectation], timeout: 10.0)
        XCTAssertNil(motoError)
        XCTAssertNotNil(motoResult)
        XCTAssertEqual(EXPECTED_CODE, motoResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, motoResult?.responseMessage)
    }

    func test_ph_moto_mastercard() {
        // GIVEN
        mastercardCard.entryMethod = .MOTO

        let motoExpectation = expectation(description: "PH MOTO Mastercard Expectation")
        var motoResult: Transaction?
        var motoError: Error?

        // WHEN
        mastercardCard.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                motoResult = $0
                motoError = $1
                motoExpectation.fulfill()
            }

        // THEN
        wait(for: [motoExpectation], timeout: 10.0)
        XCTAssertNil(motoError)
        XCTAssertNotNil(motoResult)
        XCTAssertEqual(EXPECTED_CODE, motoResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, motoResult?.responseMessage)
    }
}
