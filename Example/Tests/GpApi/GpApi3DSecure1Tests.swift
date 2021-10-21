import XCTest
import GlobalPayments_iOS_SDK

class GpApi3DSecure1Tests: XCTestCase {

    private var currency: String!
    private var amount: NSDecimalNumber!
    private var card: CreditCardData!

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "yDkdruxQ7hUjm8p76SaeBVAUnahESP5P",
            appKey: "o8C8CYrgXNELI46x",
            channel: .cardNotPresent,
            country: "GB",
            challengeNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
            methodNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
            merchantContactUrl: "https://enp4qhvjseljg.x.pipedream.net/"
        ))
    }

    override func setUp() {
        super.setUp()

        currency = "GBP"
        amount = 10.01

        card = CreditCardData()
        card.number = GpApi3DSTestCards.cardholderEnrolledV1
        card.expMonth = 12
        card.expYear = Date().currentYear + 1
        card.cardHolderName = "James Mason"
    }

    override func tearDown() {
        super.tearDown()

        currency = nil
        amount = nil
        card = nil
    }

    // MARK: - Tests for 3DS v1 Card Enrolled - Check Availability

    func test_card_holder_enrolled_challenge_required_v1() {
        // GIVEN
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollmentChallengeV1(threeDSecureResult)
    }

    func test_card_holder_enrolled_challenge_required_v1_with_idempotency_key() {

        // Check Enrollment - First

        // GIVEN
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        let idempotencyKey = UUID().uuidString
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollmentChallengeV1(threeDSecureResult)

        // Check Enrollment - Second

        // GIVEN
        let checkEnrollmentSecondExpectation = expectation(description: "Check Enrollment Second Expectation")
        var threeSecondDSecureResult: ThreeDSecure?
        var threeSecondDSecureError: GatewayException?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                threeSecondDSecureResult = $0
                if let error = $1 as? GatewayException {
                    threeSecondDSecureError = error
                }
                checkEnrollmentSecondExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentSecondExpectation], timeout: 10.0)
        XCTAssertNil(threeSecondDSecureResult)
        XCTAssertNotNil(threeSecondDSecureError)
        XCTAssertEqual(threeSecondDSecureError?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(threeSecondDSecureError?.responseMessage, "40039")
        if let message = threeSecondDSecureError?.message {
            XCTAssertTrue(message.contains("Idempotency Key seen before"))
        } else {
            XCTFail("threeSecondDSecureError?.message cannot be nil")
        }
    }

    func test_card_holder_enrolled_challenge_required_v1_tokenized_card() {

        // Tokenize

        // GIVEN
        let tokenizeExpectation = expectation(description: "Tokenize Expectation")
        var token: String?
        var tokenizeError: Error?

        // WHEN
        card.tokenize {
            token = $0
            tokenizeError = $1
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNil(tokenizeError)
        XCTAssertNotNil(token)

        // Check Enrollment

        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        tokenizedCard.cardHolderName = "James Mason"
        let checkEnrollment = expectation(description: "Check Enrollment")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: tokenizedCard)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollment.fulfill()
            }

        // THEN
        wait(for: [checkEnrollment], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollmentChallengeV1(threeDSecureResult)
    }

    func test_card_holder_enrolled_challenge_required_v1_all_preference_values() {

        for indicator in ChallengeRequestIndicator.allCases {
            // GIVEN
            let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
            var threeDSecureResult: ThreeDSecure?
            var threeDSecureError: Error?

            // WHEN
            Secure3dService
                .checkEnrollment(paymentMethod: card)
                .withCurrency(currency)
                .withAmount(amount)
                .withChallengeRequestIndicator(indicator)
                .execute {
                    threeDSecureResult = $0
                    threeDSecureError = $1
                    checkEnrollmentExpectation.fulfill()
                }

            // THEN
            wait(for: [checkEnrollmentExpectation], timeout: 10.0)
            XCTAssertNil(threeDSecureError)
            assertCheckEnrollmentChallengeV1(threeDSecureResult)
        }
    }

    func test_card_holder_enrolled_challenge_required_v1_stored_credentials() {
        // GIVEN
        let storeCredentials = StoredCredential(
            type: .installment,
            initiator: .merchant,
            sequence: .subsequent,
            reason: .incremental
        )
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .withStoredCredential(storeCredentials)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollmentChallengeV1(threeDSecureResult)
    }

    func test_card_holder_enrolled_challenge_required_v1_refund_and_sale() {

        // Refund

        // GIVEN
        let checkRefundEnrollmentExpectation = expectation(description: "Check Refund Enrollment Expectation")
        var threeDSecureRefundResult: ThreeDSecure?
        var threeDSecureRefundError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .withPaymentType(.refund)
            .execute {
                threeDSecureRefundResult = $0
                threeDSecureRefundError = $1
                checkRefundEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkRefundEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureRefundError)
        assertCheckEnrollmentChallengeV1(threeDSecureRefundResult)

        // Sale

        // GIVEN
        let checkSaleEnrollmentExpectation = expectation(description: "Check Refund Enrollment Expectation")
        var threeDSecureSaleResult: ThreeDSecure?
        var threeDSecureSaleError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .withPaymentType(.sale)
            .execute {
                threeDSecureSaleResult = $0
                threeDSecureSaleError = $1
                checkSaleEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkSaleEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureSaleError)
        assertCheckEnrollmentChallengeV1(threeDSecureSaleResult)

        // Check
        XCTAssertNotEqual(threeDSecureRefundResult, threeDSecureSaleResult)
    }

    func test_card_holder_enrolled_challenge_required_v1_all_sources() {

        for source in AuthenticationSource.allCases {
            // GIVEN
            let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
            var threeDSecureResult: ThreeDSecure?
            var threeDSecureError: Error?

            // WHEN
            Secure3dService
                .checkEnrollment(paymentMethod: card)
                .withCurrency(currency)
                .withAmount(amount)
                .withAuthenticationSource(source)
                .execute {
                    threeDSecureResult = $0
                    threeDSecureError = $1
                    checkEnrollmentExpectation.fulfill()
                }

            // THEN
            wait(for: [checkEnrollmentExpectation], timeout: 10.0)
            XCTAssertNil(threeDSecureError)
            assertCheckEnrollmentChallengeV1(threeDSecureResult)
        }
    }

    func test_card_holder_enrolled_challenge_required_v1_with_nil_payment_method() {
        // GIVEN
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: BuilderException?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withPaymentMethod(nil)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                if let error = $1 as? BuilderException {
                    threeDSecureError = error
                }
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureResult)
        XCTAssertNotNil(threeDSecureError)
        XCTAssertEqual(threeDSecureError?.message, "paymentMethod cannot be nil for this rule")
    }

    // MARK: - Tests for 3DS v1 Card Not Enrolled - Check Availability

    func test_card_holder_not_enrolled_v1() {
        // GIVEN
        card.number = GpApi3DSTestCards.cardholderNotEnrolledV1
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollmentCardNotEnrolledV1(threeDSecureResult)
    }

    func test_card_holder_not_enrolled_v1_tokenized_card() {

        // Tokenize

        // GIVEN
        card.number = GpApi3DSTestCards.cardholderNotEnrolledV1
        let tokenizeExpectation = expectation(description: "Tokenize Expectation")
        var token: String?
        var tokenizeError: Error?

        // WHEN
        card.tokenize {
            token = $0
            tokenizeError = $1
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNil(tokenizeError)
        XCTAssertNotNil(token)

        // Check Enrollment

        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        tokenizedCard.cardHolderName = "James Mason"
        let checkEnrollment = expectation(description: "Check Enrollment")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: tokenizedCard)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollment.fulfill()
            }

        // THEN
        wait(for: [checkEnrollment], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollmentCardNotEnrolledV1(threeDSecureResult)
    }

    // MARK: - Tests for 3DS v1 Card Enrolled - Obtain Result

    func test_card_holder_enrolled_post_result() {

        // Check Enrollment

        // GIVEN
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollmentChallengeV1(threeDSecureResult)

        // Perform ACS authetication

        // GIVEN
        let authenticateExpectation = expectation(description: "Authenticate Expectation")
        let acsClient = GpApi3DSecureAcsClient(redirectURL: threeDSecureResult?.issuerAcsUrl)
        var acsResponse: AcsResponse?

        // WHEN
        acsClient?.authenticateV1(threeDSecureResult, .successful) {
            acsResponse = $0
            authenticateExpectation.fulfill()
        }

        // THEN
        wait(for: [authenticateExpectation], timeout: 20.0)
        XCTAssertNotNil(acsResponse)
        XCTAssertNotNil(acsResponse?.authResponse)
        XCTAssertNotNil(acsResponse?.merchantData)
        XCTAssertEqual(acsResponse?.status, true)

        // Get Authentication Data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var secureEcomResult: ThreeDSecure?
        var secureEcomError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(acsResponse?.merchantData)
            .withPayerAuthenticationResponse(acsResponse?.authResponse)
            .execute {
                secureEcomResult = $0
                secureEcomError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 10.0)
        XCTAssertNil(secureEcomError)
        XCTAssertNotNil(secureEcomResult)
        XCTAssertEqual(secureEcomResult?.status, "SUCCESS_AUTHENTICATED")
        XCTAssertEqual(secureEcomResult?.challengeMandated, true)
        XCTAssertNotNil(secureEcomResult?.issuerAcsUrl)
        XCTAssertNotNil(secureEcomResult?.payerAuthenticationRequest)
        XCTAssertNotNil(secureEcomResult?.challengeValue)
        XCTAssertEqual(secureEcomResult?.eci, 5)
        XCTAssertEqual(secureEcomResult?.messageVersion, "1.0.0")
    }

    func test_card_holder_enrolled_post_result_with_idempotency_key() {

        // Check Enrollment

        // GIVEN
        let idempotencyKey = UUID().uuidString
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollmentChallengeV1(threeDSecureResult)

        // Perform ACS authetication

        // GIVEN
        let authenticateExpectation = expectation(description: "Authenticate Expectation")
        let acsClient = GpApi3DSecureAcsClient(redirectURL: threeDSecureResult?.issuerAcsUrl)
        var acsResponse: AcsResponse?

        // WHEN
        acsClient?.authenticateV1(threeDSecureResult, .successful) {
            acsResponse = $0
            authenticateExpectation.fulfill()
        }

        // THEN
        wait(for: [authenticateExpectation], timeout: 20.0)
        XCTAssertNotNil(acsResponse)
        XCTAssertNotNil(acsResponse?.authResponse)
        XCTAssertNotNil(acsResponse?.merchantData)
        XCTAssertEqual(acsResponse?.status, true)

        // Get Authentication Data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var secureEcomResult: ThreeDSecure?
        var secureEcomError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(acsResponse?.merchantData)
            .withPayerAuthenticationResponse(acsResponse?.authResponse)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                secureEcomResult = $0
                secureEcomError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 10.0)
        XCTAssertNil(secureEcomError)
        XCTAssertNotNil(secureEcomResult)
        XCTAssertEqual(secureEcomResult?.status, "SUCCESS_AUTHENTICATED")
        XCTAssertEqual(secureEcomResult?.challengeMandated, true)
        XCTAssertNotNil(secureEcomResult?.issuerAcsUrl)
        XCTAssertNotNil(secureEcomResult?.payerAuthenticationRequest)
        XCTAssertNotNil(secureEcomResult?.challengeValue)
        XCTAssertEqual(secureEcomResult?.eci, 5)
        XCTAssertEqual(secureEcomResult?.messageVersion, "1.0.0")

        // Get Authentication Data - Repeat

        // GIVEN
        let getAuthenticationDataRepeatExpectation = expectation(description: "Get Authentication Data Expectation")
        var secureEcomRepeatResult: ThreeDSecure?
        var secureEcomRepeatError: GatewayException?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(acsResponse?.merchantData)
            .withPayerAuthenticationResponse(acsResponse?.authResponse)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                secureEcomRepeatResult = $0
                if let error = $1 as? GatewayException {
                    secureEcomRepeatError = error
                }
                getAuthenticationDataRepeatExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataRepeatExpectation], timeout: 10.0)
        XCTAssertNil(secureEcomRepeatResult)
        XCTAssertNotNil(secureEcomRepeatError)
        XCTAssertEqual(secureEcomRepeatError?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(secureEcomRepeatError?.responseMessage, "40039")
        if let message = secureEcomRepeatError?.message {
            XCTAssertTrue(message.contains("Idempotency Key seen before"))
        } else {
            XCTFail("secureEcomRepeatError?.message cannot be nil")
        }
    }

    func test_card_holder_enrolled_post_result_non_existent_id() {
        // GIVEN
        let transactionId = "AUT_" + UUID().uuidString
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: GatewayException?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(transactionId)
            .execute {
                threeDSecureResult = $0
                if let error = $1 as? GatewayException {
                    threeDSecureError = error
                }
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureResult)
        XCTAssertNotNil(threeDSecureError)
        XCTAssertEqual(threeDSecureError?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(threeDSecureError?.responseMessage, "40118")
        if let message = threeDSecureError?.message {
            XCTAssertEqual(message, "Status Code: 404 - Authentication \(transactionId) not found at this location.")
        } else {
            XCTFail("threeDSecureError?.message cannot be nil")
        }
    }

    func test_card_holder_enrolled_post_result_acs_not_complete() {

        // Check Enrollment

        // GIVEN
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollmentChallengeV1(threeDSecureResult)

        // Get Authentication Data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var getAuthenticationDataResult: ThreeDSecure?
        var getAuthenticationDataError: GatewayException?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureResult?.serverTransactionId)
            .execute {
                getAuthenticationDataResult = $0
                if let error = $1 as? GatewayException {
                    getAuthenticationDataError = error
                }
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 10.0)
        XCTAssertNil(getAuthenticationDataResult)
        XCTAssertNotNil(getAuthenticationDataError)
        XCTAssertEqual(getAuthenticationDataError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(getAuthenticationDataError?.responseMessage, "50027")
        if let message = getAuthenticationDataError?.message {
            XCTAssertEqual(message, "Status Code: 400 - Undefined element in Message before PARes")
        } else {
            XCTFail("getAuthenticationDataError?.message cannot be nil")
        }
    }

    // MARK: - Tests for 3DS v1 Card Not Enrolled - Obtain Result

    func test_card_holder_not_enrolled_post_result() {

        // Check Enrollment

        // GIVEN
        card.number = GpApi3DSTestCards.cardholderNotEnrolledV1
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollmentCardNotEnrolledV1(threeDSecureResult)

        // Get Authentication Data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var getAuthenticationDataResult: ThreeDSecure?
        var getAuthenticationDataError: GatewayException?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureResult?.serverTransactionId)
            .execute {
                getAuthenticationDataResult = $0
                if let error = $1 as? GatewayException {
                    getAuthenticationDataError = error
                }
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 10.0)
        XCTAssertNil(getAuthenticationDataResult)
        XCTAssertNotNil(getAuthenticationDataError)
        XCTAssertEqual(getAuthenticationDataError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(getAuthenticationDataError?.responseMessage, "50027")
        if let message = getAuthenticationDataError?.message {
            XCTAssertEqual(message, "Status Code: 400 - Undefined element in Message before PARes")
        } else {
            XCTFail("getAuthenticationDataError?.message cannot be nil")
        }
    }

    private func assertCheckEnrollmentChallengeV1(_ secureEcom: ThreeDSecure?) {
        XCTAssertNotNil(secureEcom)
        XCTAssertEqual(secureEcom?.enrolled, "ENROLLED")
        XCTAssertEqual(secureEcom?.version, .one)
        XCTAssertEqual(secureEcom?.status, "CHALLENGE_REQUIRED")
        XCTAssertEqual(secureEcom?.challengeMandated, true)
        XCTAssertEqual(secureEcom?.messageVersion, "1.0.0")
        XCTAssertNotNil(secureEcom?.issuerAcsUrl)
        XCTAssertNotNil(secureEcom?.payerAuthenticationRequest)
        XCTAssertNotNil(secureEcom?.challengeValue)
        XCTAssertNil(secureEcom?.eci)
    }

    private func assertCheckEnrollmentCardNotEnrolledV1(_ secureEcom: ThreeDSecure?) {
        XCTAssertNotNil(secureEcom)
        XCTAssertEqual(secureEcom?.version, .one)
        XCTAssertEqual(secureEcom?.enrolled, "NOT_ENROLLED")
        XCTAssertEqual(secureEcom?.status, "NOT_ENROLLED")
        XCTAssertEqual(secureEcom?.eci, 6)
        XCTAssertEqual(secureEcom?.messageVersion, "1.0.0")
        XCTAssertEqual(secureEcom?.challengeMandated, false)
    }
}
