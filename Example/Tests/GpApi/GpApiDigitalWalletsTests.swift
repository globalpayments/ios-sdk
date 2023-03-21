import XCTest
import GlobalPayments_iOS_SDK

class GpApiDigitalWalletsTests: XCTestCase {
    
    var card: CreditCardData!

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc",
            appKey: "DYcEE2GpSzblo0ib",
            channel: .cardNotPresent
        ))
    }
    
    override func setUp() {
        super.setUp()

        card = CreditCardData()
        card.cardHolderName = "James Mason#"
    }

    override func tearDown() {
        super.tearDown()

        card = nil
    }
    
    func test_pay_with_decrypted_flow() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var chargeResult: Transaction?
        var chargeStatus: String?
        var chargeError: Error?

        // WHEN
        card.token = "5167300431085507"
        card.mobileType = EncryptedMobileType.APPLE_PAY.rawValue
        card.expMonth = 05
        card.expYear = 2025
        card.cryptogram = "234234234"
        
        card.charge(amount: 5)
            .withCurrency("GBP")
            .withModifier(.decryptedMobile)
            .execute {
                chargeResult = $0
                chargeError = $1
                chargeStatus = $0?.responseMessage
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10)
        XCTAssertNil(chargeError)
        XCTAssertNotNil(chargeResult)
        XCTAssertNotNil(chargeStatus)
        XCTAssertEqual(chargeResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeStatus, TransactionStatus.captured.rawValue)
    }
    
    func test_pay_with_google_pay_encrypted() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var chargeResult: Transaction?
        var chargeStatus: String?
        var chargeError: Error?
        
        // WHEN
        card.token = "{\n" +
        "  \"signature\": \"MEYCIQCnOVaiKh1MRALbQI+uG0xHmjNs7D7KuDPNDbpV/r+DLwIhAJ3M6G+4cz0vguZOmbRfGIr1buBhztwRQoXx1Q6x5mDS\",\n" +
        "  \"protocolVersion\": \"ECv1\",\n" +
        "  \"signedMessage\": \"{\\\"encryptedMessage\\\":\\\"UZ23TYSU6BEKL4oeyOUIpFQ6319ou8kYlIha03CSTTUZKni9xePI6Bwpb+xb3sl2Ri2j6V/2UIGZNkC4315P0+N3VZE1Au7Ox/E1B9RGoQexz3cs4kYvkkDGN85xp6Z5KakbL4aYRSPynzMlGGh8lflm1H7LnSmV908CBFU/yZ3zT6LQbSSxTfhokZC+v9doev41gWc9eYPf4YikqTu0hdYTlLQR3fMOd06dIBm4GYrFchSO9xlUygT+HLY3JaZqEcI6UJqYXQUN5AOUEcJPox+B58Ys8Q0NLxF9WX0YHGsWqbgpOCymPRNHbbfN6MCtydIeQhF2xUR7ghAF8DD/dsO0Q2rQcGnlpifYT7Ew+rWiSmJ2Rjce80NYwQFeRbCJatQOF4mJY7+sck6YDea1MdtLtsvzWVE5Qa9mhhAi1pRu88Wney8qhgulcaWCoEWmKqWu\\\",\\\"ephemeralPublicKey\\\":\\\"BLd4JXUkCT+mu7N6wjCorM495NtTeipIhNvEqNmrH1iwUl3LQdV+hY0XNgo8eAKZdfsV2NvBqwgm2agiLp54bio\\\\u003d\\\",\\\"tag\\\":\\\"FeGYN3UBC8MlhKks/afFDjx4RBQnkppEzkWEkf9DCRQ\\\\u003d\\\"}\"\n" +
        "}"
        
        card.mobileType = EncryptedMobileType.GOOGLE_PAY.rawValue
        
        card.charge(amount: 10)
            .withCurrency("GBP")
            .withModifier(.encryptedMobile)
            .execute {
                chargeResult = $0
                chargeError = $1
                chargeStatus = $0?.responseMessage
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10)
        XCTAssertNil(chargeError)
        XCTAssertNotNil(chargeResult)
        XCTAssertNotNil(chargeStatus)
        XCTAssertEqual(chargeResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeStatus, TransactionStatus.captured.rawValue)
    }
    
    func test_google_pay_encrypted_linked_refund() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var creditAuthorize: Transaction?
        var chargeStatus: String?
        var chargeError: Error?
        let currency = "GBP"
        
        // WHEN
        card.token = "{\n" +
        "  \"signature\": \"MEYCIQCnOVaiKh1MRALbQI+uG0xHmjNs7D7KuDPNDbpV/r+DLwIhAJ3M6G+4cz0vguZOmbRfGIr1buBhztwRQoXx1Q6x5mDS\",\n" +
        "  \"protocolVersion\": \"ECv1\",\n" +
        "  \"signedMessage\": \"{\\\"encryptedMessage\\\":\\\"UZ23TYSU6BEKL4oeyOUIpFQ6319ou8kYlIha03CSTTUZKni9xePI6Bwpb+xb3sl2Ri2j6V/2UIGZNkC4315P0+N3VZE1Au7Ox/E1B9RGoQexz3cs4kYvkkDGN85xp6Z5KakbL4aYRSPynzMlGGh8lflm1H7LnSmV908CBFU/yZ3zT6LQbSSxTfhokZC+v9doev41gWc9eYPf4YikqTu0hdYTlLQR3fMOd06dIBm4GYrFchSO9xlUygT+HLY3JaZqEcI6UJqYXQUN5AOUEcJPox+B58Ys8Q0NLxF9WX0YHGsWqbgpOCymPRNHbbfN6MCtydIeQhF2xUR7ghAF8DD/dsO0Q2rQcGnlpifYT7Ew+rWiSmJ2Rjce80NYwQFeRbCJatQOF4mJY7+sck6YDea1MdtLtsvzWVE5Qa9mhhAi1pRu88Wney8qhgulcaWCoEWmKqWu\\\",\\\"ephemeralPublicKey\\\":\\\"BLd4JXUkCT+mu7N6wjCorM495NtTeipIhNvEqNmrH1iwUl3LQdV+hY0XNgo8eAKZdfsV2NvBqwgm2agiLp54bio\\\\u003d\\\",\\\"tag\\\":\\\"FeGYN3UBC8MlhKks/afFDjx4RBQnkppEzkWEkf9DCRQ\\\\u003d\\\"}\"\n" +
        "}"
        
        card.mobileType = EncryptedMobileType.GOOGLE_PAY.rawValue
        
        card.charge(amount: 10)
            .withCurrency("GBP")
            .withModifier(.encryptedMobile)
            .execute {
                creditAuthorize = $0
                chargeError = $1
                chargeStatus = $0?.responseMessage
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10)
        XCTAssertNil(chargeError)
        XCTAssertNotNil(creditAuthorize)
        XCTAssertNotNil(chargeStatus)
        XCTAssertEqual(creditAuthorize?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeStatus, TransactionStatus.captured.rawValue)
        
        // GIVEN
        let creditRefundExpectation = expectation(description: "Credit Refund Expectation")
        var refundResult: Transaction?
        var refundStatus: String?
        var refundError: Error?
        
        // WHEN
        creditAuthorize?.refund()
            .withCurrency(currency)
            .execute {
                refundResult = $0
                refundError = $1
                refundStatus = $0?.responseMessage
                creditRefundExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditRefundExpectation], timeout: 10.0)
        XCTAssertNotNil(refundResult)
        XCTAssertNotNil(refundStatus)
        XCTAssertNil(refundError)
        XCTAssertEqual(refundResult?.responseCode, "SUCCESS")
        XCTAssertEqual(refundResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }
    
    func test_google_pay_encrypted_reverse() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var creditAuthorize: Transaction?
        var chargeStatus: String?
        var chargeError: Error?
        let currency = "GBP"
        
        // WHEN
        card.token = "{\n" +
        "  \"signature\": \"MEYCIQCnOVaiKh1MRALbQI+uG0xHmjNs7D7KuDPNDbpV/r+DLwIhAJ3M6G+4cz0vguZOmbRfGIr1buBhztwRQoXx1Q6x5mDS\",\n" +
        "  \"protocolVersion\": \"ECv1\",\n" +
        "  \"signedMessage\": \"{\\\"encryptedMessage\\\":\\\"UZ23TYSU6BEKL4oeyOUIpFQ6319ou8kYlIha03CSTTUZKni9xePI6Bwpb+xb3sl2Ri2j6V/2UIGZNkC4315P0+N3VZE1Au7Ox/E1B9RGoQexz3cs4kYvkkDGN85xp6Z5KakbL4aYRSPynzMlGGh8lflm1H7LnSmV908CBFU/yZ3zT6LQbSSxTfhokZC+v9doev41gWc9eYPf4YikqTu0hdYTlLQR3fMOd06dIBm4GYrFchSO9xlUygT+HLY3JaZqEcI6UJqYXQUN5AOUEcJPox+B58Ys8Q0NLxF9WX0YHGsWqbgpOCymPRNHbbfN6MCtydIeQhF2xUR7ghAF8DD/dsO0Q2rQcGnlpifYT7Ew+rWiSmJ2Rjce80NYwQFeRbCJatQOF4mJY7+sck6YDea1MdtLtsvzWVE5Qa9mhhAi1pRu88Wney8qhgulcaWCoEWmKqWu\\\",\\\"ephemeralPublicKey\\\":\\\"BLd4JXUkCT+mu7N6wjCorM495NtTeipIhNvEqNmrH1iwUl3LQdV+hY0XNgo8eAKZdfsV2NvBqwgm2agiLp54bio\\\\u003d\\\",\\\"tag\\\":\\\"FeGYN3UBC8MlhKks/afFDjx4RBQnkppEzkWEkf9DCRQ\\\\u003d\\\"}\"\n" +
        "}"
        
        card.mobileType = EncryptedMobileType.GOOGLE_PAY.rawValue
        
        card.charge(amount: 10)
            .withCurrency("GBP")
            .withModifier(.encryptedMobile)
            .execute {
                creditAuthorize = $0
                chargeError = $1
                chargeStatus = $0?.responseMessage
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10)
        XCTAssertNil(chargeError)
        XCTAssertNotNil(creditAuthorize)
        XCTAssertNotNil(chargeStatus)
        XCTAssertEqual(creditAuthorize?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeStatus, TransactionStatus.captured.rawValue)
        
        // GIVEN
        let creditReverseExpectation = expectation(description: "Credit Reverse Expectation")
        var reverseResult: Transaction?
        var reverseStatus: String?
        var reverseError: Error?
        
        // WHEN
        creditAuthorize?.reverse()
            .withCurrency(currency)
            .execute {
                reverseResult = $0
                reverseError = $1
                reverseStatus = $0?.responseMessage
                creditReverseExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditReverseExpectation], timeout: 10.0)
        XCTAssertNotNil(reverseResult)
        XCTAssertNotNil(reverseStatus)
        XCTAssertNil(reverseError)
        XCTAssertEqual(reverseResult?.responseCode, "SUCCESS")
        XCTAssertEqual(reverseResult?.responseMessage, TransactionStatus.reversed.mapped(for: .gpApi))
    }
    
    func  test_pay_with_apple_pay_encrypted() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var chargeResult: Transaction?
        var chargeStatus: String?
        var chargeError: Error?
        
        // WHEN
        card.token = """
{"version":"EC_v1","data":"ux6+0SHLGc/skKUx1Cp4A9TQ9dBWQyBc+4m+Ini+hEp9fZxX+dmk9JSW4s3eg+aOZqjYt1LNjapJmWJ6NyNWhFT3DYEOiJj1OqB++W7PB7pxuG3EktwviuVDwOJ3aiuE40wOP9kjEkcSzPTinq86hhhXrhY5Gdrn87tazPEWDGwtrbeL7WeIwPOzcfphUBq69lOV2yVi+y0cz2MJKBemvqj6CPvLwWV5kQsZLzAKW4CiEtGCR/obtJsX+jw4Ub4NPmKMP2s59A8y0LrtZRs0MAEH9NDDfEGbx4NnLJd0hfyxRVFXMwrkkcY7q2/jdB8mUjTL0RbDV9VBo58C5ut4T2O2R0Z7OAoAvZjcEWvo/Cr2ARWxN/Hjz/n6oJW+F3MbSdQAWJR8Wg1abFv7Fmo8Bd6kIJdDRE9kjC28t8pe1DQ=","signature":"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","header":{"ephemeralPublicKey":"MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEafMmTnKzZNz89MNvkeywS0hqDEnJP3gHS8YpO/NnGbb8eOpDFq5/jMDRhMNfbu8wEOlsvcZYMJPhXEmcPgCOzA==","publicKeyHash":"rEYX/7PdO7F7xL7rH0LZVak/iXTrkeU89Ck7E9dGFO4=","transactionId":"4115f0a5b4d18e9b1122fc9e5940a0861cbfef920adce03ac1ee661649fc0287"}}
"""
        
        card.mobileType = EncryptedMobileType.APPLE_PAY.rawValue
        card.charge(amount: 10)
            .withCurrency("GBP")
            .withModifier(.encryptedMobile)
            .execute {
                chargeResult = $0
                chargeError = $1
                chargeStatus = $0?.responseMessage
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10)
        XCTAssertNil(chargeError)
        XCTAssertNotNil(chargeResult)
        XCTAssertNotNil(chargeStatus)
        XCTAssertEqual(chargeResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeStatus, TransactionStatus.captured.rawValue)
    }
}
