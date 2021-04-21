import XCTest
import GlobalPayments_iOS_SDK

class GpApi3DSecure2Tests: XCTestCase {

    var card: CreditCardData!
    var currency: String!
    var amount: NSDecimalNumber!
    var shippingAddress: Address!
    var billingAddress: Address!
    var browserData: BrowserData!

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "P3LRVjtGRGxWQQJDE345mSkEh2KfdAyg",
            appKey: "ockJr6pv6KFoGiZA",
            channel: .cardNotPresent,
            country: "GB",
            challengeNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
            methodNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
            merchantContactUrl: "https://enp4qhvjseljg.x.pipedream.net/"
        ))
    }

    override func setUp() {
        super.setUp()

        // General
        currency = "GBP"
        amount = 10.01

        // Card
        card = CreditCardData()
        card.number = GpApi3DSTestCards.cardChallengeRequiredV22
        card.expMonth = 12
        card.expYear = Date().currentYear + 1
        card.cardHolderName = "James Mason"

        // Shipping Address
        shippingAddress = Address()
        shippingAddress.streetAddress1 = "Apartment 852"
        shippingAddress.streetAddress2 = "Complex 741"
        shippingAddress.streetAddress3 = "no"
        shippingAddress.city = "Chicago"
        shippingAddress.postalCode = "5001"
        shippingAddress.state = "IL"
        shippingAddress.countryCode = "840"

        // Billing Address
        billingAddress = Address()
        billingAddress.streetAddress1 = "Flat 456"
        billingAddress.streetAddress2 = "House 789"
        billingAddress.streetAddress3 = "no"
        billingAddress.city = "Halifax"
        billingAddress.postalCode = "W5 9HR"
        billingAddress.countryCode = "826"

        // Browser Data
        browserData = BrowserData()
        browserData.acceptHeader = "text/html,application/xhtml+xml,application/xml;q=9,image/webp,img/apng,*/*;q=0.8"
        browserData.colorDepth = .twentyFourBits
        browserData.ipAddress = "123.123.123.123"
        browserData.javaEnabled = true
        browserData.javaScriptEnabled = true
        browserData.language = "en"
        browserData.screenHeight = 1920
        browserData.screenWidth = 1080
        browserData.challengeWindowSize = .fullScreen
        browserData.timezone = "0"
        browserData.userAgent = "Mozilla/5.0 (Windows NT 6.1; Win64, x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36"
    }

    override func tearDown() {
        super.tearDown()

        currency = nil
        amount = nil
        card = nil
        shippingAddress = nil
        billingAddress = nil
        browserData = nil
    }

    // MARK: - Frictionless scenario

    func test_full_cycle_v2_frictionless() {

        // Check enrollment

        // GIVEN
        card.number = GpApi3DSTestCards.cardAuthSuccessfulV22
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
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult?.issuerAcsUrl)
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, "SUCCESS_AUTHENTICATED")

        // Get authentication data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var authThreeDSecureResult: ThreeDSecure?
        var authThreeDSecureError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .execute {
                authThreeDSecureResult = $0
                authThreeDSecureError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 20.0)
        XCTAssertNil(authThreeDSecureError)
        XCTAssertNotNil(authThreeDSecureResult)
        XCTAssertEqual(authThreeDSecureResult?.status, "SUCCESS_AUTHENTICATED")

        // Card charge

        // GIVEN
        card.threeDSecure = authThreeDSecureResult
        let chargeExpectation = expectation(description: "Charge Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card.charge(amount: amount)
            .withCurrency(currency)
            .execute {
                transactionResult = $0
                transactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 20.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.rawValue)
    }

    func test_full_cycle_v2_frictionless_failed() {

        // Check enrollment

        // GIVEN
        card.number = GpApi3DSTestCards.cardAuthFailedV22
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
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult?.issuerAcsUrl)
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, "FAILED")

        // Get authentication data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var authThreeDSecureResult: ThreeDSecure?
        var authThreeDSecureError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .execute {
                authThreeDSecureResult = $0
                authThreeDSecureError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 20.0)
        XCTAssertNil(authThreeDSecureError)
        XCTAssertNotNil(authThreeDSecureResult)
        XCTAssertEqual(authThreeDSecureResult?.status, "FAILED")

        // Card charge

        // GIVEN
        card.threeDSecure = authThreeDSecureResult
        let chargeExpectation = expectation(description: "Charge Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card.charge(amount: amount)
            .withCurrency(currency)
            .execute {
                transactionResult = $0
                transactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 20.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.rawValue)
    }

    func test_full_cycle_v2_with_card_tokenization() {

        // Tokenization

        // GIVEN
        card.number = GpApi3DSTestCards.cardAuthSuccessfulV22
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

        // Check enrollment

        // GIVEN
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        tokenizedCard.cardHolderName = "James Mason"
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
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
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult?.issuerAcsUrl)
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: tokenizedCard, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, "SUCCESS_AUTHENTICATED")

        // Get authentication data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var authThreeDSecureResult: ThreeDSecure?
        var authThreeDSecureError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .execute {
                authThreeDSecureResult = $0
                authThreeDSecureError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 20.0)
        XCTAssertNil(authThreeDSecureError)
        XCTAssertNotNil(authThreeDSecureResult)
        XCTAssertEqual(authThreeDSecureResult?.status, "SUCCESS_AUTHENTICATED")

        // Card charge

        // GIVEN
        tokenizedCard.threeDSecure = authThreeDSecureResult
        let chargeExpectation = expectation(description: "Charge Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        tokenizedCard
            .charge(amount: amount)
            .withCurrency(currency)
            .execute {
                transactionResult = $0
                transactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 20.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.rawValue)
    }

    // MARK: - Challenge scenario

    func test_full_cycle_card_holder_enrolled_challenge_required_v2() {

        // Check enrollment

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
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult)
        XCTAssertNotNil(threeDSecureResult?.issuerAcsUrl)
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, "CHALLENGE_REQUIRED")
        XCTAssertEqual(threeDSecureInitAuthResult?.challengeMandated, true)
        XCTAssertNotNil(threeDSecureInitAuthResult?.issuerAcsUrl)
        XCTAssertNotNil(threeDSecureInitAuthResult?.challengeValue)

        // Send challenge

        // GIVEN
        let authenticateExpectation = expectation(description: "Authenticate Expectation")
        let acsClient = GpApi3DSecureAcsClient(redirectURL: threeDSecureInitAuthResult?.issuerAcsUrl)
        var authResponse: String?

        // WHEN
        acsClient?.authenticateV2(secureEcom: threeDSecureInitAuthResult) {
            authResponse = $0
            authenticateExpectation.fulfill()
        }

        // THEN
        wait(for: [authenticateExpectation], timeout: 500.0)
        XCTAssertNotNil(authResponse)

        // Get authentication data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var authThreeDSecureResult: ThreeDSecure?
        var authThreeDSecureError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .execute {
                authThreeDSecureResult = $0
                authThreeDSecureError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 20.0)
        XCTAssertNil(authThreeDSecureError)
        XCTAssertNotNil(authThreeDSecureResult)
        XCTAssertEqual(authThreeDSecureResult?.status, "SUCCESS_AUTHENTICATED")

        // Card charge

        // GIVEN
        card.threeDSecure = authThreeDSecureResult
        let chargeExpectation = expectation(description: "Charge Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card.charge(amount: amount)
            .withCurrency(currency)
            .execute {
                transactionResult = $0
                transactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 20.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.rawValue)
    }

    // MARK: - Tests for 3DS v2 Challenge - Check Availability

    func test_card_holder_enrolled_challenge_required_v22() {
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
        assertCheckEnrollment3DSV2(threeDSecureResult)
    }

    func test_card_holder_enrolled_challenge_required_v2_with_idempotency_key() {

        // Check Enrollment - 1

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
            .withIdempotencyKey(idempotencyKey)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Check Enrollment - 2

        // GIVEN
        let checkEnrollmentRepeatExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureRepeatResult: ThreeDSecure?
        var threeDSecureRepeatError: GatewayException?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                threeDSecureRepeatResult = $0
                if let error = $1 as? GatewayException {
                    threeDSecureRepeatError = error
                }
                checkEnrollmentRepeatExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentRepeatExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureRepeatResult)
        XCTAssertNotNil(threeDSecureRepeatError)
        XCTAssertEqual(threeDSecureRepeatError?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(threeDSecureRepeatError?.responseMessage, "40039")
        if let message = threeDSecureRepeatError?.message {
            XCTAssertTrue(message.contains("Idempotency Key seen before"))
        } else {
            XCTFail("threeDSecureRepeatError?.message cannot be nil")
        }
    }

    func test_card_holder_enrolled_challenge_required_v2_with_tokenized_card() {

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
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
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
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollment3DSV2(threeDSecureResult)
    }

    func test_card_holder_enrolled_challenge_required_v2_all_preference_values() {

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
            assertCheckEnrollment3DSV2(threeDSecureResult)
        }
    }

    func test_card_holder_enrolled_challenge_required_v2_stored_credentials() {
        // GIVEN
        let storedCredential = StoredCredential(
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
            .withStoredCredential(storedCredential)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollment3DSV2(threeDSecureResult)
    }

    func test_card_holder_enrolled_challenge_required_v2_refund_and_sale() {

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
        assertCheckEnrollment3DSV2(threeDSecureRefundResult)

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
        assertCheckEnrollment3DSV2(threeDSecureSaleResult)

        // Check
        XCTAssertNotEqual(threeDSecureRefundResult, threeDSecureSaleResult)
    }

    func test_card_holder_enrolled_challenge_required_v2_all_sources() {

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
            assertCheckEnrollment3DSV2(threeDSecureResult)
        }
    }

    func test_card_holder_enrolled_challenge_required_v2_with_nil_payment_method() {
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

    // MARK: - Tests for 3DS v2 Frictionless - Check Availability

    func test_card_holder_enrolled_frictionless_v22() {
        // GIVEN
        card.number = GpApi3DSTestCards.cardAuthSuccessfulV22
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
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollment3DSV2(threeDSecureResult)
    }

    func test_card_holder_enrolled_frictionless_v2_with_idempotencykey() {

        // Check Enrollment - 1

        // GIVEN
        card.number = GpApi3DSTestCards.cardAuthSuccessfulV22
        let idempotencyKey = UUID().uuidString
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
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
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Check Enrollment - 2

        // GIVEN
        let checkEnrollmentRepeatExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureRepeatResult: ThreeDSecure?
        var threeDSecureRepeatError: GatewayException?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                threeDSecureRepeatResult = $0
                if let error = $1 as? GatewayException {
                    threeDSecureRepeatError = error
                }
                checkEnrollmentRepeatExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentRepeatExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureRepeatResult)
        XCTAssertNotNil(threeDSecureRepeatError)
        XCTAssertEqual(threeDSecureRepeatError?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(threeDSecureRepeatError?.responseMessage, "40039")
        if let message = threeDSecureRepeatError?.message {
            XCTAssertTrue(message.contains("Idempotency Key seen before"))
        } else {
            XCTFail("threeDSecureRepeatError?.message cannot be nil")
        }
    }

    func test_card_holder_enrolled_frictionless_v2_with_tokenized_card() {

        // Tokenize

        // GIVEN
        card.number = GpApi3DSTestCards.cardAuthSuccessfulV22
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
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
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
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollment3DSV2(threeDSecureResult)
    }

    func test_card_holder_enrolled_frictionless_v2_all_preference_values() {

        card.number = GpApi3DSTestCards.cardAuthSuccessfulV22

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
            assertCheckEnrollment3DSV2(threeDSecureResult)
        }
    }

    func test_card_holder_enrolled_frictionless_v2_stored_credentials() {
        // GIVEN
        card.number = GpApi3DSTestCards.cardAuthSuccessfulV22
        let storedCredential = StoredCredential(
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
            .withStoredCredential(storedCredential)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollment3DSV2(threeDSecureResult)
    }

    func test_card_holder_enrolled_frictionless_v2_refund_and_sale() {

        // Refund

        // GIVEN
        card.number = GpApi3DSTestCards.cardAuthSuccessfulV22
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
        assertCheckEnrollment3DSV2(threeDSecureRefundResult)

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
        assertCheckEnrollment3DSV2(threeDSecureSaleResult)

        // Check
        XCTAssertNotEqual(threeDSecureRefundResult, threeDSecureSaleResult)
    }

    func test_card_holder_enrolled_frictionless_v2_all_sources() {

        card.number = GpApi3DSTestCards.cardAuthSuccessfulV22
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
            assertCheckEnrollment3DSV2(threeDSecureResult)
        }
    }

    // MARK: - Tests for 3DS v2 Challenge Required - Obtain Result

    func test_card_holder_challenge_required_post_result() {

        // Check enrollment

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
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult)
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, "CHALLENGE_REQUIRED")
        XCTAssertEqual(threeDSecureInitAuthResult?.challengeMandated, true)
        XCTAssertNotNil(threeDSecureInitAuthResult?.issuerAcsUrl)
        XCTAssertNotNil(threeDSecureInitAuthResult?.challengeValue)

        // Send challenge

        // GIVEN
        let authenticateExpectation = expectation(description: "Authenticate Expectation")
        let acsClient = GpApi3DSecureAcsClient(redirectURL: threeDSecureInitAuthResult?.issuerAcsUrl)
        var authResponse: String?

        // WHEN
        acsClient?.authenticateV2(secureEcom: threeDSecureInitAuthResult) {
            authResponse = $0
            authenticateExpectation.fulfill()
        }

        // THEN
        wait(for: [authenticateExpectation], timeout: 500.0)
        XCTAssertNotNil(authResponse)

        // Get authentication data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var authThreeDSecureResult: ThreeDSecure?
        var authThreeDSecureError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .execute {
                authThreeDSecureResult = $0
                authThreeDSecureError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 20.0)
        XCTAssertNil(authThreeDSecureError)
        XCTAssertNotNil(authThreeDSecureResult)
        XCTAssertEqual(authThreeDSecureResult?.status, "SUCCESS_AUTHENTICATED")
        XCTAssertNotNil(authThreeDSecureResult?.challengeValue)
        XCTAssertEqual(authThreeDSecureResult?.eci, 5)
        XCTAssertEqual(authThreeDSecureResult?.messageVersion, "2.2.0")
        XCTAssertNotNil(authThreeDSecureResult?.acsTransactionId)
        XCTAssertNotNil(authThreeDSecureResult?.serverTransactionId)
        XCTAssertNotNil(authThreeDSecureResult?.directoryServerTransactionId)
        XCTAssertNotNil(authThreeDSecureResult?.challengeValue)
    }

    func test_card_holder_challenge_required_post_result_with_idempotency_key() {

        // Check enrollment

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
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult)
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, "CHALLENGE_REQUIRED")
        XCTAssertEqual(threeDSecureInitAuthResult?.challengeMandated, true)
        XCTAssertNotNil(threeDSecureInitAuthResult?.issuerAcsUrl)
        XCTAssertNotNil(threeDSecureInitAuthResult?.challengeValue)

        // Send challenge

        // GIVEN
        let authenticateExpectation = expectation(description: "Authenticate Expectation")
        let acsClient = GpApi3DSecureAcsClient(redirectURL: threeDSecureInitAuthResult?.issuerAcsUrl)
        var authResponse: String?

        // WHEN
        acsClient?.authenticateV2(secureEcom: threeDSecureInitAuthResult) {
            authResponse = $0
            authenticateExpectation.fulfill()
        }

        // THEN
        wait(for: [authenticateExpectation], timeout: 500.0)
        XCTAssertNotNil(authResponse)

        // Get authentication data - 1

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var authThreeDSecureResult: ThreeDSecure?
        var authThreeDSecureError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                authThreeDSecureResult = $0
                authThreeDSecureError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 20.0)
        XCTAssertNil(authThreeDSecureError)
        XCTAssertNotNil(authThreeDSecureResult)
        XCTAssertEqual(authThreeDSecureResult?.status, "SUCCESS_AUTHENTICATED")
        XCTAssertNotNil(authThreeDSecureResult?.challengeValue)
        XCTAssertEqual(authThreeDSecureResult?.eci, 5)
        XCTAssertEqual(authThreeDSecureResult?.messageVersion, "2.2.0")
        XCTAssertNotNil(authThreeDSecureResult?.acsTransactionId)
        XCTAssertNotNil(authThreeDSecureResult?.serverTransactionId)
        XCTAssertNotNil(authThreeDSecureResult?.directoryServerTransactionId)
        XCTAssertNotNil(authThreeDSecureResult?.challengeValue)

        // Get authentication data - 2

        // GIVEN
        let getAuthenticationDataRepeatExpectation = expectation(description: "Get Authentication Data Expectation")
        var authThreeDSecureRepeatResult: ThreeDSecure?
        var authThreeDSecureRepeatError: GatewayException?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                authThreeDSecureRepeatResult = $0
                if let error = $1 as? GatewayException {
                    authThreeDSecureRepeatError = error
                }
                getAuthenticationDataRepeatExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataRepeatExpectation], timeout: 10.0)
        XCTAssertNil(authThreeDSecureRepeatResult)
        XCTAssertNotNil(authThreeDSecureRepeatError)
        XCTAssertEqual(authThreeDSecureRepeatError?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(authThreeDSecureRepeatError?.responseMessage, "40039")
        if let message = authThreeDSecureRepeatError?.message {
            XCTAssertTrue(message.contains("Idempotency Key seen before"))
        } else {
            XCTFail("threeDSecureRepeatError?.message cannot be nil")
        }
    }

    // MARK: - Tests for 3DS v2 Frictionless - Obtain Result

    func test_card_holder_frictionless_post_result() {

        // Check enrollment

        // GIVEN
        card.number = GpApi3DSTestCards.cardAuthSuccessfulV22
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
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult)
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, "SUCCESS_AUTHENTICATED")

        // Get authentication data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var authThreeDSecureResult: ThreeDSecure?
        var authThreeDSecureError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .execute {
                authThreeDSecureResult = $0
                authThreeDSecureError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 20.0)
        XCTAssertNil(authThreeDSecureError)
        XCTAssertNotNil(authThreeDSecureResult)
        XCTAssertEqual(authThreeDSecureResult?.status, "SUCCESS_AUTHENTICATED")
        XCTAssertNotNil(authThreeDSecureResult?.challengeValue)
        XCTAssertEqual(authThreeDSecureResult?.eci, 5)
        XCTAssertEqual(authThreeDSecureResult?.messageVersion, "2.2.0")
        XCTAssertNotNil(authThreeDSecureResult?.acsTransactionId)
        XCTAssertNotNil(authThreeDSecureResult?.serverTransactionId)
        XCTAssertNotNil(authThreeDSecureResult?.directoryServerTransactionId)
        XCTAssertNotNil(authThreeDSecureResult?.challengeValue)
    }

    func test_card_holder_frictionless_post_result_with_idempotency_key() {

        // Check enrollment

        // GIVEN
        let idempotencyKey = UUID().uuidString
        card.number = GpApi3DSTestCards.cardAuthSuccessfulV22
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
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult)
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, "SUCCESS_AUTHENTICATED")

        // Get authentication data - 1

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var authThreeDSecureResult: ThreeDSecure?
        var authThreeDSecureError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                authThreeDSecureResult = $0
                authThreeDSecureError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 20.0)
        XCTAssertNil(authThreeDSecureError)
        XCTAssertNotNil(authThreeDSecureResult)
        XCTAssertEqual(authThreeDSecureResult?.status, "SUCCESS_AUTHENTICATED")
        XCTAssertNotNil(authThreeDSecureResult?.challengeValue)
        XCTAssertEqual(authThreeDSecureResult?.eci, 5)
        XCTAssertEqual(authThreeDSecureResult?.messageVersion, "2.2.0")
        XCTAssertNotNil(authThreeDSecureResult?.acsTransactionId)
        XCTAssertNotNil(authThreeDSecureResult?.serverTransactionId)
        XCTAssertNotNil(authThreeDSecureResult?.directoryServerTransactionId)
        XCTAssertNotNil(authThreeDSecureResult?.challengeValue)

        // Get authentication data - 2

        // GIVEN
        let getAuthenticationDataRepeatExpectation = expectation(description: "Get Authentication Data Expectation")
        var authThreeDSecureRepeatResult: ThreeDSecure?
        var authThreeDSecureRepeatError: GatewayException?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                authThreeDSecureRepeatResult = $0
                if let error = $1 as? GatewayException {
                    authThreeDSecureRepeatError = error
                }
                getAuthenticationDataRepeatExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataRepeatExpectation], timeout: 10.0)
        XCTAssertNil(authThreeDSecureRepeatResult)
        XCTAssertNotNil(authThreeDSecureRepeatError)
        XCTAssertEqual(authThreeDSecureRepeatError?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(authThreeDSecureRepeatError?.responseMessage, "40039")
        if let message = authThreeDSecureRepeatError?.message {
            XCTAssertTrue(message.contains("Idempotency Key seen before"))
        } else {
            XCTFail("threeDSecureRepeatError?.message cannot be nil")
        }
    }

    func test_card_holder_frictionless_post_result_non_existent_id() {
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

    // MARK: - Tests for 3DS v2 Challenge - Initiate

    func test_card_holder_enrolled_challenge_required_v2_initiate() {

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
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        assertInitiate3DSV2(threeDSecureInitAuthResult)
    }

    func test_card_holder_enrolled_challenge_required_v2_initiate_with_idempotency_key() {

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
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication - 1

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        assertInitiate3DSV2(threeDSecureInitAuthResult)

        // Get authentication data - 2

        // GIVEN
        let getAuthenticationDataRepeatExpectation = expectation(description: "Get Authentication Data Expectation")
        var authThreeDSecureRepeatResult: ThreeDSecure?
        var authThreeDSecureRepeatError: GatewayException?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                authThreeDSecureRepeatResult = $0
                if let error = $1 as? GatewayException {
                    authThreeDSecureRepeatError = error
                }
                getAuthenticationDataRepeatExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataRepeatExpectation], timeout: 10.0)
        XCTAssertNil(authThreeDSecureRepeatResult)
        XCTAssertNotNil(authThreeDSecureRepeatError)
        XCTAssertEqual(authThreeDSecureRepeatError?.responseCode, "DUPLICATE_ACTION")
        XCTAssertEqual(authThreeDSecureRepeatError?.responseMessage, "40039")
        if let message = authThreeDSecureRepeatError?.message {
            XCTAssertTrue(message.contains("Idempotency Key seen before"))
        } else {
            XCTFail("threeDSecureRepeatError?.message cannot be nil")
        }
    }

    func test_card_holder_enrolled_challenge_required_v2_initiate_tokenized_card() {

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
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
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
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: tokenizedCard, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        assertInitiate3DSV2(threeDSecureInitAuthResult)
    }

    func test_card_holder_enrolled_challenge_required_v2_initiate_method_url_set_no() {

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
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.no)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        assertInitiate3DSV2(threeDSecureInitAuthResult)
    }

    func test_card_holder_enrolled_challenge_required_v2_initiate_method_url_set_unavailable() {

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
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.unavailable)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        assertInitiate3DSV2(threeDSecureInitAuthResult)
    }

    func test_card_holder_enrolled_challenge_required_v2_initiate_without_shipping_address() {

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
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        assertInitiate3DSV2(threeDSecureInitAuthResult)
    }

    func test_card_holder_enrolled_challenge_required_v2_initiate_with_gift_card() {

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
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withBrowserData(browserData)
            .withGiftCardCount(1)
            .withGiftCardAmount(2)
            .withGiftCardCurrency(currency)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        assertInitiate3DSV2(threeDSecureInitAuthResult)
    }

    func test_card_holder_enrolled_challenge_required_v2_initiate_with_shipping_method() {

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
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withBrowserData(browserData)
            .withShippingMethod(.digitalGoods)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        assertInitiate3DSV2(threeDSecureInitAuthResult)
    }

    func test_card_holder_enrolled_challenge_required_v2_initiate_with_delivery_email() {

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
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withBrowserData(browserData)
            .withDeliveryEmail("james.mason@example.com")
            .withDeliveryTimeFrame(.sameDay)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        assertInitiate3DSV2(threeDSecureInitAuthResult)
    }

    func test_card_holder_enrolled_frictionless_v2_initiate() {

        // Check Enrollment

        // GIVEN
        card.number = GpApi3DSTestCards.cardAuthSuccessfulV22
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
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, "SUCCESS_AUTHENTICATED")
        XCTAssertNotNil(threeDSecureInitAuthResult?.issuerAcsUrl)
        XCTAssertNotNil(threeDSecureInitAuthResult?.challengeValue)
        XCTAssertNotNil(threeDSecureInitAuthResult?.acsTransactionId)
        XCTAssertEqual(threeDSecureInitAuthResult?.eci, 5)
        XCTAssertEqual(threeDSecureInitAuthResult?.messageVersion, "2.2.0")
    }

    func test_card_holder_enrolled_challenge_required_v2_initiate_without_payment_method() {

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
        assertCheckEnrollment3DSV2(threeDSecureResult)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: GatewayException?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withPaymentMethod(nil)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                if let error = $1 as? GatewayException {
                    threeDSecureInitAuthError = error
                }
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthResult)
        XCTAssertNotNil(threeDSecureInitAuthError)
        XCTAssertEqual(threeDSecureInitAuthError?.responseCode, "MANDATORY_DATA_MISSING")
        XCTAssertEqual(threeDSecureInitAuthError?.responseMessage, "40005")
        if let message = threeDSecureInitAuthError?.message {
            XCTAssertEqual(message, "Status Code: 400 - Request expects the following fields number")
        } else {
            XCTFail("threeDSecureInitAuthError?.message cannot be nil")
        }
    }

    func test_card_holder_enrolled_challenge_required_v2_initiate_non_existent_id() {
        // GIVEN
        let transactionId = UUID().uuidString
        let secureEcom = ThreeDSecure()
        secureEcom.serverTransactionId = transactionId
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: GatewayException?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: secureEcom)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                if let error = $1 as? GatewayException {
                    threeDSecureInitAuthError = error
                }
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthResult)
        XCTAssertNotNil(threeDSecureInitAuthError)
        XCTAssertEqual(threeDSecureInitAuthError?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(threeDSecureInitAuthError?.responseMessage, "40118")
        if let message = threeDSecureInitAuthError?.message {
            XCTAssertEqual(message, "Status Code: 404 - Authentication \(transactionId) not found at this location.")
        } else {
            XCTFail("threeDSecureInitAuthError?.message cannot be nil")
        }
    }

    private func assertCheckEnrollment3DSV2(_ secureEcom: ThreeDSecure?) {
        XCTAssertNotNil(secureEcom)
        XCTAssertEqual(secureEcom?.enrolled, "ENROLLED")
        XCTAssertEqual(secureEcom?.version, .two)
        XCTAssertEqual(secureEcom?.status, "AVAILABLE")
        XCTAssertNotNil(secureEcom?.issuerAcsUrl)
        XCTAssertNotNil(secureEcom?.payerAuthenticationRequest)
        XCTAssertNotNil(secureEcom?.challengeValue)
        XCTAssertNil(secureEcom?.eci)
    }

    private func assertInitiate3DSV2(_ secureEcom: ThreeDSecure?) {
        XCTAssertNotNil(secureEcom)
        XCTAssertEqual(secureEcom?.status, "CHALLENGE_REQUIRED")
        XCTAssertEqual(secureEcom?.challengeMandated, true)
        XCTAssertNotNil(secureEcom?.issuerAcsUrl)
        XCTAssertNotNil(secureEcom?.challengeValue)
        XCTAssertNotNil(secureEcom?.acsTransactionId)
        XCTAssertNil(secureEcom?.eci)
        XCTAssertEqual(secureEcom?.messageVersion, "2.2.0")
    }
}
