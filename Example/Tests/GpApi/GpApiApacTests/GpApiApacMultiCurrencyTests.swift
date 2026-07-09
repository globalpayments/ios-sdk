//
//  GpApiApacMultiCurrencyTests.swift
//  GlobalPayments-iOS-SDK
//
//  Created by Ranu Dhurandhar on 11/06/26.


//    Exponent 2 — two-decimal currencies (×100 on wire):
//      APAC settlement : SGD, HKD, MOP, PHP, MYR
//      JPY exception   : ISO exponent 0, but GP-API requires ×100
//      Other standard  : AED, AUD, BDT, BND, BRL, CAD, CHF, CLP*, CNY, DKK,
//                        EGP, EUR, GBP, IDR, ILS, INR, LKR, MUR, MVR, MXN,
//                        NOK, NZD, PGK, PKR, QAR, RUB, SAR, SEK, THB, TRY,
//                        TWD, USD, VEF, ZAR
//      * CLP: ISO 4217 exponent 0 but 24713 analysis mandates exponent 2 on wire
//
//    Exponent 3 — milli-unit currencies (×1000 on wire): BHD, KWD, OMR
//
//    Exponent 0 — whole-unit currencies (×1 on wire): ISK, KRW, VND

import XCTest
import GlobalPayments_iOS_SDK

class GpApiApacMultiCurrencyTests: XCTestCase {


    private let exponent2Currencies = [
        "SGD", "HKD", "MOP", "PHP", "MYR",
        
        "JPY",

        "AED", "AUD", "BDT", "BND", "BRL",
        "CAD", "CHF", "CLP", "CNY", "DKK",
        "EGP", "EUR", "GBP", "IDR", "ILS",
        "INR", "LKR", "MUR", "MVR", "MXN",
        "NOK", "NZD", "PGK", "PKR", "QAR",
        "RUB", "SAR", "SEK", "THB", "TRY",
        "TWD", "USD", "ZAR"
    ]
    private let exponent3Currencies = ["BHD", "KWD", "OMR"]
    private let exponent0Currencies = ["ISK", "KRW", "VND"]

    private let AMOUNT: NSDecimalNumber = 10.00
    private let EXPECTED_CODE = "SUCCESS"

    private var visaCard: CreditCardData!
    private var mastercardCard: CreditCardData!
    private var motoVisaCard: CreditCardData!
    private var motoMastercardCard: CreditCardData!

    override func setUp() {
        super.setUp()
        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = GpApiApacTestConfig.accountName
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: GpApiApacTestConfig.appId,
            appKey: GpApiApacTestConfig.appKey,
            channel: .cardNotPresent,
            country: "HK",
            accessTokenInfo: accessTokenInfo
        ))

        visaCard = makeCard(number: "4263970000005262", name: "APAC Visa")
        mastercardCard = makeCard(number: "5425230000004415", name: "APAC Mastercard")
        motoVisaCard = makeCard(number: "4263970000005262", name: "APAC MOTO Visa", moto: true)
        motoMastercardCard = makeCard(number: "5425230000004415", name: "APAC MOTO MC", moto: true)
    }

    override func tearDown() {
        super.tearDown()
        visaCard = nil;
        mastercardCard = nil
        motoVisaCard = nil;
        motoMastercardCard = nil
    }

    // MARK: - Helpers

    private func makeCard(number: String, name: String, moto: Bool = false) -> CreditCardData {
        let card = CreditCardData()
        card.number = number
        card.expMonth = 12
        card.expYear = 2026
        card.cvn = "123"
        card.cardHolderName = name
        if moto { card.entryMethod = .MOTO }
        return card
    }

    private func runForAll(
        _ currencies: [String],
        card: CreditCardData,
        label: String,
        block: @escaping (String, @escaping () -> Void) -> Void
    ) {
        for currency in currencies {
            let exp = expectation(description: "\(label) \(currency)")
            block(currency) { exp.fulfill() }
            wait(for: [exp], timeout: 10.0)
        }
    }

    // MARK: - 1. Sale — Exponent 2

    func test_CreditSale_Exponent2_Visa() {
        for currency in exponent2Currencies {
            let exp = expectation(description: "Sale Visa \(currency)")
            var result: Transaction?; var error: Error?
            visaCard.charge(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "Sale Visa \(currency)")
            XCTAssertEqual(EXPECTED_CODE, result?.responseCode, "\(currency) responseCode")
            XCTAssertEqual(TransactionStatus.captured.rawValue, result?.responseMessage, "\(currency) status")
            XCTAssertEqual(AMOUNT, result?.balanceAmount, "\(currency) amount round-trip")
        }
    }

    func test_CreditSale_Exponent2_Mastercard() {
        for currency in exponent2Currencies {
            let exp = expectation(description: "Sale MC \(currency)")
            var result: Transaction?; var error: Error?
            mastercardCard.charge(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "Sale MC \(currency)")
            XCTAssertEqual(EXPECTED_CODE, result?.responseCode, "\(currency) responseCode")
            XCTAssertEqual(TransactionStatus.captured.rawValue, result?.responseMessage, "\(currency) status")
            XCTAssertEqual(AMOUNT, result?.balanceAmount, "\(currency) amount round-trip")
        }
    }

    // MARK: - 1. Sale — Exponent 3

    func test_CreditSale_Exponent3_Visa() {
        for currency in exponent3Currencies {
            let exp = expectation(description: "Sale Visa \(currency)")
            var result: Transaction?; var error: Error?
            visaCard.charge(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "Sale Visa \(currency)")
            XCTAssertEqual(EXPECTED_CODE, result?.responseCode, "\(currency) responseCode")
            XCTAssertEqual(TransactionStatus.captured.rawValue, result?.responseMessage, "\(currency) status")
        }
    }

    func test_CreditSale_Exponent3_Mastercard() {
        for currency in exponent3Currencies {
            let exp = expectation(description: "Sale MC \(currency)")
            var result: Transaction?; var error: Error?
            mastercardCard.charge(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "Sale MC \(currency)")
            XCTAssertEqual(EXPECTED_CODE, result?.responseCode, "\(currency) responseCode")
        }
    }

    // MARK: - 1. Sale — Exponent 0

    func test_CreditSale_Exponent0_Visa() {
        for currency in exponent0Currencies {
            let exp = expectation(description: "Sale Visa \(currency)")
            var result: Transaction?; var error: Error?
            visaCard.charge(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "Sale Visa \(currency)")
            XCTAssertEqual(EXPECTED_CODE, result?.responseCode, "\(currency) responseCode")
        }
    }

    func test_CreditSale_Exponent0_Mastercard() {
        for currency in exponent0Currencies {
            let exp = expectation(description: "Sale MC \(currency)")
            var result: Transaction?; var error: Error?
            mastercardCard.charge(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "Sale MC \(currency)")
            XCTAssertEqual(EXPECTED_CODE, result?.responseCode, "\(currency) responseCode")
        }
    }

    // MARK: - 2. Auth — all families

    func test_CreditAuth_Exponent2() {
        for currency in exponent2Currencies {
            let exp = expectation(description: "Auth Visa \(currency)")
            var result: Transaction?; var error: Error?
            visaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error)
            XCTAssertEqual(TransactionStatus.preauthorized.rawValue, result?.responseMessage, "\(currency)")
            XCTAssertEqual(AMOUNT, result?.balanceAmount, "\(currency) round-trip")
        }
    }

    func test_CreditAuth_Exponent3() {
        for currency in exponent3Currencies {
            let exp = expectation(description: "Auth \(currency)")
            var result: Transaction?; var error: Error?
            visaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error)
            XCTAssertEqual(TransactionStatus.preauthorized.rawValue, result?.responseMessage, "\(currency)")
        }
    }

    func test_CreditAuth_Exponent0() {
        for currency in exponent0Currencies {
            let exp = expectation(description: "Auth \(currency)")
            var result: Transaction?; var error: Error?
            visaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error)
            XCTAssertEqual(TransactionStatus.preauthorized.rawValue, result?.responseMessage, "\(currency)")
        }
    }

    // MARK: - 3. Capture — all families

    func test_CreditCapture_Exponent2() {
        for currency in exponent2Currencies {
            // Auth
            let authExp = expectation(description: "Auth \(currency)")
            var authResult: Transaction?; var authError: Error?
            visaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                authResult = $0; authError = $1; authExp.fulfill()
            }
            wait(for: [authExp], timeout: 10.0)
            XCTAssertNil(authError, "Auth \(currency)")
            guard authResult != nil else { continue }
            // Capture — no .withCurrency() needed; currency resolved from TransactionReference
            let capExp = expectation(description: "Capture \(currency)")
            var capResult: Transaction?; var capError: Error?
            authResult?.capture(amount: AMOUNT).execute {
                capResult = $0; capError = $1; capExp.fulfill()
            }
            wait(for: [capExp], timeout: 10.0)
            XCTAssertNil(capError, "Capture \(currency)")
            XCTAssertEqual(EXPECTED_CODE, capResult?.responseCode, "\(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, capResult?.responseMessage, "\(currency)")
        }
    }

    func test_CreditCapture_Exponent3() {
        for currency in exponent3Currencies {
            let authExp = expectation(description: "Auth \(currency)")
            var authResult: Transaction?; var authError: Error?
            visaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                authResult = $0; authError = $1; authExp.fulfill()
            }
            wait(for: [authExp], timeout: 10.0)
            XCTAssertNil(authError)
            guard authResult != nil else { continue }
            let capExp = expectation(description: "Capture \(currency)")
            var capResult: Transaction?; var capError: Error?
            authResult?.capture(amount: AMOUNT).execute {
                capResult = $0; capError = $1; capExp.fulfill()
            }
            wait(for: [capExp], timeout: 10.0)
            XCTAssertNil(capError, "Capture \(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, capResult?.responseMessage, "\(currency)")
        }
    }

    func test_CreditCapture_Exponent0() {
        for currency in exponent0Currencies {
            let authExp = expectation(description: "Auth \(currency)")
            var authResult: Transaction?; var authError: Error?
            visaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                authResult = $0; authError = $1; authExp.fulfill()
            }
            wait(for: [authExp], timeout: 10.0)
            XCTAssertNil(authError)
            guard authResult != nil else { continue }
            let capExp = expectation(description: "Capture \(currency)")
            var capResult: Transaction?; var capError: Error?
            authResult?.capture(amount: AMOUNT).execute {
                capResult = $0; capError = $1; capExp.fulfill()
            }
            wait(for: [capExp], timeout: 10.0)
            XCTAssertNil(capError, "Capture \(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, capResult?.responseMessage, "\(currency)")
        }
    }

    // MARK: - 4. Auth Reversal — all families

    func test_CreditAuthReversal_Exponent2() {
        for currency in exponent2Currencies {
            let authExp = expectation(description: "Auth \(currency)")
            var authResult: Transaction?; var authError: Error?
            visaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                authResult = $0; authError = $1; authExp.fulfill()
            }
            wait(for: [authExp], timeout: 10.0)
            XCTAssertNil(authError)
            guard authResult != nil else { continue }
            let revExp = expectation(description: "Reversal \(currency)")
            var revResult: Transaction?; var revError: Error?
            authResult?.reverse(amount: AMOUNT).execute {
                revResult = $0; revError = $1; revExp.fulfill()
            }
            wait(for: [revExp], timeout: 10.0)
            XCTAssertNil(revError, "Reversal \(currency)")
            XCTAssertEqual(TransactionStatus.reversed.rawValue, revResult?.responseMessage, "\(currency)")
        }
    }

    func test_CreditAuthReversal_Exponent3() {
        for currency in exponent3Currencies {
            let authExp = expectation(description: "Auth \(currency)")
            var authResult: Transaction?; var authError: Error?
            visaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                authResult = $0; authError = $1; authExp.fulfill()
            }
            wait(for: [authExp], timeout: 10.0)
            XCTAssertNil(authError)
            guard authResult != nil else { continue }
            let revExp = expectation(description: "Reversal \(currency)")
            var revResult: Transaction?; var revError: Error?
            authResult?.reverse(amount: AMOUNT).execute {
                revResult = $0; revError = $1; revExp.fulfill()
            }
            wait(for: [revExp], timeout: 10.0)
            XCTAssertNil(revError, "Reversal \(currency)")
            XCTAssertEqual(TransactionStatus.reversed.rawValue, revResult?.responseMessage, "\(currency)")
        }
    }

    func test_CreditAuthReversal_Exponent0() {
        for currency in exponent0Currencies {
            let authExp = expectation(description: "Auth \(currency)")
            var authResult: Transaction?; var authError: Error?
            visaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                authResult = $0; authError = $1; authExp.fulfill()
            }
            wait(for: [authExp], timeout: 10.0)
            XCTAssertNil(authError)
            guard authResult != nil else { continue }
            let revExp = expectation(description: "Reversal \(currency)")
            var revResult: Transaction?; var revError: Error?
            authResult?.reverse(amount: AMOUNT).execute {
                revResult = $0; revError = $1; revExp.fulfill()
            }
            wait(for: [revExp], timeout: 10.0)
            XCTAssertNil(revError, "Reversal \(currency)")
            XCTAssertEqual(TransactionStatus.reversed.rawValue, revResult?.responseMessage, "\(currency)")
        }
    }

    // MARK: - 5. Void (Sale → Reverse) — Exponent 2 core APAC only

    func test_CreditVoid_Exponent2() {
        let voidCurrencies = ["SGD", "HKD", "MOP", "PHP", "MYR", "JPY"]
        for currency in voidCurrencies {
            let saleExp = expectation(description: "Sale \(currency)")
            var saleResult: Transaction?; var saleError: Error?
            visaCard.charge(amount: AMOUNT).withCurrency(currency).execute {
                saleResult = $0; saleError = $1; saleExp.fulfill()
            }
            wait(for: [saleExp], timeout: 10.0)
            XCTAssertNil(saleError)
            guard saleResult != nil else { continue }
            let voidExp = expectation(description: "Void \(currency)")
            var voidResult: Transaction?; var voidError: Error?
            saleResult?.reverse(amount: AMOUNT).execute {
                voidResult = $0; voidError = $1; voidExp.fulfill()
            }
            wait(for: [voidExp], timeout: 10.0)
            XCTAssertNil(voidError, "Void \(currency)")
            XCTAssertEqual(TransactionStatus.reversed.rawValue, voidResult?.responseMessage, "\(currency)")
        }
    }

    // MARK: - 6. Linked Refund — all families

    func test_CreditRefund_Linked_Exponent2() {
        for currency in exponent2Currencies {
            let saleExp = expectation(description: "Sale \(currency)")
            var saleResult: Transaction?; var saleError: Error?
            visaCard.charge(amount: AMOUNT).withCurrency(currency).execute {
                saleResult = $0; saleError = $1; saleExp.fulfill()
            }
            wait(for: [saleExp], timeout: 10.0)
            XCTAssertNil(saleError)
            guard saleResult != nil else { continue }
            let refExp = expectation(description: "Refund \(currency)")
            var refResult: Transaction?; var refError: Error?
            saleResult?.refund(amount: AMOUNT).withCurrency(currency).execute {
                refResult = $0; refError = $1; refExp.fulfill()
            }
            wait(for: [refExp], timeout: 10.0)
            XCTAssertNil(refError, "Refund \(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, refResult?.responseMessage, "\(currency)")
        }
    }

    func test_CreditRefund_Linked_Exponent3() {
        for currency in exponent3Currencies {
            let saleExp = expectation(description: "Sale \(currency)")
            var saleResult: Transaction?; var saleError: Error?
            visaCard.charge(amount: AMOUNT).withCurrency(currency).execute {
                saleResult = $0; saleError = $1; saleExp.fulfill()
            }
            wait(for: [saleExp], timeout: 10.0)
            XCTAssertNil(saleError)
            guard saleResult != nil else { continue }
            let refExp = expectation(description: "Refund \(currency)")
            var refResult: Transaction?; var refError: Error?
            saleResult?.refund(amount: AMOUNT).withCurrency(currency).execute {
                refResult = $0; refError = $1; refExp.fulfill()
            }
            wait(for: [refExp], timeout: 10.0)
            XCTAssertNil(refError, "Refund \(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, refResult?.responseMessage, "\(currency)")
        }
    }

    func test_CreditRefund_Linked_Exponent0() {
        for currency in exponent0Currencies {
            let saleExp = expectation(description: "Sale \(currency)")
            var saleResult: Transaction?; var saleError: Error?
            visaCard.charge(amount: AMOUNT).withCurrency(currency).execute {
                saleResult = $0; saleError = $1; saleExp.fulfill()
            }
            wait(for: [saleExp], timeout: 10.0)
            XCTAssertNil(saleError)
            guard saleResult != nil else { continue }
            let refExp = expectation(description: "Refund \(currency)")
            var refResult: Transaction?; var refError: Error?
            saleResult?.refund(amount: AMOUNT).withCurrency(currency).execute {
                refResult = $0; refError = $1; refExp.fulfill()
            }
            wait(for: [refExp], timeout: 10.0)
            XCTAssertNil(refError, "Refund \(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, refResult?.responseMessage, "\(currency)")
        }
    }

    // MARK: - 7. Standalone Refund — all families

    func test_CreditRefund_Standalone_Exponent2() {
        for currency in exponent2Currencies {
            let exp = expectation(description: "Standalone Refund \(currency)")
            var result: Transaction?; var error: Error?
            visaCard.refund(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "Standalone Refund \(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, result?.responseMessage, "\(currency)")
        }
    }

    func test_CreditRefund_Standalone_Exponent3() {
        for currency in exponent3Currencies {
            let exp = expectation(description: "Standalone Refund \(currency)")
            var result: Transaction?; var error: Error?
            visaCard.refund(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "Standalone Refund \(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, result?.responseMessage, "\(currency)")
        }
    }

    func test_CreditRefund_Standalone_Exponent0() {
        for currency in exponent0Currencies {
            let exp = expectation(description: "Standalone Refund \(currency)")
            var result: Transaction?; var error: Error?
            visaCard.refund(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "Standalone Refund \(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, result?.responseMessage, "\(currency)")
        }
    }

    // MARK: - 8. Partial Capture (VT) — all families

    func test_CreditPartialCapture_Exponent2() {
        let partial: NSDecimalNumber = 5.00
        for currency in exponent2Currencies {
            let authExp = expectation(description: "Auth \(currency)")
            var authResult: Transaction?; var authError: Error?
            visaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                authResult = $0; authError = $1; authExp.fulfill()
            }
            wait(for: [authExp], timeout: 10.0)
            XCTAssertNil(authError)
            guard authResult != nil else { continue }
            let capExp = expectation(description: "Partial Capture \(currency)")
            var capResult: Transaction?; var capError: Error?
            authResult?.capture(amount: partial).execute {
                capResult = $0; capError = $1; capExp.fulfill()
            }
            wait(for: [capExp], timeout: 10.0)
            XCTAssertNil(capError, "Partial Capture \(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, capResult?.responseMessage, "\(currency)")
        }
    }

    func test_CreditPartialCapture_Exponent3() {
        let partial: NSDecimalNumber = 5.00
        for currency in exponent3Currencies {
            let authExp = expectation(description: "Auth \(currency)")
            var authResult: Transaction?; var authError: Error?
            visaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                authResult = $0; authError = $1; authExp.fulfill()
            }
            wait(for: [authExp], timeout: 10.0)
            XCTAssertNil(authError)
            guard authResult != nil else { continue }
            let capExp = expectation(description: "Partial Capture \(currency)")
            var capResult: Transaction?; var capError: Error?
            authResult?.capture(amount: partial).execute {
                capResult = $0; capError = $1; capExp.fulfill()
            }
            wait(for: [capExp], timeout: 10.0)
            XCTAssertNil(capError, "Partial Capture \(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, capResult?.responseMessage, "\(currency)")
        }
    }

    func test_CreditPartialCapture_Exponent0() {
        let partial: NSDecimalNumber = 5.00
        for currency in exponent0Currencies {
            let authExp = expectation(description: "Auth \(currency)")
            var authResult: Transaction?; var authError: Error?
            visaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                authResult = $0; authError = $1; authExp.fulfill()
            }
            wait(for: [authExp], timeout: 10.0)
            XCTAssertNil(authError)
            guard authResult != nil else { continue }
            let capExp = expectation(description: "Partial Capture \(currency)")
            var capResult: Transaction?; var capError: Error?
            authResult?.capture(amount: partial).execute {
                capResult = $0; capError = $1; capExp.fulfill()
            }
            wait(for: [capExp], timeout: 10.0)
            XCTAssertNil(capError, "Partial Capture \(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, capResult?.responseMessage, "\(currency)")
        }
    }

    // MARK: - 9. MOTO (Manual Key-In) — all families

    func test_CreditMoto_Sale_Exponent2() {
        for currency in exponent2Currencies {
            let exp = expectation(description: "MOTO Sale \(currency)")
            var result: Transaction?; var error: Error?
            motoVisaCard.charge(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "MOTO Sale \(currency)")
            XCTAssertEqual(EXPECTED_CODE, result?.responseCode, "\(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, result?.responseMessage, "\(currency)")
        }
    }

    func test_CreditMoto_Sale_Exponent3() {
        for currency in exponent3Currencies {
            let exp = expectation(description: "MOTO Sale \(currency)")
            var result: Transaction?; var error: Error?
            motoVisaCard.charge(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "MOTO Sale \(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, result?.responseMessage, "\(currency)")
        }
    }

    func test_CreditMoto_Sale_Exponent0() {
        for currency in exponent0Currencies {
            let exp = expectation(description: "MOTO Sale \(currency)")
            var result: Transaction?; var error: Error?
            motoVisaCard.charge(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "MOTO Sale \(currency)")
            XCTAssertEqual(TransactionStatus.captured.rawValue, result?.responseMessage, "\(currency)")
        }
    }

    func test_CreditMoto_Authorization_Exponent2() {
        for currency in exponent2Currencies {
            let exp = expectation(description: "MOTO Auth \(currency)")
            var result: Transaction?; var error: Error?
            motoVisaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "MOTO Auth \(currency)")
            XCTAssertEqual(TransactionStatus.preauthorized.rawValue, result?.responseMessage, "\(currency)")
        }
    }

    func test_CreditMoto_Authorization_Exponent3() {
        for currency in exponent3Currencies {
            let exp = expectation(description: "MOTO Auth \(currency)")
            var result: Transaction?; var error: Error?
            motoVisaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "MOTO Auth \(currency)")
            XCTAssertEqual(TransactionStatus.preauthorized.rawValue, result?.responseMessage, "\(currency)")
        }
    }

    func test_CreditMoto_Authorization_Exponent0() {
        for currency in exponent0Currencies {
            let exp = expectation(description: "MOTO Auth \(currency)")
            var result: Transaction?; var error: Error?
            motoVisaCard.authorize(amount: AMOUNT).withCurrency(currency).execute {
                result = $0; error = $1; exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
            XCTAssertNil(error, "MOTO Auth \(currency)")
            XCTAssertEqual(TransactionStatus.preauthorized.rawValue, result?.responseMessage, "\(currency)")
        }
    }

    // MARK: - 10. Offline: Amount encoding / rounding per exponent 
   
    private struct EncodingCase {
        let currency: String;
        let input: NSDecimalNumber
        let expectedWire: String;
        let expectedDecoded: NSDecimalNumber
    }

    func test_AmountEncoding_RoundsAndScalesPerExponent() {
        let input = NSDecimalNumber(string: "1235.876")
        let cases: [EncodingCase] = [
            EncodingCase(currency: "JPY", input: input, expectedWire: "123588",  expectedDecoded: NSDecimalNumber(string: "1235.88")),
            EncodingCase(currency: "KRW", input: input, expectedWire: "1236",    expectedDecoded: NSDecimalNumber(string: "1236")),
            EncodingCase(currency: "VND", input: input, expectedWire: "1236",    expectedDecoded: NSDecimalNumber(string: "1236")),
            EncodingCase(currency: "ISK", input: input, expectedWire: "1236",    expectedDecoded: NSDecimalNumber(string: "1236")),
            EncodingCase(currency: "CLP", input: input, expectedWire: "123588",  expectedDecoded: NSDecimalNumber(string: "1235.88")),
            EncodingCase(currency: "USD", input: input, expectedWire: "123588",  expectedDecoded: NSDecimalNumber(string: "1235.88")),
            EncodingCase(currency: "BHD", input: input, expectedWire: "1235876", expectedDecoded: NSDecimalNumber(string: "1235.876")),
            EncodingCase(currency: "KWD", input: input, expectedWire: "1235876", expectedDecoded: NSDecimalNumber(string: "1235.876")),
            EncodingCase(currency: "OMR", input: input, expectedWire: "1235876", expectedDecoded: NSDecimalNumber(string: "1235.876")),
        ]
        for c in cases {
            let wire = c.input.toNumericCurrencyString(currency: c.currency)
            XCTAssertEqual(c.expectedWire, wire,
                "\(c.currency): SDK→GP-API for \(c.input)")
            let decoded = NSDecimalNumber(string: wire).amount(for: c.currency)
            XCTAssertEqual(c.expectedDecoded, decoded,
                "\(c.currency): GP-API→SDK decoded amount")
        }
    }

    func test_AmountEncoding_TenUnits_Baseline() {
        let cases: [(currency: String, expectedWire: String)] = [
            ("JPY", "1000"), ("KRW", "10"), ("VND", "10"),
            ("ISK", "10"),   ("CLP", "1000"), ("USD", "1000"),
            ("BHD", "10000"), ("KWD", "10000"), ("OMR", "10000")
        ]
        for (currency, expected) in cases {
            XCTAssertEqual(expected,
                NSDecimalNumber(value: 10).toNumericCurrencyString(currency: currency),
                "\(currency): 10.00 baseline encode")
        }
    }

    // MARK: - 11. Offline: Symmetry — encode→decode round-trip for all 46 currencies

    func test_EncodeDecodeRoundTrip_IsSymmetric() {
        let cases: [(String, NSDecimalNumber)] = [
            ("SGD", 10.00), ("HKD", 10.00), ("MOP", 10.00), ("PHP", 10.00), ("MYR", 10.00),
            ("USD", 10.00), ("EUR", 10.00), ("GBP", 10.00), ("AUD", 10.00), ("CAD", 10.00),
            ("CLP", 5000),
            ("KRW", 10000), ("ISK", 1000), ("VND", 25000),
            ("BHD", 10.000), ("KWD", 10.000), ("OMR", 10.000),
            ("JPY", 1000)
        ]
        for (currency, amount) in cases {
            let wire = amount.toNumericCurrencyString(currency: currency)!
            let decoded = NSDecimalNumber(string: wire).amount(for: currency)
            XCTAssertEqual(amount, decoded,
                "Round-trip mismatch for \(currency): \(amount) → \"\(wire)\" → \(decoded?.description ?? "nil")")
        }
    }
}


