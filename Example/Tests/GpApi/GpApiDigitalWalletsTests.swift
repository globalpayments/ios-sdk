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
            .withCurrency("EUR")
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
    
    func test_pay_with_encrypted() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var chargeResult: Transaction?
        var chargeStatus: String?
        var chargeError: Error?
        card.token = "9113329269393758302"
        card.mobileType = EncryptedMobileType.CLICK_PAY.rawValue

        // WHEN
        
        card.charge(amount: 10)
            .withCurrency("EUR")
            .withModifier(.encryptedMobile)
            .withMaskedDataResponse(true)
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
        XCTAssertTrue(!(chargeResult?.transactionId?.isEmpty ?? false))
        assertClickToPayPayerDetails(chargeResult)
    }
    
    //You need a valid ApplePay token that it is valid only for 60 sec
    func  test_pay_with_apple_pay_encrypted() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var chargeResult: Transaction?
        var chargeStatus: String?
        var chargeError: Error?
        
        // WHEN
        card.token = """
        {"version":"EC_v1","data":"lreFgHfpcDnLXAgXUHu5pe/Sm6hCsLjUteTuzI4YlPOX/yEygwz9KfdharsjHEGI3O8p4r9nA7wkvHy43ie7wGVqjT4L0rITZ3yT5MWSMlMDegjAgeMBrKMEm2yMyIp6ivZK9fLHhgb6kckqDsSnN64mBxNG+mQETRVvL02evefDxLcftB05MhgknJ0ogfvSgh/QpBSqYAMNCq40/xdSqf6k3ofNPZhupR916p8AfFNm7ZB/dqxSD+m5+C3BQ00AX++jsAo2cJPulsiPXcBOl+B92KU1mXy+FzthmQv7ZwVozJ+mHYJwqtAlz1oOEghYoADD83kHAS6ut/UWOpS23tH6XLP15VYMVU6YS1C1VPkAhUlrcLN97377B+4mIUkqfJrAyWyLRZT5wAdoWxPmP48p4vyl+JfLmwPoMVzLURU=","signature":"MIAGCSqGSIb3DQEHAqCAMIACAQExDTALBglghkgBZQMEAgEwgAYJKoZIhvcNAQcBAACggDCCA+MwggOIoAMCAQICCEwwQUlRnVQ2MAoGCCqGSM49BAMCMHoxLjAsBgNVBAMMJUFwcGxlIEFwcGxpY2F0aW9uIEludGVncmF0aW9uIENBIC0gRzMxJjAkBgNVBAsMHUFwcGxlIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQGEwJVUzAeFw0xOTA1MTgwMTMyNTdaFw0yNDA1MTYwMTMyNTdaMF8xJTAjBgNVBAMMHGVjYy1zbXAtYnJva2VyLXNpZ25fVUM0LVBST0QxFDASBgNVBAsMC2lPUyBTeXN0ZW1zMRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQGEwJVUzBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABMIVd+3r1seyIY9o3XCQoSGNx7C9bywoPYRgldlK9KVBG4NCDtgR80B+gzMfHFTD9+syINa61dTv9JKJiT58DxOjggIRMIICDTAMBgNVHRMBAf8EAjAAMB8GA1UdIwQYMBaAFCPyScRPk+TvJ+bE9ihsP6K7/S5LMEUGCCsGAQUFBwEBBDkwNzA1BggrBgEFBQcwAYYpaHR0cDovL29jc3AuYXBwbGUuY29tL29jc3AwNC1hcHBsZWFpY2EzMDIwggEdBgNVHSAEggEUMIIBEDCCAQwGCSqGSIb3Y2QFATCB/jCBwwYIKwYBBQUHAgIwgbYMgbNSZWxpYW5jZSBvbiB0aGlzIGNlcnRpZmljYXRlIGJ5IGFueSBwYXJ0eSBhc3N1bWVzIGFjY2VwdGFuY2Ugb2YgdGhlIHRoZW4gYXBwbGljYWJsZSBzdGFuZGFyZCB0ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB1c2UsIGNlcnRpZmljYXRlIHBvbGljeSBhbmQgY2VydGlmaWNhdGlvbiBwcmFjdGljZSBzdGF0ZW1lbnRzLjA2BggrBgEFBQcCARYqaHR0cDovL3d3dy5hcHBsZS5jb20vY2VydGlmaWNhdGVhdXRob3JpdHkvMDQGA1UdHwQtMCswKaAnoCWGI2h0dHA6Ly9jcmwuYXBwbGUuY29tL2FwcGxlYWljYTMuY3JsMB0GA1UdDgQWBBSUV9tv1XSBhomJdi9+V4UH55tYJDAOBgNVHQ8BAf8EBAMCB4AwDwYJKoZIhvdjZAYdBAIFADAKBggqhkjOPQQDAgNJADBGAiEAvglXH+ceHnNbVeWvrLTHL+tEXzAYUiLHJRACth69b1UCIQDRizUKXdbdbrF0YDWxHrLOh8+j5q9svYOAiQ3ILN2qYzCCAu4wggJ1oAMCAQICCEltL786mNqXMAoGCCqGSM49BAMCMGcxGzAZBgNVBAMMEkFwcGxlIFJvb3QgQ0EgLSBHMzEmMCQGA1UECwwdQXBwbGUgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxEzARBgNVBAoMCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTMB4XDTE0MDUwNjIzNDYzMFoXDTI5MDUwNjIzNDYzMFowejEuMCwGA1UEAwwlQXBwbGUgQXBwbGljYXRpb24gSW50ZWdyYXRpb24gQ0EgLSBHMzEmMCQGA1UECwwdQXBwbGUgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxEzARBgNVBAoMCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE8BcRhBnXZIXVGl4lgQd26ICi7957rk3gjfxLk+EzVtVmWzWuItCXdg0iTnu6CP12F86Iy3a7ZnC+yOgphP9URaOB9zCB9DBGBggrBgEFBQcBAQQ6MDgwNgYIKwYBBQUHMAGGKmh0dHA6Ly9vY3NwLmFwcGxlLmNvbS9vY3NwMDQtYXBwbGVyb290Y2FnMzAdBgNVHQ4EFgQUI/JJxE+T5O8n5sT2KGw/orv9LkswDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBS7sN6hWDOImqSKmd6+veuv2sskqzA3BgNVHR8EMDAuMCygKqAohiZodHRwOi8vY3JsLmFwcGxlLmNvbS9hcHBsZXJvb3RjYWczLmNybDAOBgNVHQ8BAf8EBAMCAQYwEAYKKoZIhvdjZAYCDgQCBQAwCgYIKoZIzj0EAwIDZwAwZAIwOs9yg1EWmbGG+zXDVspiv/QX7dkPdU2ijr7xnIFeQreJ+Jj3m1mfmNVBDY+d6cL+AjAyLdVEIbCjBXdsXfM4O5Bn/Rd8LCFtlk/GcmmCEm9U+Hp9G5nLmwmJIWEGmQ8Jkh0AADGCAYgwggGEAgEBMIGGMHoxLjAsBgNVBAMMJUFwcGxlIEFwcGxpY2F0aW9uIEludGVncmF0aW9uIENBIC0gRzMxJjAkBgNVBAsMHUFwcGxlIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQGEwJVUwIITDBBSVGdVDYwCwYJYIZIAWUDBAIBoIGTMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIzMDUyMzIwMjEyOVowKAYJKoZIhvcNAQk0MRswGTALBglghkgBZQMEAgGhCgYIKoZIzj0EAwIwLwYJKoZIhvcNAQkEMSIEIBZyNTBEbjqXe34CgMUgxv5DOU6hYUreO0D4McORbgchMAoGCCqGSM49BAMCBEcwRQIgWBAg6rNAkpGMl6PULdd0+RueF+6cDBjaYTxzt/fGGbICIQCvyCXyudXD+ObrJUltJcgb9BG+59+nLIQDB3X4DWxrOgAAAAAAAA==","header":{"ephemeralPublicKey":"MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEPxg/Mbr0cOj7CxOPo7iy4ePC1xdm8jW7/cdieiJQc6PSAPlFZMnZtuiJGYuIJG1ffbC+8vmm7lMdRHewFoLmwQ==","publicKeyHash":"rEYX/7PdO7F7xL7rH0LZVak/iXTrkeU89Ck7E9dGFO4=","transactionId":"12c8708a74acde4a08263cc068a29a5fa7fc568b8d7f226c709a0afd2f7892f2"}}
        """
        
        card.mobileType = EncryptedMobileType.APPLE_PAY.rawValue
        card.charge(amount: 10)
            .withCurrency("USD")
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
    
    //You need a valid ApplePay token that it is valid only for 60 sec
    func  test_pay_with_apple_pay_encrypted_reverse() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var chargeResult: Transaction?
        var chargeStatus: String?
        var chargeError: Error?
        card.mobileType = EncryptedMobileType.APPLE_PAY.rawValue
        card.token = """
{"version":"EC_v1","data":"016NsVOAiI8p4hRuP7tyaBBWJL2kxSTsB7B98jnRQ82dk4bjwzwFvIEsTMHux3j8SbdYF8mnT4/eWL9Yf7nPM6+kVyhYPzmeA4xbdbbrm0F+szcjJkhBv8era1wNXtc9LraPOXHjwDbLD465I20uRoFjQ+miohPv18h+86tnoCD00JQHBccEcpyscwszcQqEyj6a9L2j+5Rqa+2EenU2efQh5DCNGHH89s2NBn19UFpjIgjCTTgo5x+PeD9r37JZDm4oDvuyNaH7exlHDZSF4S45C/VCfCMHZstFA8jsxF9v6wQ047UeybTdY3sZzz9UEJ11DEQ9Uc0Ou/dUvUMrl59Iwix+WtKkYFyFA23PRvD01nK3xaPaThuDydX/faYZNbXb23ALam1J9j1ToIIjIUSPHMsHzvT+Ds1F+gI0enM=","signature":"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","header":{"ephemeralPublicKey":"MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEJGk/xino0ep1++sfsrwRABBgQf4o1NwvNX2P4GKJxiY2JJsxltN7qURFkFgN2DgCOBVV/BT5tIrLd2fePRlICQ==","publicKeyHash":"rEYX/7PdO7F7xL7rH0LZVak/iXTrkeU89Ck7E9dGFO4=","transactionId":"bcfab064e7a80b206a59f665f6519ed3489a79aaac97a75929221c7e67a7ba1f"}}
"""
        // WHEN
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
        
        // GIVEN
        let creditReverseExpectation = expectation(description: "Credit reverse expectation")
        var reverseResponse: Transaction?
        var reverseError: Error?
        
        // WHEN
        chargeResult?.reverse()
            .withCurrency("USD")
            .execute{
                reverseResponse = $0
                reverseError = $1
                creditReverseExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditReverseExpectation], timeout: 10.0)
        XCTAssertNil(reverseError)
        XCTAssertNotNil(reverseResponse)
        XCTAssertEqual("SUCCESS", reverseResponse?.responseCode)
        XCTAssertEqual(TransactionStatus.reversed.rawValue, reverseResponse?.responseMessage)
    }
    
    private func assertClickToPayPayerDetails(_ response: Transaction?) {
        XCTAssertNotNil(response?.payerDetails)
        XCTAssertNotNil(response?.payerDetails?.email)
        XCTAssertNotNil(response?.payerDetails?.billingAddress)
        XCTAssertNotNil(response?.payerDetails?.shippingAddress)
        XCTAssertNotNil(response?.payerDetails?.firstName)
        XCTAssertNotNil(response?.payerDetails?.firstName)
    }
}
